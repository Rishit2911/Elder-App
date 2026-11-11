import uuid
from datetime import datetime, timezone
from typing import Any, Dict, Optional
from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.payments import AuditLog
from app.models.users import FamilyProfile, SeniorProfile, User, UserConsent
from app.schemas.user import UserDetailResponse, UserProfileUpdate


class UserService:
    """
    Manages user profile queries, selective profile updates, and consent records.
    Prevents mass assignment and IDOR vulnerabilities.
    """

    @staticmethod
    async def get_user_with_profiles(db: AsyncSession, user_id: uuid.UUID) -> Optional[User]:
        """Fetch user with all associated profiles preloaded."""
        stmt = (
            select(User)
            .where(User.id == user_id)
            .options(
                selectinload(User.senior_profile),
                selectinload(User.family_profile),
                selectinload(User.caregiver_profile),
                selectinload(User.doctor_profile),
            )
        )
        result = await db.execute(stmt)
        return result.scalars().first()

    @classmethod
    async def get_user_detail(cls, db: AsyncSession, user_id: uuid.UUID) -> UserDetailResponse:
        """Construct full user detail response with role-specific profile data."""
        user = await cls.get_user_with_profiles(db, user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        full_name = user.phone_number
        profile_data: Dict[str, Any] = {}

        if user.role == "senior" and user.senior_profile:
            full_name = user.senior_profile.full_name
            profile_data = {
                "preferredName": user.senior_profile.preferred_name,
                "dateOfBirth": user.senior_profile.date_of_birth.isoformat() if user.senior_profile.date_of_birth else None,
                "gender": user.senior_profile.gender,
                "bloodGroup": user.senior_profile.blood_group,
                "address": user.senior_profile.address,
                "city": user.senior_profile.city,
                "postalCode": user.senior_profile.postal_code,
                "primaryLanguage": user.senior_profile.primary_language,
                "profilePictureUrl": user.senior_profile.profile_picture_url
            }
        elif user.role == "family" and user.family_profile:
            full_name = user.family_profile.full_name
            profile_data = {
                "relationship": user.family_profile.relationship_description,
                "alternatePhone": user.family_profile.alternate_phone
            }
        elif user.role == "caregiver" and user.caregiver_profile:
            full_name = user.caregiver_profile.full_name
            profile_data = {
                "hourlyRate": float(user.caregiver_profile.hourly_rate),
                "rating": float(user.caregiver_profile.rating_average),
                "isAvailable": user.caregiver_profile.is_available_for_hire
            }

        return UserDetailResponse(
            id=user.id,
            fullName=full_name,
            email=user.email,
            phoneNumber=user.phone_number,
            role=user.role,
            isActive=user.is_active,
            isVerified=user.is_verified,
            createdAt=user.created_at,
            profile=profile_data
        )

    @classmethod
    async def update_profile(
        cls,
        db: AsyncSession,
        user_id: uuid.UUID,
        payload: UserProfileUpdate
    ) -> UserDetailResponse:
        """Selectively update allowed fields without mass-assignment vulnerabilities."""
        user = await cls.get_user_with_profiles(db, user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Update core user fields
        if payload.email is not None:
            user.email = payload.email

        # Update role-specific profile fields
        if user.role == "senior" and user.senior_profile:
            if payload.full_name is not None:
                user.senior_profile.full_name = payload.full_name
            if payload.preferred_name is not None:
                user.senior_profile.preferred_name = payload.preferred_name
            if payload.address is not None:
                user.senior_profile.address = payload.address
            if payload.city is not None:
                user.senior_profile.city = payload.city
            if payload.postal_code is not None:
                user.senior_profile.postal_code = payload.postal_code
            if payload.primary_language is not None:
                user.senior_profile.primary_language = payload.primary_language
            if payload.profile_picture_url is not None:
                user.senior_profile.profile_picture_url = payload.profile_picture_url
        elif user.role == "family" and user.family_profile:
            if payload.full_name is not None:
                user.family_profile.full_name = payload.full_name
            if payload.alternate_phone is not None:
                user.family_profile.alternate_phone = payload.alternate_phone

        audit = AuditLog(
            actor_user_id=user.id,
            target_entity_type="user",
            target_entity_id=user.id,
            action="UPDATE_PROFILE"
        )
        db.add(audit)

        await db.commit()
        await db.refresh(user)
        return await cls.get_user_detail(db, user.id)

    @staticmethod
    async def record_consent(
        db: AsyncSession,
        user_id: uuid.UUID,
        consent_type: str,
        consent_version: str = "1.0",
        is_granted: bool = True
    ) -> UserConsent:
        """Record explicit informed consent in user_consents table."""
        consent = UserConsent(
            user_id=user_id,
            consent_type=consent_type,
            consent_version=consent_version,
            is_granted=is_granted,
            granted_at=datetime.now(timezone.utc)
        )
        db.add(consent)
        await db.commit()
        await db.refresh(consent)
        return consent

    @staticmethod
    async def has_active_consent(
        db: AsyncSession,
        user_id: uuid.UUID,
        consent_type: str
    ) -> bool:
        """Check whether user has an active, unwithdrawn consent."""
        stmt = (
            select(UserConsent)
            .where(
                UserConsent.user_id == user_id,
                UserConsent.consent_type == consent_type,
                UserConsent.is_granted == True,
                UserConsent.withdrawn_at == None
            )
        )
        result = await db.execute(stmt)
        return result.scalars().first() is not None

