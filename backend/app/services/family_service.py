import secrets
import string
import uuid
from datetime import datetime, timedelta, timezone
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.family import AccessPermission, FamilyInvitation, FamilyRelationship
from app.models.payments import AuditLog
from app.models.users import SeniorProfile, User
from app.schemas.family import (
    FamilyInvitationCreate, FamilyLinkApproval,
    FamilyLinkItem, PermissionsUpdateRequest
)


class FamilyService:
    """
    Manages cryptographic family invitation tokens, approval workflows,
    granular ReBAC access permissions, and connection lifecycles.
    """

    @staticmethod
    def _generate_invitation_code() -> str:
        """Generate a cryptographically secure 8-character invitation code."""
        chars = string.ascii_uppercase + string.digits
        return "SC-" + "".join(secrets.choice(chars) for _ in range(6))

    @classmethod
    async def create_invitation(
        cls,
        db: AsyncSession,
        inviter_user: User,
        payload: FamilyInvitationCreate
    ) -> FamilyInvitation:
        """Create an invitation link or code to connect a family member with a senior."""
        clean_phone = payload.target_phone.strip()

        # Determine Senior profile
        if inviter_user.role == "senior":
            senior_stmt = select(SeniorProfile).where(SeniorProfile.user_id == inviter_user.id)
            senior = (await db.execute(senior_stmt)).scalars().first()
            if not senior:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Senior profile not initialized"
                )
        else:
            # Family member inviting a senior by phone
            senior_stmt = (
                select(SeniorProfile)
                .join(User, SeniorProfile.user_id == User.id)
                .where(User.phone_number == clean_phone)
            )
            senior = (await db.execute(senior_stmt)).scalars().first()
            if not senior:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="No senior citizen account found with this phone number"
                )

        # Check for existing active relationship
        if inviter_user.role == "family":
            rel_stmt = select(FamilyRelationship).where(
                FamilyRelationship.senior_id == senior.id,
                FamilyRelationship.family_user_id == inviter_user.id,
                FamilyRelationship.status == "active"
            )
            existing_rel = (await db.execute(rel_stmt)).scalars().first()
            if existing_rel:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="An active family relationship already exists between these accounts"
                )

        invitation_code = cls._generate_invitation_code()
        expires_at = datetime.now(timezone.utc) + timedelta(days=7)

        invitation = FamilyInvitation(
            senior_id=senior.id,
            inviter_user_id=inviter_user.id,
            invitee_phone=clean_phone,
            invitee_email=payload.invitee_email,
            invitation_code=invitation_code,
            relation_proposed=payload.relationship,
            status="pending",
            expires_at=expires_at
        )
        db.add(invitation)

        audit = AuditLog(
            actor_user_id=inviter_user.id,
            target_entity_type="family_invitation",
            target_entity_id=inviter_user.id,
            action="CREATE_INVITATION",
            details_json={"code": invitation_code, "target_phone": clean_phone}
        )
        db.add(audit)

        await db.commit()
        await db.refresh(invitation)
        return invitation

    @classmethod
    async def approve_invitation(
        cls,
        db: AsyncSession,
        approver_user: User,
        payload: FamilyLinkApproval
    ) -> FamilyRelationship:
        """Approve or reject a family connection invitation."""
        stmt = select(FamilyInvitation).where(FamilyInvitation.id == payload.invitation_id)
        invitation = (await db.execute(stmt)).scalars().first()

        if not invitation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Invitation not found"
            )

        now = datetime.now(timezone.utc)
        if invitation.status != "pending" or invitation.expires_at < now:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This invitation is no longer valid or has expired"
            )

        # Verify approver is the senior of this invitation
        senior_stmt = select(SeniorProfile).where(SeniorProfile.user_id == approver_user.id)
        senior = (await db.execute(senior_stmt)).scalars().first()
        if not senior or senior.id != invitation.senior_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the invited senior citizen can approve this relationship"
            )

        if not payload.approved:
            invitation.status = "rejected"
            await db.commit()
            raise HTTPException(
                status_code=status.HTTP_200_OK,
                detail="Invitation was rejected"
            )

        # Create or update active relationship
        rel_stmt = select(FamilyRelationship).where(
            FamilyRelationship.senior_id == invitation.senior_id,
            FamilyRelationship.family_user_id == invitation.inviter_user_id
        )
        relationship = (await db.execute(rel_stmt)).scalars().first()

        if not relationship:
            relationship = FamilyRelationship(
                senior_id=invitation.senior_id,
                family_user_id=invitation.inviter_user_id,
                relation_type=invitation.relation_proposed,
                is_primary_caregiver_contact=True,
                is_emergency_contact=True,
                status="active"
            )
            db.add(relationship)
            await db.flush()
        else:
            relationship.status = "active"

        # Create or update access permissions
        modules = ["health_records", "medicines", "caregiver_bookings"]
        for mod in modules:
            p_stmt = select(AccessPermission).where(
                AccessPermission.relationship_id == relationship.id,
                AccessPermission.permission_module == mod
            )
            p = (await db.execute(p_stmt)).scalars().first()
            if not p:
                p = AccessPermission(
                    relationship_id=relationship.id,
                    permission_module=mod,
                    access_level="full_management"
                )
                db.add(p)

        invitation.status = "accepted"

        audit = AuditLog(
            actor_user_id=approver_user.id,
            target_entity_type="family_relationship",
            target_entity_id=relationship.id,
            action="APPROVE_RELATIONSHIP"
        )
        db.add(audit)

        await db.commit()
        await db.refresh(relationship)
        return relationship

    @classmethod
    async def list_links(cls, db: AsyncSession, user: User) -> List[FamilyLinkItem]:
        """List active family connections for either senior or family member."""
        if user.role == "senior":
            senior_stmt = select(SeniorProfile).where(SeniorProfile.user_id == user.id)
            senior = (await db.execute(senior_stmt)).scalars().first()
            if not senior:
                return []
            stmt = (
                select(FamilyRelationship)
                .where(FamilyRelationship.senior_id == senior.id, FamilyRelationship.status == "active")
                .options(selectinload(FamilyRelationship.permissions))
            )
        else:
            stmt = (
                select(FamilyRelationship)
                .where(FamilyRelationship.family_user_id == user.id, FamilyRelationship.status == "active")
                .options(selectinload(FamilyRelationship.permissions))
            )

        relationships = (await db.execute(stmt)).scalars().all()
        items = []

        for rel in relationships:
            senior_p = await db.get(SeniorProfile, rel.senior_id)
            family_u = await db.get(User, rel.family_user_id)
            family_p_stmt = select(SeniorProfile).where(SeniorProfile.user_id == rel.family_user_id)

            items.append(
                FamilyLinkItem(
                    id=rel.id,
                    seniorId=rel.senior_id,
                    seniorName=senior_p.full_name if senior_p else "Senior",
                    familyUserId=rel.family_user_id,
                    familyName=family_u.email or family_u.phone_number if family_u else "Family Member",
                    relationship=rel.relation_type,
                    status=rel.status,
                    isEmergencyContact=rel.is_emergency_contact,
                    isPrimaryCaregiverContact=rel.is_primary_caregiver_contact,
                    canManageMedications=True,
                    canViewRecords=True,
                    canBookServices=True,
                    createdAt=rel.created_at
                )
            )
        return items

    @classmethod
    async def update_permissions(
        cls,
        db: AsyncSession,
        senior_user: User,
        relationship_id: uuid.UUID,
        payload: PermissionsUpdateRequest
    ) -> FamilyRelationship:
        """Update permissions on a family connection."""
        senior_stmt = select(SeniorProfile).where(SeniorProfile.user_id == senior_user.id)
        senior = (await db.execute(senior_stmt)).scalars().first()
        if not senior:
            raise HTTPException(status_code=403, detail="Senior profile not found")

        rel = await db.get(FamilyRelationship, relationship_id)
        if not rel or rel.senior_id != senior.id:
            raise HTTPException(status_code=403, detail="Unauthorized access to relationship")

        if payload.is_emergency_contact is not None:
            rel.is_emergency_contact = payload.is_emergency_contact
        if payload.is_primary_caregiver_contact is not None:
            rel.is_primary_caregiver_contact = payload.is_primary_caregiver_contact

        await db.commit()
        await db.refresh(rel)
        return rel

    @classmethod
    async def revoke_link(
        cls,
        db: AsyncSession,
        user: User,
        relationship_id: uuid.UUID
    ) -> None:
        """Revoke a family relationship link."""
        rel = await db.get(FamilyRelationship, relationship_id)
        if not rel:
            raise HTTPException(status_code=404, detail="Relationship not found")

        # Either the senior or the connected family member can revoke
        senior_stmt = select(SeniorProfile).where(SeniorProfile.user_id == user.id)
        senior = (await db.execute(senior_stmt)).scalars().first()
        is_senior = senior and rel.senior_id == senior.id
        is_family = rel.family_user_id == user.id

        if not (is_senior or is_family or user.role == "admin"):
            raise HTTPException(status_code=403, detail="Unauthorized to revoke this relationship")

        rel.status = "revoked"

        audit = AuditLog(
            actor_user_id=user.id,
            target_entity_type="family_relationship",
            target_entity_id=rel.id,
            action="REVOKE_RELATIONSHIP"
        )
        db.add(audit)
        await db.commit()
