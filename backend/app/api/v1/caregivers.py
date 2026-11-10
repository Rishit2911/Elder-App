import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user_payload
from app.database.connection import get_db
from app.schemas.caregivers import BookingCreateRequest

router = APIRouter(prefix="/caregivers", tags=["Caregiver Services"])


@router.get("/search")
async def search_caregivers(
    city: Optional[str] = Query("Jaipur"),
    service_category: Optional[str] = None,
    min_rating: Optional[float] = None,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Search certified caregivers for Person 1's "Book a Caregiver" screen.
    """
    return {
        "caregivers": [
            {
                "id": "cg-uuid-1",
                "name": "Sunita Devi",
                "experience_years": 6,
                "hourly_rate": 250.0,
                "rating": 4.9,
                "police_verified": True,
                "medical_trained": True,
                "specialization": "Elderly Companion & Mobility Care"
            },
            {
                "id": "cg-uuid-2",
                "name": "Rohan Verma",
                "experience_years": 4,
                "hourly_rate": 300.0,
                "rating": 4.8,
                "police_verified": True,
                "medical_trained": True,
                "specialization": "Post-Op & Physiotherapy Support"
            }
        ]
    }


@router.post("/bookings", status_code=status.HTTP_201_CREATED)
async def create_booking(
    payload: BookingCreateRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Request a new caregiver booking shift.
    """
    return {
        "booking_id": uuid.uuid4(),
        "status": "requested",
        "senior_id": payload.senior_id,
        "caregiver_id": payload.caregiver_id,
        "total_estimated_amount": 2000.0,
        "message": "Booking request sent to caregiver. You will receive confirmation shortly."
    }

