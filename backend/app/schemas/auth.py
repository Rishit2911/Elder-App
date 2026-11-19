import re
from datetime import date, datetime
from typing import Any, Dict, List, Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class StandardResponse(BaseModel):
    success: bool = True
    message: str
    data: Optional[Any] = None
    error_code: Optional[str] = None


class UserRegisterRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    full_name: str = Field(..., alias="fullName", min_length=2, max_length=150)
    email: Optional[EmailStr] = None
    phone_number: str = Field(..., alias="phoneNumber")
    password: Optional[str] = Field(None, min_length=6)
    role: str = Field("senior", pattern="^(senior|family|caregiver|doctor|admin)$")

    @field_validator("phone_number")
    @classmethod
    def normalize_phone(cls, v: str) -> str:
        clean = re.sub(r"[^\d+]", "", v)
        if len(clean) < 7:
            raise ValueError("Invalid phone number format")
        return clean


class SeniorRegisterRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    full_name: str = Field(..., alias="fullName", min_length=2, max_length=150)
    phone_number: str = Field(..., alias="phoneNumber")
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(None, min_length=6)
    preferred_name: Optional[str] = Field(None, alias="preferredName")
    date_of_birth: Optional[date] = Field(None, alias="dateOfBirth")
    gender: Optional[str] = Field("other", pattern="^(male|female|other)$")
    blood_group: Optional[str] = Field(None, alias="bloodGroup")
    address: Optional[str] = "Not Specified"
    city: Optional[str] = "Delhi"
    postal_code: Optional[str] = Field("110001", alias="postalCode")
    primary_language: str = Field("hi", alias="primaryLanguage")
    assisted_by_user_id: Optional[UUID] = Field(None, alias="assistedByUserId")

    @field_validator("phone_number")
    @classmethod
    def normalize_phone(cls, v: str) -> str:
        clean = re.sub(r"[^\d+]", "", v)
        if len(clean) < 7:
            raise ValueError("Invalid phone number format")
        return clean


class FamilyRegisterRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    full_name: str = Field(..., alias="fullName", min_length=2, max_length=150)
    email: Optional[EmailStr] = None
    phone_number: str = Field(..., alias="phoneNumber")
    password: str = Field(..., min_length=6)
    relationship_type: Optional[str] = Field("other", alias="relationshipType")
    alternate_phone: Optional[str] = Field(None, alias="alternatePhone")

    @field_validator("phone_number")
    @classmethod
    def normalize_phone(cls, v: str) -> str:
        clean = re.sub(r"[^\d+]", "", v)
        if len(clean) < 7:
            raise ValueError("Invalid phone number format")
        return clean


class CaregiverRegisterRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    full_name: str = Field(..., alias="fullName", min_length=2, max_length=150)
    email: Optional[EmailStr] = None
    phone_number: str = Field(..., alias="phoneNumber")
    password: str = Field(..., min_length=6)
    gender: Optional[str] = "other"
    hourly_rate: Optional[float] = Field(250.0, alias="hourlyRate")
    service_city: Optional[str] = Field("Delhi NCR", alias="serviceCity")
    experience_years: Optional[int] = Field(1, alias="experienceYears")
    bio: Optional[str] = None

    @field_validator("phone_number")
    @classmethod
    def normalize_phone(cls, v: str) -> str:
        clean = re.sub(r"[^\d+]", "", v)
        if len(clean) < 7:
            raise ValueError("Invalid phone number format")
        return clean


class LoginRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    identifier: str = Field(..., alias="emailOrPhone")
    password: str
    role: Optional[str] = None
    device_uuid: Optional[str] = Field("default-web-device", alias="deviceUuid")
    platform: Optional[str] = "android"


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 900
    user: Dict[str, Any]


class RefreshTokenRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    refresh_token: str = Field(..., alias="refreshToken")
    device_uuid: Optional[str] = Field("default-web-device", alias="deviceUuid")


class LogoutRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    refresh_token: Optional[str] = Field(None, alias="refreshToken")


class ConsentCreateRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    consent_type: str = Field(..., alias="consentType")  # biometric_face_auth, health_data_sharing
    consent_version: str = Field("1.0", alias="consentVersion")
    is_granted: bool = Field(True, alias="isGranted")
