import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user
from app.database.connection import get_db
from app.models.family import FamilyRelationship
from app.models.users import User
from app.schemas.auth import StandardResponse
from app.schemas.family import (
    FamilyInvitationCreate, FamilyLinkApproval,
    FamilyLinkItem, PermissionsUpdateRequest
)
from app.services.family_service import FamilyService

router = APIRouter(prefix="/family", tags=["Family Connections & Linking"])


@router.post("/link/request", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
@router.post("/invite", response_model=StandardResponse, status_code=status.HTTP_201_CREATED)
async def request_connection(
    payload: FamilyInvitationCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Request a connection between a family member and senior citizen.
    Generates a cryptographically random invitation code (SC-XXXXXX) valid for 7 days.
    """
    invitation = await FamilyService.create_invitation(db, current_user, payload)
    return StandardResponse(
        success=True,
        message="Family connection invitation created successfully",
        data={
            "invitationId": str(invitation.id),
            "invitationCode": invitation.invitation_code,
            "targetPhone": invitation.invitee_phone,
            "proposedRelationship": invitation.relation_proposed,
            "status": invitation.status,
            "expiresAt": invitation.expires_at.isoformat()
        }
    )


@router.post("/link/approve", response_model=StandardResponse)
async def approve_connection(
    payload: FamilyLinkApproval,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Approve or reject a family connection invitation.
    Only the invited senior citizen can approve the request.
    On approval, assigns verified ReBAC permissions.
    """
    relationship = await FamilyService.approve_invitation(db, current_user, payload)
    return StandardResponse(
        success=True,
        message="Family connection approved and permissions assigned",
        data={
            "relationshipId": str(relationship.id),
            "seniorId": str(relationship.senior_id),
            "familyUserId": str(relationship.family_user_id),
            "relationType": relationship.relation_type,
            "status": relationship.status
        }
    )


@router.get("/links", response_model=StandardResponse)
async def list_connections(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    List all active family links for the current user.
    If Senior: lists connected family members and their permissions.
    If Family: lists connected senior citizens.
    """
    links = await FamilyService.list_links(db, current_user)
    return StandardResponse(
        success=True,
        message="Family connections retrieved",
        data=[link.model_dump(by_alias=True) for link in links]
    )


@router.get("/links/{relationship_id}", response_model=StandardResponse)
async def get_connection_details(
    relationship_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve specific relationship link details with ownership verification.
    """
    rel = await db.get(FamilyRelationship, relationship_id)
    if not rel:
        raise HTTPException(status_code=404, detail="Relationship link not found")

    # Verify user is either the senior or the family member
    is_senior = current_user.senior_profile and current_user.senior_profile.id == rel.senior_id
    is_family = current_user.id == rel.family_user_id
    if not (is_senior or is_family or current_user.role == "admin"):
        raise HTTPException(status_code=403, detail="Unauthorized access to this relationship")

    return StandardResponse(
        success=True,
        message="Relationship details retrieved",
        data={
            "id": str(rel.id),
            "seniorId": str(rel.senior_id),
            "familyUserId": str(rel.family_user_id),
            "relationType": rel.relation_type,
            "status": rel.status,
            "isEmergencyContact": rel.is_emergency_contact,
            "isPrimaryCaregiverContact": rel.is_primary_caregiver_contact,
            "createdAt": rel.created_at.isoformat()
        }
    )


@router.patch("/links/{relationship_id}/permissions", response_model=StandardResponse)
async def update_permissions(
    relationship_id: uuid.UUID,
    payload: PermissionsUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update permissions and emergency priorities on an approved relationship.
    Only the senior citizen who owns the records can modify permissions.
    """
    rel = await FamilyService.update_permissions(db, current_user, relationship_id, payload)
    return StandardResponse(
        success=True,
        message="Permissions updated successfully",
        data={
            "relationshipId": str(rel.id),
            "isEmergencyContact": rel.is_emergency_contact,
            "isPrimaryCaregiverContact": rel.is_primary_caregiver_contact,
            "status": rel.status
        }
    )


@router.post("/links/{relationship_id}/revoke", response_model=StandardResponse)
async def revoke_connection(
    relationship_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Revoke a family connection link immediately.
    Can be executed by either the senior citizen or the connected family member.
    """
    await FamilyService.revoke_link(db, current_user, relationship_id)
    return StandardResponse(
        success=True,
        message="Family connection was successfully revoked"
    )
