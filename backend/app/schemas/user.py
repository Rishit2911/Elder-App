from datetime import date, datetime
from typing import Any, Dict, Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class SeniorProfileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    id: UUID
    full_name: str = Field(..., alias="fullName")
    preferred_name: Optional[str] = Field(None, alias="preferredName")
    date_of_birth: Optional[date] = Field(None, alias="dateOfBirth")
    gender: Optional[str] = None
    blood_group: Optional[str] = Field(None, alias="bloodGroup")
    address: Optional[str] = None
    city: Optional[str] = None
    postal_code: Optional[str] = Field(None, alias="postalCode")
    primary_language: Optional[str] = Field(None, alias="primaryLanguage")
    profile_picture_url: Optional[str] = Field(None, alias="profilePictureUrl")


class FamilyProfileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    id: UUID
    full_name: str = Field(..., alias="fullName")
    alternate_phone: Optional[str] = Field(None, alias="alternatePhone")
    relationship_description: Optional[str] = Field(None, alias="relationshipDescription")


class UserDetailResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    id: UUID
    full_name: str = Field(..., alias="fullName")
    email: Optional[str] = None
    phone_number: str = Field(..., alias="phoneNumber")
    role: str
    is_active: bool = Field(..., alias="isActive")
    is_verified: bool = Field(..., alias="isVerified")
    created_at: datetime = Field(..., alias="createdAt")
    profile: Optional[Dict[str, Any]] = None


class UserProfileUpdate(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    full_name: Optional[str] = Field(None, alias="fullName", min_length=2, max_length=150)
    email: Optional[EmailStr] = None
    preferred_name: Optional[str] = Field(None, alias="preferredName")
    address: Optional[str] = None
    city: Optional[str] = None
    postal_code: Optional[str] = Field(None, alias="postalCode")
    primary_language: Optional[str] = Field(None, alias="primaryLanguage")
    alternate_phone: Optional[str] = Field(None, alias="alternatePhone")
    profile_picture_url: Optional[str] = Field(None, alias="profilePictureUrl")

