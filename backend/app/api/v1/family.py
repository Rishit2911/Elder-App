import uuid
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user_payload
from app.database.connection import get_db
from app.schemas.family import (
    FamilyInvitationCreate, InvitationAcceptRequest, PermissionsUpdateRequest
)

router = APIRouter(prefix="/family", tags=["Family Connections"])


@router.post("/invitations", status_code=status.HTTP_201_CREATED)
async def create_invitation(
    payload: FamilyInvitationCreate,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Senior sends an invitation to link a family member into their care circle.
    """
    code = f"INV-{uuid.uuid4().hex[:6].upper()}"
    return {
        "invitation_code": code,
        "invitee_phone": payload.invitee_phone,
        "relation_proposed": payload.relation_proposed,
        "expires_at": datetime.now(timezone.utc) + timedelta(days=2),
        "status": "pending"
    }


@router.post("/invitations/accept")
async def accept_invitation(
    payload: InvitationAcceptRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Family member inputs code to accept invitation and establish verified connection.
    """
    return {
        "status": "active",
        "relationship_id": uuid.uuid4(),
        "senior_name": "दादाजी Ramesh Sharma",
        "message": "Connection established successfully. You are now part of Dadaji's care circle."
    }


@router.get("/seniors")
async def get_connected_seniors(
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve all senior citizen dependents connected to this family account.
    """
    return {
        "seniors": [
            {
                "id": "00000000-0000-0000-0000-000000000001",
                "name": "दादाजी Ramesh Sharma",
                "relation": "Father",
                "city": "Jaipur",
                "recent_bp": "120/80",
                "status": "Healthy"
            }
        ]
    }


@router.put("/relationships/{relationship_id}/permissions")
async def update_permissions(
    relationship_id: uuid.UUID,
    payload: PermissionsUpdateRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Senior updates fine-grained ReBAC access permissions for a connected family member.
    """
    return {
        "relationship_id": relationship_id,
        "updated_permissions": [p.dict() for p in payload.permissions],
        "message": "Access permissions updated successfully."
    }


@router.get("/updates/moments")
async def get_family_moments(
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Photo and message timeline feed for the "My Family" screen.
    """
    return {
        "moments": [
            {
                "id": "moment-uuid-1",
                "author": "Priya (Daughter)",
                "caption": "Good morning Dadaji! Hope you had your morning tea and walk.",
                "created_at": "2026-11-06T07:30:00Z"
            }
        ]
    }

