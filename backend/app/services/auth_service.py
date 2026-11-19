import hashlib
import re
import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import (
    create_access_token, create_refresh_token, hash_password, verify_password
)
from app.models.biometrics import Device, RefreshToken
from app.models.payments import AuditLog
from app.models.users import (
    CaregiverProfile, FamilyProfile, SeniorProfile, User, UserConsent
)
from app.schemas.auth import (
    CaregiverRegisterRequest, FamilyRegisterRequest, LoginRequest,
    SeniorRegisterRequest, TokenResponse, UserRegisterRequest
)


class AuthService:
    """
    Production-grade Authentication Service implementing:
    - Argon2id password hashing
    - Unique login identifier lookups
    - JWT access & rotating refresh tokens
    - Audit logging
    - Multi-role profile bootstrapping
    """

    @staticmethod
    async def get_user_by_identifier(db: AsyncSession, identifier: str) -> Optional[User]:
        """Find user by email or phone number using indexed columns."""
        clean_id = identifier.strip()
        # If not an email, normalize digits
        norm_phone = re.sub(r"[^\d+]", "", clean_id) if "@" not in clean_id else clean_id
        stmt = select(User).where(
            or_(
                User.phone_number == clean_id,
                User.phone_number == norm_phone,
                User.email == clean_id.lower()
            )
        )
        result = await db.execute(stmt)
        return result.scalars().first()

    @classmethod
    async def register_user(
        cls,
        db: AsyncSession,
        payload: UserRegisterRequest,
        ip_address: Optional[str] = None
    ) -> User:
        """Register a user across any persona role."""
        # Check phone uniqueness
        stmt_phone = select(User).where(User.phone_number == payload.phone_number)
        existing_phone = (await db.execute(stmt_phone)).scalars().first()
        if existing_phone:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A user with this mobile number is already registered"
            )

        email_clean = payload.email.lower() if payload.email else None
        if email_clean:
            stmt_email = select(User).where(User.email == email_clean)
            existing_email = (await db.execute(stmt_email)).scalars().first()
            if existing_email:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="A user with this email address is already registered"
                )

        hashed_pw = hash_password(payload.password) if payload.password else None

        user = User(
            phone_number=payload.phone_number,
            email=email_clean,
            hashed_password=hashed_pw,
            role=payload.role,
            is_active=True,
            is_verified=False
        )
        db.add(user)
        await db.flush()

        # Create corresponding persona profile
        if payload.role == "senior":
            senior_profile = SeniorProfile(
                user_id=user.id,
                full_name=payload.full_name,
                preferred_name="दादाजी",
                date_of_birth=datetime(1950, 1, 1).date(),
                gender="other",
                address="Not Specified",
                city="Delhi",
                postal_code="110001",
                primary_language="hi"
            )
            db.add(senior_profile)
        elif payload.role == "family":
            family_profile = FamilyProfile(
                user_id=user.id,
                full_name=payload.full_name,
                relationship_description="Family Member"
            )
            db.add(family_profile)
        elif payload.role == "caregiver":
            caregiver_profile = CaregiverProfile(
                user_id=user.id,
                full_name=payload.full_name,
                gender="other",
                hourly_rate=250.00,
                service_city="Delhi"
            )
            db.add(caregiver_profile)

        # Log security event
        audit = AuditLog(
            actor_user_id=user.id,
            target_entity_type="user",
            target_entity_id=user.id,
            action="REGISTER",
            ip_address=ip_address,
            details_json={"role": user.role, "phone": user.phone_number}
        )
        db.add(audit)

        await db.commit()
        await db.refresh(user)
        return user

    @classmethod
    async def register_senior(
        cls,
        db: AsyncSession,
        payload: SeniorRegisterRequest,
        ip_address: Optional[str] = None
    ) -> Tuple[User, SeniorProfile]:
        """Register a senior citizen with full profile details."""
        # Uniqueness checks
        stmt = select(User).where(User.phone_number == payload.phone_number)
        if (await db.execute(stmt)).scalars().first():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A user with this mobile number is already registered"
            )

        if payload.email:
            stmt_e = select(User).where(User.email == payload.email)
            if (await db.execute(stmt_e)).scalars().first():
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="A user with this email address is already registered"
                )

        hashed_pw = hash_password(payload.password) if payload.password else None

        user = User(
            phone_number=payload.phone_number,
            email=payload.email,
            hashed_password=hashed_pw,
            role="senior",
            is_active=True,
            is_verified=False
        )
        db.add(user)
        await db.flush()

        dob = payload.date_of_birth or datetime(1950, 1, 1).date()
        profile = SeniorProfile(
            user_id=user.id,
            full_name=payload.full_name,
            preferred_name=payload.preferred_name or "दादाजी",
            date_of_birth=dob,
            gender=payload.gender or "other",
            blood_group=payload.blood_group,
            address=payload.address or "Not Specified",
            city=payload.city or "Delhi",
            postal_code=payload.postal_code or "110001",
            primary_language=payload.primary_language or "hi"
        )
        db.add(profile)

        # Audit assisted registration if applicable
        audit_details = {"assisted_by": str(payload.assisted_by_user_id)} if payload.assisted_by_user_id else {}
        audit = AuditLog(
            actor_user_id=payload.assisted_by_user_id or user.id,
            target_entity_type="senior_profile",
            target_entity_id=user.id,
            action="REGISTER_SENIOR",
            ip_address=ip_address,
            details_json=audit_details
        )
        db.add(audit)

        await db.commit()
        await db.refresh(user)
        await db.refresh(profile)
        return user, profile

    @classmethod
    async def register_family(
        cls,
        db: AsyncSession,
        payload: FamilyRegisterRequest,
        ip_address: Optional[str] = None
    ) -> Tuple[User, FamilyProfile]:
        """Register a remote family member."""
        stmt = select(User).where(User.phone_number == payload.phone_number)
        if (await db.execute(stmt)).scalars().first():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A user with this mobile number is already registered"
            )

        if payload.email:
            stmt_e = select(User).where(User.email == payload.email)
            if (await db.execute(stmt_e)).scalars().first():
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="A user with this email address is already registered"
                )

        hashed_pw = hash_password(payload.password)
        user = User(
            phone_number=payload.phone_number,
            email=payload.email,
            hashed_password=hashed_pw,
            role="family",
            is_active=True,
            is_verified=False
        )
        db.add(user)
        await db.flush()

        profile = FamilyProfile(
            user_id=user.id,
            full_name=payload.full_name,
            alternate_phone=payload.alternate_phone,
            relationship_description=payload.relationship_type or "Family Member"
        )
        db.add(profile)

        audit = AuditLog(
            actor_user_id=user.id,
            target_entity_type="family_profile",
            target_entity_id=user.id,
            action="REGISTER_FAMILY",
            ip_address=ip_address,
            details_json={"relationship": payload.relationship_type}
        )
        db.add(audit)

        await db.commit()
        await db.refresh(user)
        await db.refresh(profile)
        return user, profile

    @classmethod
    async def register_caregiver(
        cls,
        db: AsyncSession,
        payload: CaregiverRegisterRequest,
        ip_address: Optional[str] = None
    ) -> Tuple[User, CaregiverProfile]:
        """Register a professional in-home caregiver / caretaker."""
        stmt = select(User).where(User.phone_number == payload.phone_number)
        if (await db.execute(stmt)).scalars().first():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A user with this mobile number is already registered"
            )

        if payload.email:
            stmt_e = select(User).where(User.email == payload.email)
            if (await db.execute(stmt_e)).scalars().first():
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="A user with this email address is already registered"
                )

        hashed_pw = hash_password(payload.password)
        user = User(
            phone_number=payload.phone_number,
            email=payload.email,
            hashed_password=hashed_pw,
            role="caregiver",
            is_active=True,
            is_verified=False
        )
        db.add(user)
        await db.flush()

        profile = CaregiverProfile(
            user_id=user.id,
            full_name=payload.full_name,
            gender=payload.gender or "other",
            hourly_rate=payload.hourly_rate or 250.0,
            service_city=payload.service_city or "Delhi NCR",
            experience_years=payload.experience_years or 1,
            bio=payload.bio or "Certified elder care specialist"
        )
        db.add(profile)

        audit = AuditLog(
            actor_user_id=user.id,
            target_entity_type="caregiver_profile",
            target_entity_id=user.id,
            action="REGISTER_CAREGIVER",
            ip_address=ip_address,
            details_json={"city": payload.service_city, "rate": payload.hourly_rate}
        )
        db.add(audit)

        await db.commit()
        await db.refresh(user)
        await db.refresh(profile)
        return user, profile

    @classmethod
    async def authenticate(
        cls,
        db: AsyncSession,
        identifier: str,
        password: str,
        expected_role: Optional[str] = None,
        ip_address: Optional[str] = None
    ) -> User:
        """Authenticate user with Argon2id verification."""
        user = await cls.get_user_by_identifier(db, identifier)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid login credentials",
                headers={"WWW-Authenticate": "Bearer"}
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account is inactive or disabled. Please contact support."
            )

        if expected_role and user.role != expected_role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"This account is registered as '{user.role}', not '{expected_role}'."
            )

        if not user.hashed_password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This account does not have a password configured. Please use biometric face login."
            )

        if not verify_password(password, user.hashed_password):
            audit = AuditLog(
                actor_user_id=user.id,
                target_entity_type="user",
                target_entity_id=user.id,
                action="LOGIN_FAILED",
                ip_address=ip_address,
                details_json={"reason": "bad_password"}
            )
            db.add(audit)
            await db.commit()
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid login credentials",
                headers={"WWW-Authenticate": "Bearer"}
            )

        # Audit successful login
        audit = AuditLog(
            actor_user_id=user.id,
            target_entity_type="user",
            target_entity_id=user.id,
            action="LOGIN_SUCCESS",
            ip_address=ip_address,
            details_json={"method": "password"}
        )
        db.add(audit)
        await db.commit()
        return user

    @classmethod
    async def create_tokens(
        cls,
        db: AsyncSession,
        user: User,
        device_uuid: str = "default-device"
    ) -> TokenResponse:
        """Issue access JWT and store hashed rotating refresh token."""
        # Ensure device record exists
        stmt_dev = select(Device).where(Device.user_id == user.id, Device.device_uuid == device_uuid)
        device = (await db.execute(stmt_dev)).scalars().first()
        if not device:
            device = Device(
                user_id=user.id,
                device_uuid=device_uuid,
                platform="android"
            )
            db.add(device)
            await db.flush()

        # Generate Access Token (15 min)
        access_token = create_access_token(
            subject=str(user.id),
            role=user.role
        )

        # Generate Refresh Token (7 days)
        raw_refresh, token_hash = create_refresh_token(str(user.id), device_uuid)
        expires_at = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

        refresh_record = RefreshToken(
            user_id=user.id,
            device_id=device.id,
            token_hash=token_hash,
            expires_at=expires_at,
            is_revoked=False
        )
        db.add(refresh_record)
        await db.commit()

        # Fetch display name safely
        display_name = user.phone_number
        try:
            if user.role == "senior" and user.senior_profile:
                display_name = user.senior_profile.full_name
            elif user.role == "family" and user.family_profile:
                display_name = user.family_profile.full_name
            elif user.role == "caregiver" and user.caregiver_profile:
                display_name = user.caregiver_profile.full_name
        except Exception:
            display_name = user.phone_number

        return TokenResponse(
            access_token=access_token,
            refresh_token=raw_refresh,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            user={
                "id": str(user.id),
                "fullName": display_name,
                "email": user.email,
                "phoneNumber": user.phone_number,
                "role": user.role
            }
        )

    @classmethod
    async def rotate_refresh_token(
        cls,
        db: AsyncSession,
        raw_refresh_token: str,
        device_uuid: str = "default-device"
    ) -> TokenResponse:
        """Rotate a refresh token, invalidating the old token and generating a new pair."""
        token_hash = hashlib.sha256(raw_refresh_token.encode("utf-8")).hexdigest()
        stmt = select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        record = (await db.execute(stmt)).scalars().first()

        now = datetime.now(timezone.utc)
        if not record or record.is_revoked or record.expires_at < now:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token is invalid, expired, or has already been revoked",
                headers={"WWW-Authenticate": "Bearer"}
            )

        # Revoke old token
        record.is_revoked = True

        # Load user
        user = await db.get(User, record.user_id)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User account is no longer active"
            )

        await db.commit()
        # Create fresh token pair
        return await cls.create_tokens(db, user, device_uuid)

    @classmethod
    async def logout(
        cls,
        db: AsyncSession,
        user_id: uuid.UUID,
        raw_refresh_token: Optional[str] = None
    ) -> None:
        """Revoke refresh token and log out user."""
        if raw_refresh_token:
            token_hash = hashlib.sha256(raw_refresh_token.encode("utf-8")).hexdigest()
            stmt = select(RefreshToken).where(RefreshToken.token_hash == token_hash)
            record = (await db.execute(stmt)).scalars().first()
            if record:
                record.is_revoked = True

        audit = AuditLog(
            actor_user_id=user_id,
            target_entity_type="user",
            target_entity_id=user_id,
            action="LOGOUT"
        )
        db.add(audit)
        await db.commit()
