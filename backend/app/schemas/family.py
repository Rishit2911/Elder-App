from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel, Field


class FamilyInvitationCreate(BaseModel):
    invitee_phone: str = Field(..., pattern=r"^\+?[1-9]\d{9,14}$")
    relation_proposed: str = Field(..., min_length=2, max_length=50)


class InvitationAcceptRequest(BaseModel):
    invitation_code: str


class PermissionItem(BaseModel):
    module: str = Field(..., pattern="^(health_records|medicines|live_location|caregiver_bookings|doctor_consultations|financial_billing)$")
    level: str = Field(..., pattern="^(none|view_only|full_management)$")


class PermissionsUpdateRequest(BaseModel):
    permissions: List[PermissionItem]

