from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, Field


class SOSTriggerRequest(BaseModel):
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    approximate_address: Optional[str] = None
    trigger_source: str = Field(default="in_app_button", pattern="^(in_app_button|voice_assistant_keyword|fall_detection_sensor)$")
    battery_level_percent: Optional[int] = Field(None, ge=0, le=100)


class SOSEventResponse(BaseModel):
    sos_event_id: UUID
    status: str
    triggered_at: datetime
    notified_contacts_count: int
    message: str


class SOSResolveRequest(BaseModel):
    resolution_status: str = Field(..., pattern="^(resolved|false_alarm)$")
    notes: Optional[str] = None

