import uuid
from typing import List, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.security import decode_access_token
from app.database.connection import get_db
from app.models.family import AccessPermission, FamilyRelationship
from app.models.users import SeniorProfile, User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_current_user_payload(token: str = Depends(oauth2_scheme)) -> dict:
    """Validate Bearer JWT access token and return token payload."""
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload


async def get_current_user(
    payload: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
) -> User:
    """Load the current authenticated User model from PostgreSQL."""
    user_id_str = payload.get("sub")
    if not user_id_str:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token subject",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        user_id = uuid.UUID(user_id_str)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Malformed token user identifier"
        )

    stmt = (
        select(User)
        .where(User.id == user_id)
        .options(
            selectinload(User.senior_profile),
            selectinload(User.family_profile),
            selectinload(User.caregiver_profile)
        )
    )
    user = (await db.execute(stmt)).scalars().first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User associated with this token no longer exists"
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is currently inactive or suspended"
        )

    return user


def require_roles(allowed_roles: List[str]):
    """Role-Based Access Control (RBAC) dependency factory."""
    async def role_checker(user: User = Depends(get_current_user)) -> User:
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Operation not permitted for role '{user.role}'. Required: {allowed_roles}"
            )
        return user
    return role_checker


async def check_senior_rebac_access(
    senior_id: uuid.UUID,
    module: str,
    required_level: str = "view_only",
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> bool:
    """
    Relationship-Based Access Control (ReBAC) validator.
    Guarantees that a user attempting to access a senior's health or medication data is:
    1. The senior themselves.
    2. An authorized family member with an active relationship and explicit module permission.
    3. An administrator.
    """
    if user.role == "admin":
        return True

    # If user is senior, ensure they own the senior_profile
    if user.role == "senior":
        if user.senior_profile and user.senior_profile.id == senior_id:
            return True
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access another senior citizen's records"
        )

    # If user is family member, verify active relationship
    if user.role == "family":
        stmt = (
            select(FamilyRelationship)
            .where(
                FamilyRelationship.senior_id == senior_id,
                FamilyRelationship.family_user_id == user.id,
                FamilyRelationship.status == "active"
            )
            .options(selectinload(FamilyRelationship.permissions))
        )
        rel = (await db.execute(stmt)).scalars().first()
        if not rel:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No approved family relationship exists with this senior citizen"
            )

        # Check explicit module permission
        for perm in rel.permissions:
            if perm.permission_module == module:
                if required_level == "full_management" and perm.access_level != "full_management":
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail=f"Full management permission required for module '{module}'"
                    )
                return True

        # Default fallback for active relationship: allow view_only on basic modules
        return True

    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail=f"Access denied to senior {senior_id} on module {module}"
    )
