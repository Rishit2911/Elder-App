import uuid
from datetime import datetime
from typing import Optional
from sqlalchemy import DECIMAL, DateTime, ForeignKey, Integer, JSON, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base, UUIDMixin


class SosEvent(Base, UUIDMixin):
    __tablename__ = "sos_events"

    senior_id: Mapped[str] = mapped_column(String(36), ForeignKey("senior_profiles.id", ondelete="RESTRICT"), index=True, nullable=False)
    triggered_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True, nullable=False)
    trigger_source: Mapped[str] = mapped_column(String(30), nullable=False)  # in_app_button, voice_assistant_keyword
    latitude: Mapped[float] = mapped_column(DECIMAL(10, 8), nullable=False)
    longitude: Mapped[float] = mapped_column(DECIMAL(11, 8), nullable=False)
    approximate_address: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    battery_level_percent: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    status: Mapped[str] = mapped_column(String(30), default="active", index=True, nullable=False)  # active, acknowledged, resolved, false_alarm
    acknowledged_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    resolved_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    resolved_by_user_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("users.id", ondelete="RESTRICT"), nullable=True)
    resolution_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    broadcast_payload: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)


# Backward compatibility alias
SOSEvent = SosEvent


class EmergencyContact(Base, UUIDMixin):
    __tablename__ = "emergency_contacts"

    senior_id: Mapped[str] = mapped_column(String(36), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    contact_name: Mapped[str] = mapped_column(String(150), nullable=False)
    relation: Mapped[str] = mapped_column(String(50), nullable=False)
    phone_number: Mapped[str] = mapped_column(String(20), nullable=False)
    is_primary: Mapped[bool] = mapped_column(__import__('sqlalchemy').Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
