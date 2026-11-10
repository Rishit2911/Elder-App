import uuid
from datetime import date, datetime, time
from typing import List, Optional
from sqlalchemy import ARRAY, Boolean, Date, DECIMAL, ForeignKey, Integer, String, Text, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, TimestampMixin, UUIDMixin


class HealthRecord(Base, UUIDMixin):
    __tablename__ = "health_records"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    record_type: Mapped[str] = mapped_column(String(50), nullable=False)  # vitals, lab_test, doctor_summary, discharge_summary
    recorded_at: Mapped[datetime] = mapped_column(index=True, nullable=False)
    recorded_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    
    # Vital measurements
    vital_bp_systolic: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    vital_bp_diastolic: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    vital_heart_rate: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    vital_blood_glucose: Mapped[Optional[float]] = mapped_column(DECIMAL(5, 1), nullable=True)
    vital_oxygen_saturation: Mapped[Optional[float]] = mapped_column(DECIMAL(4, 1), nullable=True)
    vital_temperature: Mapped[Optional[float]] = mapped_column(DECIMAL(4, 1), nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Document attachment
    document_s3_key: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    document_file_hash: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    document_mime_type: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)


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
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)

    medicines = relationship("Medicine", back_populates="prescription")


class Medicine(Base, UUIDMixin):
    __tablename__ = "medicines"

    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    prescription_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("prescriptions.id", ondelete="SET NULL"), nullable=True)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    dosage_strength: Mapped[str] = mapped_column(String(50), nullable=False)  # e.g., "500mg"
    form: Mapped[str] = mapped_column(String(30), nullable=False)  # tablet, capsule, syrup, injection
    meal_relation: Mapped[str] = mapped_column(String(30), nullable=False)  # before_meal, after_meal, with_meal
    color_code: Mapped[Optional[str]] = mapped_column(String(10), nullable=True)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    instructions: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, index=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)

    prescription = relationship("Prescription", back_populates="medicines")
    schedules = relationship("MedicineSchedule", back_populates="medicine", cascade="all, delete-orphan")


class MedicineSchedule(Base, UUIDMixin):
    __tablename__ = "medicine_schedules"

    medicine_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("medicines.id", ondelete="CASCADE"), index=True, nullable=False)
    time_of_day: Mapped[time] = mapped_column(Time, index=True, nullable=False)
    days_of_week: Mapped[Optional[List[int]]] = mapped_column(ARRAY(Integer), nullable=True)
    dose_quantity: Mapped[float] = mapped_column(DECIMAL(3, 1), default=1.0, nullable=False)
    reminder_lead_minutes: Mapped[int] = mapped_column(Integer, default=10, nullable=False)

    medicine = relationship("Medicine", back_populates="schedules")
    logs = relationship("MedicineLog", back_populates="schedule", cascade="all, delete-orphan")


class MedicineLog(Base, UUIDMixin):
    __tablename__ = "medicine_logs"

    schedule_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("medicine_schedules.id", ondelete="CASCADE"), index=True, nullable=False)
    senior_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("senior_profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    scheduled_timestamp: Mapped[datetime] = mapped_column(index=True, nullable=False)
    status: Mapped[str] = mapped_column(String(30), index=True, nullable=False)  # taken, missed, skipped, snoozed
    logged_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, nullable=False)
    acknowledged_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    schedule = relationship("MedicineSchedule", back_populates="logs")

