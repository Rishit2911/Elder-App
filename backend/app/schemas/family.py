from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class FamilyInvitationCreate(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    target_phone: str = Field(..., alias="targetPhone")
    relationship: str = Field("other", pattern="^(son|daughter|spouse|grandchild|sibling|other|guardian)$")
    custom_relationship: Optional[str] = Field(None, alias="customRelationship")
    invitee_email: Optional[EmailStr] = Field(None, alias="inviteeEmail")


class FamilyLinkApproval(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    invitation_id: UUID = Field(..., alias="invitationId")
    approved: bool = True
    can_manage_medications: bool = Field(True, alias="canManageMedications")
    can_view_records: bool = Field(True, alias="canViewRecords")
    can_book_services: bool = Field(True, alias="canBookServices")
    emergency_priority: int = Field(1, alias="emergencyPriority")


class PermissionsUpdateRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    can_manage_medications: Optional[bool] = Field(None, alias="canManageMedications")
    can_view_records: Optional[bool] = Field(None, alias="canViewRecords")
    can_book_services: Optional[bool] = Field(None, alias="canBookServices")
    is_emergency_contact: Optional[bool] = Field(None, alias="isEmergencyContact")
    is_primary_caregiver_contact: Optional[bool] = Field(None, alias="isPrimaryCaregiverContact")


class FamilyLinkItem(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    id: UUID
    senior_id: UUID = Field(..., alias="seniorId")
    senior_name: str = Field(..., alias="seniorName")
    family_user_id: UUID = Field(..., alias="familyUserId")
    family_name: str = Field(..., alias="familyName")
    relationship: str
    status: str
    is_emergency_contact: bool = Field(..., alias="isEmergencyContact")
    is_primary_caregiver_contact: bool = Field(..., alias="isPrimaryCaregiverContact")
    can_manage_medications: bool = Field(..., alias="canManageMedications")
    can_view_records: bool = Field(..., alias="canViewRecords")
    can_book_services: bool = Field(..., alias="canBookServices")
    created_at: datetime = Field(..., alias="createdAt")
