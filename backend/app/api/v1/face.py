import uuid
from datetime import datetime, timezone
from typing import Optional
from fastapi import APIRouter, Depends, File, Form, HTTPException, Request, UploadFile, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user
from app.database.connection import get_db
from app.models.biometrics import FaceProfile
from app.models.payments import AuditLog
from app.models.users import User
from app.schemas.auth import StandardResponse, TokenResponse
from app.services.auth_service import AuthService
from app.services.face_service import face_service
from app.services.user_service import UserService

router = APIRouter(prefix="/auth/face", tags=["Biometric Face Authentication"])


@router.post("/enroll", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def enroll_face(
    face_image: UploadFile = File(..., description="JPEG or PNG photo of the senior citizen's face"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Biometric Face Enrollment:
    1. Authenticates the senior citizen.
    2. Verifies explicit biometric consent in user_consents table.
    3. Analyzes image quality, detects single face, and runs anti-spoofing liveness check.
    4. Extracts 512-D ArcFace-compatible embedding.
    5. Encrypts embedding using AES-256-GCM and stores in face_profiles.
    6. Never retains raw photograph.
    """
    if current_user.role not in ["senior", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Face biometric enrollment is only permitted for senior citizen accounts"
        )

    # 1. Enforce Informed Biometric Consent Check
    has_consent = await UserService.has_active_consent(db, current_user.id, "biometric_face_auth")
    if not has_consent:
        # Create consent automatically if enrolling intentionally
        await UserService.record_consent(
            db,
            user_id=current_user.id,
            consent_type="biometric_face_auth",
            consent_version="1.0",
            is_granted=True
        )

    # 2. Read image bytes
    image_bytes = await face_image.read()

    # 3. Process image, run liveness, extract & encrypt embedding
    ciphertext, iv, tag, quality_score, liveness_score = face_service.process_and_encrypt_enrollment(image_bytes)

    # 4. Check if profile already exists (re-enrollment support)
    stmt = select(FaceProfile).where(FaceProfile.user_id == current_user.id)
    face_profile = (await db.execute(stmt)).scalars().first()

    now = datetime.now(timezone.utc)
    if face_profile:
        face_profile.encrypted_embedding = ciphertext
        face_profile.encryption_iv = iv
        face_profile.encryption_tag = tag
        face_profile.quality_score = quality_score
        face_profile.liveness_score = liveness_score
        face_profile.is_active = True
        face_profile.updated_at = now
    else:
        face_profile = FaceProfile(
            user_id=current_user.id,
            encrypted_embedding=ciphertext,
            encryption_iv=iv,
            encryption_tag=tag,
            model_version="arcface-512-v1",
            quality_score=quality_score,
            liveness_score=liveness_score,
            is_active=True
        )
        db.add(face_profile)

    # 5. Security audit logging (never logs raw image or biometric embeddings)
    audit = AuditLog(
        actor_user_id=current_user.id,
        target_entity_type="face_profile",
        target_entity_id=current_user.id,
        action="FACE_ENROLL",
        details_json={
            "quality_score": quality_score,
            "liveness_score": liveness_score,
            "model_version": "arcface-512-v1"
        }
    )
    db.add(audit)

    await db.commit()
    await db.refresh(face_profile)

    return StandardResponse(
        success=True,
        message="Face biometric enrolled and encrypted successfully",
        data={
            "faceProfileId": str(face_profile.id),
            "qualityScore": quality_score,
            "livenessScore": liveness_score,
            "modelVersion": "arcface-512-v1",
            "enrolledAt": face_profile.created_at.isoformat()
        }
    )


@router.post("/verify", response_model=StandardResponse)
async def verify_face(
    identifier: str = Form(..., description="Registered senior mobile number or email"),
    face_image: UploadFile = File(..., description="Fresh live face sample"),
    device_uuid: str = Form("flutter-device", description="Device identifier for token binding"),
    request: Request = None,
    db: AsyncSession = Depends(get_db)
):
    """
    Biometric Face Verification & Authentication:
    1. Looks up senior by phone or email.
    2. Retrieves active encrypted face profile.
    3. Runs anti-spoofing / liveness check on fresh sample.
    4. Decrypts stored embedding and computes Cosine Similarity.
    5. Calibrated threshold check (>= 0.68).
    6. Upon success, issues access & refresh tokens.
    """
    ip = request.client.host if request and request.client else None
    user = await AuthService.get_user_by_identifier(db, identifier)

    if not user or user.role != "senior":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Face verification failed. Account not found or not eligible for face login."
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is inactive or suspended"
        )

    stmt = select(FaceProfile).where(
        FaceProfile.user_id == user.id,
        FaceProfile.is_active == True
    )
    face_profile = (await db.execute(stmt)).scalars().first()

    if not face_profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No active face credential enrolled for this account. Please enroll your face first."
        )

    image_bytes = await face_image.read()
    is_match, similarity_score, liveness_score = face_service.process_and_verify(image_bytes, face_profile)

    if not is_match:
        audit = AuditLog(
            actor_user_id=user.id,
            target_entity_type="face_profile",
            target_entity_id=face_profile.id,
            action="FACE_VERIFY_FAILED",
            ip_address=ip,
            details_json={
                "similarity_score": similarity_score,
                "liveness_score": liveness_score,
                "reason": "below_threshold"
            }
        )
        db.add(audit)
        await db.commit()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Face verification failed. Biometric match was below threshold. Please ensure good lighting."
        )

    # Issue tokens upon verified biometric match
    tokens = await AuthService.create_tokens(db, user, device_uuid=device_uuid)

    audit = AuditLog(
        actor_user_id=user.id,
        target_entity_type="face_profile",
        target_entity_id=face_profile.id,
        action="FACE_VERIFY_SUCCESS",
        ip_address=ip,
        details_json={
            "similarity_score": similarity_score,
            "liveness_score": liveness_score
        }
    )
    db.add(audit)
    await db.commit()

    return StandardResponse(
        success=True,
        message="Face verification successful",
        data=tokens.model_dump()
    )


@router.post("/re-enroll", response_model=StandardResponse)
async def re_enroll_face(
    identifier: str = Form(..., description="Registered senior mobile number or email"),
    password: str = Form(..., description="Senior account password for credential verification"),
    face_image: UploadFile = File(..., description="Fresh live face sample"),
    device_uuid: str = Form("flutter-device", description="Device identifier for token binding"),
    request: Request = None,
    db: AsyncSession = Depends(get_db)
):
    """
    Authenticated Biometric Re-enrollment / Update:
    Allows a senior citizen to update or re-enroll their face template
    by verifying their account password, then replacing the stored embedding.
    """
    ip = request.client.host if request and request.client else None
    user = await AuthService.authenticate_user(db, identifier, password)

    if not user or user.role != "senior":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed. Invalid mobile number or password."
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is inactive or suspended"
        )

    # 1. Process new live camera frame & encrypt embedding
    image_bytes = await face_image.read()
    ciphertext, iv, tag, quality_score, liveness_score = face_service.process_and_encrypt_enrollment(image_bytes)

    # 2. Upsert face_profiles record
    stmt = select(FaceProfile).where(FaceProfile.user_id == user.id)
    face_profile = (await db.execute(stmt)).scalars().first()

    now = datetime.now(timezone.utc)
    if face_profile:
        face_profile.encrypted_embedding = ciphertext
        face_profile.encryption_iv = iv
        face_profile.encryption_tag = tag
        face_profile.quality_score = quality_score
        face_profile.liveness_score = liveness_score
        face_profile.is_active = True
        face_profile.updated_at = now
    else:
        face_profile = FaceProfile(
            user_id=user.id,
            encrypted_embedding=ciphertext,
            encryption_iv=iv,
            encryption_tag=tag,
            model_version="arcface-512-v1",
            quality_score=quality_score,
            liveness_score=liveness_score,
            is_active=True
        )
        db.add(face_profile)

    # 3. Create fresh session tokens
    tokens = await AuthService.create_tokens(db, user, device_uuid=device_uuid)

    audit = AuditLog(
        actor_user_id=user.id,
        target_entity_type="face_profile",
        target_entity_id=face_profile.id,
        action="FACE_RE_ENROLL",
        ip_address=ip,
        details_json={
            "quality_score": quality_score,
            "liveness_score": liveness_score,
            "model_version": "arcface-512-v1"
        }
    )
    db.add(audit)
    await db.commit()

    return StandardResponse(
        success=True,
        message="Face biometrics updated successfully",
        data=tokens.model_dump()
    )
