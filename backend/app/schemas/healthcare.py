from datetime import date, datetime, time
from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel, Field


class ScheduleItem(BaseModel):
    time_of_day: str  # e.g., "09:00:00"
    days_of_week: Optional[List[int]] = None
    dose_quantity: float = 1.0


class MedicineCreateRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=150)
    dosage_strength: str = Field(..., max_length=50)
    form: str = Field(..., pattern="^(tablet|capsule|syrup|injection|drops)$")
    meal_relation: str = Field(..., pattern="^(before_meal|after_meal|with_meal|empty_stomach)$")
    color_code: Optional[str] = None
    start_date: date
    end_date: Optional[date] = None
    instructions: Optional[str] = None
    schedules: List[ScheduleItem] = []


class MedicineLogRequest(BaseModel):
    schedule_id: UUID
    senior_id: UUID
    scheduled_timestamp: datetime
    status: str = Field(..., pattern="^(taken|missed|skipped|snoozed)$")
    notes: Optional[str] = None


class HealthRecordCreateRequest(BaseModel):
    title: str = Field(..., min_length=3, max_length=200)
    record_type: str = Field(..., pattern="^(vitals|lab_test|doctor_summary|discharge_summary|vaccination)$")
    recorded_at: datetime
    vital_bp_systolic: Optional[int] = Field(None, ge=50, le=260)
    vital_bp_diastolic: Optional[int] = Field(None, ge=30, le=160)
    vital_heart_rate: Optional[int] = Field(None, ge=30, le=220)
    vital_blood_glucose: Optional[float] = Field(None, ge=20, le=600)
    notes: Optional[str] = None


class DashboardSummaryResponse(BaseModel):
    senior_name: str
    greeting: str
    subtitle: str
    profile_image_url: Optional[str]
    next_medicine: Optional[dict]
    recent_vitals: Optional[dict]
    caregiver_status: str
    unread_notifications_count: int

