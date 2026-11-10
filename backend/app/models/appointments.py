import uuid
from datetime import date, datetime
from typing import Optional
from sqlalchemy import Date, DECIMAL, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base, TimestampMixin, UUIDMixin


class DoctorAppointment(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "doctor_appointments"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="RESTRICT"), index=True, nullable=False)
    doctor_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("doctor_profiles.id", ondelete="RESTRICT"), index=True, nullable=False)
    booked_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    scheduled_time: Mapped[datetime] = mapped_column(index=True, nullable=False)
    appointment_type: Mapped[str] = mapped_column(String(30), nullable=False)  # video_consult, clinic_visit, home_visit
    status: Mapped[str] = mapped_column(String(30), default="scheduled", index=True, nullable=False)  # scheduled, completed, cancelled, no_show
    reason_for_consultation: Mapped[str] = mapped_column(Text, nullable=False)
    video_room_id: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    doctor_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    fee_amount: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    payment_status: Mapped[str] = mapped_column(String(30), default="pending", nullable=False)


class LabBooking(Base, UUIDMixin):
    __tablename__ = "lab_bookings"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="RESTRICT"), index=True, nullable=False)
    booked_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    lab_provider_name: Mapped[str] = mapped_column(String(150), nullable=False)
    test_package_name: Mapped[str] = mapped_column(String(200), nullable=False)
    scheduled_date: Mapped[date] = mapped_column(Date, nullable=False)
    collection_type: Mapped[str] = mapped_column(String(30), nullable=False)  # home_sample_collection, diagnostic_center_visit
    status: Mapped[str] = mapped_column(String(30), default="booked", nullable=False)
    total_cost: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    report_s3_key: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)

