import uuid
from datetime import datetime
from typing import Optional
from sqlalchemy import Boolean, DECIMAL, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base, UUIDMixin


class EmergencyContact(Base, UUIDMixin):
    __tablename__ = "emergency_contacts"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    contact_name: Mapped[str] = mapped_column(String(150), nullable=False)
    phone_number: Mapped[str] = mapped_column(String(20), nullable=False)
    relationship: Mapped[str] = mapped_column(String(50), nullable=False)
    priority_order: Mapped[int] = mapped_column(Integer, default=1, index=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


class SOSEvent(Base, UUIDMixin):
    __tablename__ = "sos_events"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="RESTRICT"), index=True, nullable=False)
    triggered_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, index=True, nullable=False)
    trigger_source: Mapped[str] = mapped_column(String(30), nullable=False)  # in_app_button, voice_assistant_keyword
    latitude: Mapped[float] = mapped_column(DECIMAL(10, 8), nullable=False)
    longitude: Mapped[float] = mapped_column(DECIMAL(11, 8), nullable=False)
    approximate_address: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    battery_level_percent: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    status: Mapped[str] = mapped_column(String(30), default="active", index=True, nullable=False)  # active, acknowledged, resolved, false_alarm
    acknowledged_at: Mapped[Optional[datetime]] = mapped_column(nullable=True)
    resolved_at: Mapped[Optional[datetime]] = mapped_column(nullable=True)
    resolved_by_user_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=True)
    resolution_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    broadcast_payload: Mapped[Optional[dict]] = mapped_column(JSONB, default={}, nullable=True)

