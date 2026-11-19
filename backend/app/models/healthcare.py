import uuid
from datetime import date, datetime, time, timezone
from typing import Optional
from sqlalchemy import Boolean, Date, DECIMAL, DateTime, ForeignKey, Integer, String, Text, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, TimestampMixin, UUIDMixin


class HealthRecord(Base, UUIDMixin):
    __tablename__ = "health_records"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    record_type: Mapped[str] = mapped_column(String(50), nullable=False)
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True, nullable=False)
    recorded_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    vital_bp_systolic: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    vital_bp_diastolic: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    vital_heart_rate: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    vital_blood_glucose: Mapped[Optional[float]] = mapped_column(DECIMAL(5, 1), nullable=True)
    vital_oxygen_saturation: Mapped[Optional[float]] = mapped_column(DECIMAL(4, 1), nullable=True)
    vital_temperature: Mapped[Optional[float]] = mapped_column(DECIMAL(4, 1), nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    document_s3_key: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    document_file_hash: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    document_mime_type: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)


class Prescription(Base, UUIDMixin):
    __tablename__ = "prescriptions"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    prescribing_doctor_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("doctor_profiles.id", ondelete="SET NULL"), nullable=True)
    prescribing_doctor_name: Mapped[Optional[str]] = mapped_column(String(150), nullable=True)
    diagnosis: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    issued_date: Mapped[date] = mapped_column(Date, nullable=False)
    valid_until: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    document_s3_key: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    medicines = relationship("Medicine", back_populates="prescription")


class Medicine(Base, UUIDMixin):
    __tablename__ = "medicines"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    prescription_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("prescriptions.id", ondelete="SET NULL"), nullable=True)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    dosage_strength: Mapped[str] = mapped_column(String(50), nullable=False)
    form: Mapped[str] = mapped_column(String(30), nullable=False)
    meal_relation: Mapped[str] = mapped_column(String(30), nullable=False)
    color_code: Mapped[Optional[str]] = mapped_column(String(10), nullable=True)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    instructions: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, index=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    prescription = relationship("Prescription", back_populates="medicines")
    schedules = relationship("MedicineSchedule", back_populates="medicine", cascade="all, delete-orphan")


class MedicineSchedule(Base, UUIDMixin):
    __tablename__ = "medicine_schedules"

    medicine_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("medicines.id", ondelete="CASCADE"), index=True, nullable=False)
    time_of_day: Mapped[time] = mapped_column(Time, nullable=False)
    dosage_quantity: Mapped[float] = mapped_column(DECIMAL(5, 2), default=1.0, nullable=False)
    days_of_week: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    medicine = relationship("Medicine", back_populates="schedules")
    intake_logs = relationship("MedicineIntakeLog", back_populates="schedule", cascade="all, delete-orphan")


class MedicineIntakeLog(Base, UUIDMixin):
    __tablename__ = "medicine_intake_logs"

    schedule_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("medicine_schedules.id", ondelete="CASCADE"), index=True, nullable=False)
    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    scheduled_datetime: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True, nullable=False)
    taken_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False)
    skipped_reason: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    logged_by_user_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    schedule = relationship("MedicineSchedule", back_populates="intake_logs")


# Backward compatibility alias
MedicineLog = MedicineIntakeLog


class DailyReminder(Base, UUIDMixin):
    __tablename__ = "daily_reminders"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    created_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    reminder_time: Mapped[time] = mapped_column(Time, nullable=False)
    reminder_type: Mapped[str] = mapped_column(String(30), nullable=False)
    days_active: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)


class HealthReading(Base, UUIDMixin):
    __tablename__ = "health_readings"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    reading_type: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    value_numeric: Mapped[float] = mapped_column(DECIMAL(7, 2), nullable=False)
    secondary_value_numeric: Mapped[Optional[float]] = mapped_column(DECIMAL(7, 2), nullable=True)
    unit: Mapped[str] = mapped_column(String(20), nullable=False)
    measured_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True, nullable=False)
    recorded_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    is_abnormal: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
