import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user
from app.database.connection import get_db
from app.models.family import FamilyRelationship
from app.models.users import User
from app.schemas.auth import StandardResponse
from app.schemas.user import UserDetailResponse, UserProfileUpdate
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["User Profiles & Management"])


@router.get("/me", response_model=StandardResponse)
async def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve profile details for the currently authenticated user.
    """
    detail = await UserService.get_user_detail(db, current_user.id)
    return StandardResponse(
        success=True,
        message="Profile retrieved successfully",
        data=detail.model_dump(by_alias=True)
    )


@router.patch("/me", response_model=StandardResponse)
async def update_my_profile(
    payload: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update permitted personal profile fields for the authenticated user.
    Prevents mass-assignment of restricted security fields (role, passwords, statuses).
    """
    updated = await UserService.update_profile(db, current_user.id, payload)
    return StandardResponse(
        success=True,
        message="Profile updated successfully",
        data=updated.model_dump(by_alias=True)
    )


@router.get("/{user_id}", response_model=StandardResponse)
async def get_user_profile(
    user_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve user details by ID with IDOR protection.
    A user can view their own profile, an administrator can view any profile,
    and a family member can view an authorized connected senior.
    """
    if current_user.id == user_id or current_user.role == "admin":
        detail = await UserService.get_user_detail(db, user_id)
        return StandardResponse(
            success=True,
            message="User retrieved successfully",
            data=detail.model_dump(by_alias=True)
        )

    # Check if there is an active relationship
    target_user = await UserService.get_user_with_profiles(db, user_id)
    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")

    if current_user.role == "family" and target_user.role == "senior":
        # Check active family relationship
        if target_user.senior_profile:
            senior_id = target_user.senior_profile.id
            rel_stmt = select(FamilyRelationship).where(
                FamilyRelationship.senior_id == senior_id,
                FamilyRelationship.family_user_id == current_user.id,
                FamilyRelationship.status == "active"
            )
            rel = (await db.execute(rel_stmt)).scalars().first()
            if rel:
                detail = await UserService.get_user_detail(db, user_id)
                return StandardResponse(
                    success=True,
                    message="Connected senior profile retrieved",
                    data=detail.model_dump(by_alias=True)
                )

    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="You are not authorized to view this user profile"
    )

