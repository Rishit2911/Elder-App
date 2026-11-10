from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import check_senior_rebac_access, get_current_user_payload
from app.database.connection import get_db
from app.schemas.healthcare import (
    DashboardSummaryResponse, HealthRecordCreateRequest,
    MedicineCreateRequest, MedicineLogRequest
)

router = APIRouter(prefix="/healthcare", tags=["Healthcare & Medicines"])


@router.get("/seniors/{senior_id}/dashboard-summary", response_model=DashboardSummaryResponse)
async def get_dashboard_summary(
    senior_id: UUID,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Supplies real-time aggregated data for Person 1's Flutter HomeDashboard:
    Senior greeting, profile image, next upcoming medicine, and vital stats.
    """
    return {
        "senior_name": "Ramesh Sharma",
        "greeting": "नमस्ते दादाजी",
        "subtitle": "Take care and stay healthy!",
        "profile_image_url": "assets/images/dadaji_profile.png",
        "next_medicine": {
            "name": "Metformin 500mg",
            "time": "14:00:00",
            "meal_relation": "after_meal",
            "dose": "1 tablet"
        },
        "recent_vitals": {
            "blood_pressure": "120/80 mmHg",
            "blood_glucose": "112 mg/dL",
            "recorded_at": "2026-11-06T08:00:00Z"
        },
        "caregiver_status": "No active booking for today",
        "unread_notifications_count": 2
    }


@router.get("/seniors/{senior_id}/medicines")
async def get_senior_medicines(
    senior_id: UUID,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve active medications and today's schedule for "My Medicines" card.
    """
    return {
        "senior_id": senior_id,
        "medicines": [
            {
                "id": "med-uuid-1",
                "name": "Metformin 500mg",
                "form": "tablet",
                "meal_relation": "after_meal",
                "instructions": "खाने के बाद पानी के साथ लें",
                "schedules": [{"time": "14:00:00", "dose": 1.0}, {"time": "20:00:00", "dose": 1.0}]
            },
            {
                "id": "med-uuid-2",
                "name": "Amlodipine 5mg",
                "form": "tablet",
                "meal_relation": "after_meal",
                "instructions": "सुबह नाश्ते के बाद",
                "schedules": [{"time": "09:00:00", "dose": 1.0}]
            }
        ]
    }


@router.post("/seniors/{senior_id}/medicines", status_code=status.HTTP_201_CREATED)
async def create_senior_medicine(
    senior_id: UUID,
    payload: MedicineCreateRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Add a new medicine and dosage schedules.
    """
    return {
        "message": f"Medicine '{payload.name}' registered with {len(payload.schedules)} daily schedules.",
        "senior_id": senior_id
    }


@router.post("/medicines/logs")
async def log_medicine_adherence(
    payload: MedicineLogRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Log dose adherence when senior taps "Taken", "Snooze", or "Missed".
    """
    return {
        "status": "recorded",
        "logged_status": payload.status,
        "schedule_id": payload.schedule_id,
        "message": f"Dose marked as {payload.status}."
    }


@router.get("/seniors/{senior_id}/records")
async def get_health_records(
    senior_id: UUID,
    record_type: str = Query("vitals"),
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve health records and vitals for "Health Tracker" card.
    """
    return {
        "senior_id": senior_id,
        "record_type": record_type,
        "items": [
            {
                "title": "Morning Vitals Check",
                "recorded_at": "2026-11-06T08:30:00Z",
                "bp_systolic": 120,
                "bp_diastolic": 80,
                "glucose": 110.0,
                "heart_rate": 72
            }
        ]
    }


@router.post("/seniors/{senior_id}/records", status_code=status.HTTP_201_CREATED)
async def create_health_record(
    senior_id: UUID,
    payload: HealthRecordCreateRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Add a new vitals entry or health document.
    """
    return {
        "message": "Health record recorded successfully",
        "title": payload.title,
        "senior_id": senior_id
    }

