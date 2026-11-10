import uuid
from datetime import datetime, time
from typing import Optional
from sqlalchemy import Boolean, ForeignKey, Integer, String, Text, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, UUIDMixin


class FamilyUpdate(Base, UUIDMixin):
    __tablename__ = "family_updates"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    author_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    caption: Mapped[str] = mapped_column(Text, nullable=False)
    update_type: Mapped[str] = mapped_column(String(30), default="photo", nullable=False)  # photo, video, health_announcement
    is_pinned: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)

    attachments = relationship("UpdateAttachment", back_populates="update", cascade="all, delete-orphan")


class UpdateAttachment(Base, UUIDMixin):
    __tablename__ = "update_attachments"

    update_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("family_updates.id", ondelete="CASCADE"), index=True, nullable=False)
    attachment_s3_key: Mapped[str] = mapped_column(String(500), nullable=False)
    file_mime_type: Mapped[str] = mapped_column(String(50), nullable=False)
    file_size_bytes: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)

    update = relationship("FamilyUpdate", back_populates="attachments")


class Notification(Base, UUIDMixin):
    __tablename__ = "notifications"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)  # medicine_reminder, sos_emergency, caregiver_update
    deep_link_screen: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    reference_entity_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), nullable=True)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False, index=True, nullable=False)
    sent_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)
    read_at: Mapped[Optional[datetime]] = mapped_column(nullable=True)


class NotificationPreference(Base, UUIDMixin):
    __tablename__ = "notification_preferences"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    push_enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    sms_enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    whatsapp_enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    email_enabled: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    quiet_hours_enabled: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    quiet_hours_start: Mapped[Optional[time]] = mapped_column(Time, nullable=True)
    quiet_hours_end: Mapped[Optional[time]] = mapped_column(Time, nullable=True)

