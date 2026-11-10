from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, Field


class CaregiverSearchQuery(BaseModel):
    city: Optional[str] = None
    service_category: Optional[str] = None
    min_rating: Optional[float] = None
    max_hourly_rate: Optional[float] = None


class BookingCreateRequest(BaseModel):
    senior_id: UUID
    caregiver_id: UUID
    service_id: UUID
    booking_type: str = Field(..., pattern="^(hourly|daily|weekly|monthly)$")
    start_datetime: datetime
    end_datetime: datetime
    special_instructions: Optional[str] = None

