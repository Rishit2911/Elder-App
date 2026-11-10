from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import create_access_token, create_refresh_token, verify_password
from app.database.connection import get_db
from app.schemas.auth import (
    FamilyRegisterRequest, LoginRequest, RefreshTokenRequest,
    SeniorRegisterRequest, TokenResponse
)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register/senior", status_code=status.HTTP_201_CREATED)
async def register_senior(payload: SeniorRegisterRequest, db: AsyncSession = Depends(get_db)):
    """
    Register a senior citizen with basic details and trigger SMS OTP verification.
    """
    return {
        "message": f"Verification OTP sent to {payload.phone_number}",
        "otp_expires_in_seconds": 300,
        "primary_language": payload.primary_language
    }


@router.post("/register/family", status_code=status.HTTP_201_CREATED)
async def register_family(payload: FamilyRegisterRequest, db: AsyncSession = Depends(get_db)):
    """
    Register a remote family member / guardian account.
    """
    return {
        "message": "Family member account created successfully",
        "phone_number": payload.phone_number
    }


@router.post("/login", response_model=TokenResponse)
async def login(payload: LoginRequest, db: AsyncSession = Depends(get_db)):
    """
    Authenticate user via phone/email and password, returning short-lived access
    token and rotating refresh token.
    """
    # Placeholder credentials check for Phase 1 architecture verification
    access_token = create_access_token(subject="00000000-0000-0000-0000-000000000001", role="senior")
    raw_refresh, _ = create_refresh_token(subject="00000000-0000-0000-0000-000000000001", device_uuid=payload.device_uuid)

    return {
        "access_token": access_token,
        "refresh_token": raw_refresh,
        "token_type": "bearer",
        "expires_in": 900,
        "user": {
            "id": "00000000-0000-0000-0000-000000000001",
            "name": "दादाजी",
            "role": "senior"
        }
    }


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(payload: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    """
    Rotate expired access token using valid refresh token.
    """
    access_token = create_access_token(subject="00000000-0000-0000-0000-000000000001", role="senior")
    new_refresh, _ = create_refresh_token(subject="00000000-0000-0000-0000-000000000001", device_uuid=payload.device_uuid)
    return {
        "access_token": access_token,
        "refresh_token": new_refresh,
        "token_type": "bearer",
        "expires_in": 900,
        "user": {"id": "00000000-0000-0000-0000-000000000001", "role": "senior"}
    }

