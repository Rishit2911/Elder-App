from datetime import date
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, EmailStr, Field


class SeniorRegisterRequest(BaseModel):
    phone_number: str = Field(..., pattern=r"^\+?[1-9]\d{9,14}$")
    full_name: str = Field(..., min_length=2, max_length=150)
    preferred_name: Optional[str] = "दादाजी"
    date_of_birth: date
    gender: str = Field(..., pattern="^(male|female|other)$")
    blood_group: Optional[str] = None
    address: str = Field(..., min_length=5)
    city: str
    postal_code: str
    primary_language: str = "hi"


class FamilyRegisterRequest(BaseModel):
    phone_number: str = Field(..., pattern=r"^\+?[1-9]\d{9,14}$")
    email: Optional[EmailStr] = None
    password: str = Field(..., min_length=8)
    full_name: str
    relationship_description: Optional[str] = None


class LoginRequest(BaseModel):
    username: str  # Phone number or Email
    password: str
    device_uuid: str
    platform: str = "android"


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 900
    user: dict


class RefreshTokenRequest(BaseModel):
    refresh_token: str
    device_uuid: str

