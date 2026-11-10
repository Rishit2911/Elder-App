from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user_payload
from app.database.connection import get_db

router = APIRouter(prefix="/consultations", tags=["Medical Consultations & Hospitals"])


@router.get("/nearby-hospitals")
async def get_nearby_hospitals(
    latitude: float = Query(26.9124),
    longitude: float = Query(75.7873),
    radius_km: float = Query(10.0),
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Powers the 'Nearby Hospitals' card on Person 1's Home Dashboard.
    """
    return {
        "hospitals": [
            {
                "name": "SMS Government Hospital & Emergency Trauma",
                "distance_km": 2.4,
                "helpline_phone": "0141-2560291",
                "ambulance_phone": "108",
                "address": "Jawaharlal Nehru Marg, Jaipur",
                "has_icu": True
            },
            {
                "name": "Fortis Escorts Hospital",
                "distance_km": 4.1,
                "helpline_phone": "0141-2547000",
                "ambulance_phone": "1050",
                "address": "Malviya Nagar, Jaipur",
                "has_icu": True
            }
        ]
    }


@router.get("/doctors")
async def get_available_doctors(
    specialization: Optional[str] = None,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Powers the 'Talk to a Doctor' card on Person 1's Home Dashboard.
    """
    return {
        "doctors": [
            {
                "id": "doc-uuid-1",
                "name": "Dr. Arvind Sharma",
                "specialization": "Geriatric Specialist & Senior Physician",
                "qualifications": "MBBS, MD (Medicine)",
                "consultation_fee": 500.0,
                "rating": 4.95,
                "next_available_slot": "Today, 4:30 PM"
            }
        ]
    }

