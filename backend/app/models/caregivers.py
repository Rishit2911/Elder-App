import uuid
from datetime import date, datetime, timezone
from typing import Optional
from sqlalchemy import Boolean, Date, DECIMAL, DateTime, ForeignKey, Integer, JSON, String, Text, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, TimestampMixin, UUIDMixin


class Service(Base, UUIDMixin):
    __tablename__ = "services"

    title: Mapped[str] = mapped_column(String(150), nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    base_hourly_rate: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    icon_key: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class Agency(Base, UUIDMixin):
    __tablename__ = "agencies"

    name: Mapped[str] = mapped_column(String(200), nullable=False)
    registration_number: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    contact_email: Mapped[str] = mapped_column(String(255), nullable=False)
    contact_phone: Mapped[str] = mapped_column(String(20), nullable=False)
    address: Mapped[str] = mapped_column(Text, nullable=False)
    city: Mapped[str] = mapped_column(String(100), index=True, nullable=False)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    rating_average: Mapped[float] = mapped_column(DECIMAL(3, 2), default=4.80, nullable=False)
    total_caregivers: Mapped[int] = mapped_column(Integer, default=15, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)


class CaregiverQualification(Base, UUIDMixin):
    __tablename__ = "caregiver_qualifications"

    caregiver_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("caregiver_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    qualification_title: Mapped[str] = mapped_column(String(200), nullable=False)
    institution: Mapped[str] = mapped_column(String(200), nullable=False)
    year_completed: Mapped[int] = mapped_column(Integer, nullable=False)
    certificate_s3_key: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)


class CaregiverVerificationDocument(Base, UUIDMixin):
    __tablename__ = "caregiver_verification_documents"

    caregiver_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("caregiver_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    document_type: Mapped[str] = mapped_column(String(50), nullable=False)
    document_number: Mapped[str] = mapped_column(String(100), nullable=False)
    document_s3_key: Mapped[str] = mapped_column(String(500), nullable=False)
    verification_status: Mapped[str] = mapped_column(String(30), default="pending", index=True, nullable=False)
    reviewed_by_admin_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    rejection_reason: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    reviewed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)


class CaregiverAvailability(Base, UUIDMixin):
    __tablename__ = "caregiver_availability"

    caregiver_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("caregiver_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    day_of_week: Mapped[int] = mapped_column(Integer, nullable=False)
    start_time: Mapped[datetime] = mapped_column(Time, nullable=False)
    end_time: Mapped[datetime] = mapped_column(Time, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class Booking(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "bookings"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="RESTRICT"), index=True, nullable=False)
    booked_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    caregiver_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("caregiver_profiles.id", ondelete="RESTRICT"), index=True, nullable=False)
    service_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("services.id", ondelete="RESTRICT"), nullable=False)
    booking_type: Mapped[str] = mapped_column(String(30), nullable=False)
    start_datetime: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True, nullable=False)
    end_datetime: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    special_instructions: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    total_hours: Mapped[float] = mapped_column(DECIMAL(5, 2), nullable=False)
    hourly_rate_agreed: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    total_amount: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    payment_status: Mapped[str] = mapped_column(String(30), default="unpaid", nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="requested", index=True, nullable=False)

    visit_report = relationship("CaregiverVisitReport", back_populates="booking", uselist=False)


class BookingStatusHistory(Base, UUIDMixin):
    __tablename__ = "booking_status_history"

    booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("bookings.id", ondelete="CASCADE"), index=True, nullable=False)
    previous_status: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    new_status: Mapped[str] = mapped_column(String(30), nullable=False)
    changed_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    reason_or_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)


class CaregiverVisitReport(Base, UUIDMixin):
    __tablename__ = "caregiver_visit_reports"

    booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("bookings.id", ondelete="CASCADE"), unique=True, nullable=False)
    caregiver_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("caregiver_profiles.id", ondelete="RESTRICT"), nullable=False)
    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="RESTRICT"), nullable=False)
    check_in_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    check_out_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    check_in_latitude: Mapped[Optional[float]] = mapped_column(DECIMAL(10, 8), nullable=True)
    check_in_longitude: Mapped[Optional[float]] = mapped_column(DECIMAL(11, 8), nullable=True)
    activities_performed: Mapped[dict] = mapped_column(JSON, nullable=False)
    vital_blood_pressure: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    vital_pulse: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    vital_sugar: Mapped[Optional[float]] = mapped_column(DECIMAL(5, 1), nullable=True)
    mood_observation: Mapped[str] = mapped_column(String(50), nullable=False)
    caregiver_notes: Mapped[str] = mapped_column(Text, nullable=False)
    report_photo_s3_key: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    booking = relationship("Booking", back_populates="visit_report")
