from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user
from app.database.connection import get_db
from app.models.users import User
from app.schemas.auth import (
    CaregiverRegisterRequest, ConsentCreateRequest, FamilyRegisterRequest, LoginRequest,
    LogoutRequest, RefreshTokenRequest, SeniorRegisterRequest,
    StandardResponse, TokenResponse, UserRegisterRequest
)
from app.services.auth_service import AuthService
from app.services.user_service import UserService

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def register(
    payload: UserRegisterRequest,
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """
    Universal Registration Endpoint utilized directly by Flutter RegistrationScreen.
    Supports registration for Senior, Family, and Caregiver roles with Argon2id hashing.
    """
    ip = request.client.host if request.client else None
    user = await AuthService.register_user(db, payload, ip_address=ip)
    return StandardResponse(
        success=True,
        message=f"Account created successfully for {user.phone_number}",
        data={
            "id": str(user.id),
            "fullName": payload.full_name,
            "email": user.email,
            "phoneNumber": user.phone_number,
            "role": user.role,
            "createdAt": user.created_at.isoformat()
        }
    )


@router.post("/register/senior", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def register_senior(
    payload: SeniorRegisterRequest,
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """
    Dedicated Senior Citizen Registration with full profile details.
    Supports assisted onboarding by an authorized family member.
    """
    ip = request.client.host if request.client else None
    user, profile = await AuthService.register_senior(db, payload, ip_address=ip)
    return StandardResponse(
        success=True,
        message="Senior citizen registered successfully",
        data={
            "userId": str(user.id),
            "seniorProfileId": str(profile.id),
            "fullName": profile.full_name,
            "preferredName": profile.preferred_name,
            "role": "senior"
        }
    )


@router.post("/register/family", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def register_family(
    payload: FamilyRegisterRequest,
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """
    Dedicated Family Member Registration with relationship details.
    """
    ip = request.client.host if request.client else None
    user, profile = await AuthService.register_family(db, payload, ip_address=ip)
    return StandardResponse(
        success=True,
        message="Family member registered successfully",
        data={
            "userId": str(user.id),
            "familyProfileId": str(profile.id),
            "fullName": profile.full_name,
            "role": "family"
        }
    )


@router.post("/register/caregiver", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def register_caregiver(
    payload: CaregiverRegisterRequest,
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """
    Dedicated Caregiver / Caretaker Registration with hourly rate, experience, and service city.
    """
    ip = request.client.host if request.client else None
    user, profile = await AuthService.register_caregiver(db, payload, ip_address=ip)
    return StandardResponse(
        success=True,
        message="Caregiver registered successfully",
        data={
            "userId": str(user.id),
            "caregiverProfileId": str(profile.id),
            "fullName": profile.full_name,
            "serviceCity": profile.service_city,
            "role": "caregiver"
        }
    )


@router.post("/login", response_model=StandardResponse)
@router.post("/login/family", response_model=StandardResponse)
@router.post("/login/caregiver", response_model=StandardResponse)
async def login(
    payload: LoginRequest,
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """
    Universal & Family Login:
    Accepts email or phone number, verifies Argon2id password hash,
    and returns a short-lived access JWT + rotating refresh token.
    """
    ip = request.client.host if request.client else None
    user = await AuthService.authenticate(
        db,
        identifier=payload.identifier,
        password=payload.password,
        expected_role=payload.role,
        ip_address=ip
    )
    tokens = await AuthService.create_tokens(
        db,
        user=user,
        device_uuid=payload.device_uuid or "flutter-device"
    )
    return StandardResponse(
        success=True,
        message="Login successful",
        data=tokens.model_dump()
    )


@router.post("/refresh", response_model=StandardResponse)
async def refresh_token(
    payload: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Rotate expired access token using valid refresh token.
    Enforces single-use token rotation: revokes the old refresh token
    and issues an entirely new token pair.
    """
    tokens = await AuthService.rotate_refresh_token(
        db,
        raw_refresh_token=payload.refresh_token,
        device_uuid=payload.device_uuid or "flutter-device"
    )
    return StandardResponse(
        success=True,
        message="Token refreshed successfully",
        data=tokens.model_dump()
    )


@router.post("/logout", response_model=StandardResponse)
async def logout(
    payload: LogoutRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Revoke current refresh token and terminate session.
    """
    await AuthService.logout(db, user_id=current_user.id, raw_refresh_token=payload.refresh_token)
    return StandardResponse(
        success=True,
        message="Logged out successfully"
    )


@router.get("/me", response_model=StandardResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve authentication and profile summary for currently logged in user.
    """
    detail = await UserService.get_user_detail(db, current_user.id)
    return StandardResponse(
        success=True,
        message="User details retrieved",
        data=detail.model_dump(by_alias=True)
    )


@router.post("/consent", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def record_consent(
    payload: ConsentCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Record explicit informed consent (e.g. for biometric face authentication or health data sharing).
    """
    consent = await UserService.record_consent(
        db,
        user_id=current_user.id,
        consent_type=payload.consent_type,
        consent_version=payload.consent_version,
        is_granted=payload.is_granted
    )
    return StandardResponse(
        success=True,
        message="Consent recorded successfully",
        data={
            "consentId": str(consent.id),
            "consentType": consent.consent_type,
            "isGranted": consent.is_granted,
            "grantedAt": consent.granted_at.isoformat()
        }
    )
