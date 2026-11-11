import uuid
from datetime import date, datetime, timezone
from typing import Optional
from sqlalchemy import Boolean, Date, DateTime, DECIMAL, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, TimestampMixin, UUIDMixin


class User(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "users"

    phone_number: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(255), unique=True, index=True, nullable=True)
    hashed_password: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    role: Mapped[str] = mapped_column(String(30), index=True, nullable=False)  # senior, family, caregiver, doctor, admin
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    # Relationships with eager selectin loading for async IO safety
    senior_profile = relationship("SeniorProfile", back_populates="user", uselist=False, cascade="all, delete-orphan", lazy="selectin")
    family_profile = relationship("FamilyProfile", back_populates="user", uselist=False, cascade="all, delete-orphan", lazy="selectin")
    caregiver_profile = relationship("CaregiverProfile", back_populates="user", uselist=False, cascade="all, delete-orphan", lazy="selectin")
    doctor_profile = relationship("DoctorProfile", back_populates="user", uselist=False, cascade="all, delete-orphan", lazy="selectin")
    consents = relationship("UserConsent", back_populates="user", cascade="all, delete-orphan", lazy="selectin")


class UserConsent(Base, UUIDMixin):
    __tablename__ = "user_consents"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    consent_type: Mapped[str] = mapped_column(String(50), nullable=False)  # biometric_face_auth, health_data_sharing
    consent_version: Mapped[str] = mapped_column(String(20), default="1.0", nullable=False)
    is_granted: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    granted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    withdrawn_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    user = relationship("User", back_populates="consents")


class SeniorProfile(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "senior_profiles"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    preferred_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)  # e.g., "दादाजी"
    date_of_birth: Mapped[date] = mapped_column(Date, nullable=False)
    gender: Mapped[str] = mapped_column(String(20), nullable=False)
    blood_group: Mapped[Optional[str]] = mapped_column(String(5), nullable=True)
    address: Mapped[str] = mapped_column(Text, nullable=False)
    city: Mapped[str] = mapped_column(String(100), index=True, nullable=False)
    postal_code: Mapped[str] = mapped_column(String(20), nullable=False)
    latitude: Mapped[Optional[float]] = mapped_column(DECIMAL(10, 8), nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(DECIMAL(11, 8), nullable=True)
    primary_language: Mapped[str] = mapped_column(String(20), default="hi", nullable=False)
    emergency_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    profile_picture_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)

    user = relationship("User", back_populates="senior_profile")


class FamilyProfile(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "family_profiles"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    alternate_phone: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    relationship_description: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)

    user = relationship("User", back_populates="family_profile")


class CaregiverProfile(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "caregiver_profiles"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    gender: Mapped[str] = mapped_column(String(20), nullable=False)
    bio: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    experience_years: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    hourly_rate: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    daily_rate: Mapped[Optional[float]] = mapped_column(DECIMAL(10, 2), nullable=True)
    verification_status: Mapped[str] = mapped_column(String(30), default="pending", index=True, nullable=False)
    police_clearance_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    medical_training_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    rating_average: Mapped[float] = mapped_column(DECIMAL(3, 2), default=0.0, nullable=False)
    total_reviews: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    is_available_for_hire: Mapped[bool] = mapped_column(Boolean, default=True, index=True, nullable=False)
    service_city: Mapped[str] = mapped_column(String(100), index=True, nullable=False)

    user = relationship("User", back_populates="caregiver_profile")


class DoctorProfile(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "doctor_profiles"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    specialization: Mapped[str] = mapped_column(String(100), index=True, nullable=False)
    medical_license_number: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    qualifications: Mapped[str] = mapped_column(String(200), nullable=False)
    hospital_affiliation: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    consultation_fee: Mapped[float] = mapped_column(DECIMAL(10, 2), nullable=False)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    rating_average: Mapped[float] = mapped_column(DECIMAL(3, 2), default=0.0, nullable=False)

    user = relationship("User", back_populates="doctor_profile")

