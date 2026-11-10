import uuid
from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import Boolean, DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, TimestampMixin, UUIDMixin


class FamilyRelationship(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "family_relationships"
    __table_args__ = (
        UniqueConstraint("senior_id", "family_user_id", name="uq_senior_family_link"),
    )

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    family_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    relation_type: Mapped[str] = mapped_column(String(50), nullable=False)  # son, daughter, spouse, grandchild, guardian
    is_primary_caregiver_contact: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_emergency_contact: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="active", nullable=False)  # active, paused, revoked

    permissions = relationship("AccessPermission", back_populates="relationship", cascade="all, delete-orphan")


class FamilyInvitation(Base, UUIDMixin):
    __tablename__ = "family_invitations"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), nullable=False)
    inviter_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    invitee_phone: Mapped[str] = mapped_column(String(20), index=True, nullable=False)
    invitee_email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    invitation_code: Mapped[str] = mapped_column(String(64), unique=True, index=True, nullable=False)
    relation_proposed: Mapped[str] = mapped_column(String(50), nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="pending", nullable=False)  # pending, accepted, rejected, expired
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)


class AccessPermission(Base, UUIDMixin):
    __tablename__ = "access_permissions"
    __table_args__ = (
        UniqueConstraint("relationship_id", "permission_module", name="uq_rel_permission_module"),
    )

    relationship_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("family_relationships.id", ondelete="CASCADE"), index=True, nullable=False)
    permission_module: Mapped[str] = mapped_column(String(50), nullable=False)  # health_records, medicines, live_location, caregiver_bookings
    access_level: Mapped[str] = mapped_column(String(20), nullable=False)  # none, view_only, full_management
    granted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    relationship = relationship("FamilyRelationship", back_populates="permissions")

