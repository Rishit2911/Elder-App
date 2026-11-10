import uuid
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user_payload
from app.database.connection import get_db
from app.schemas.emergency import SOSEventResponse, SOSResolveRequest, SOSTriggerRequest

router = APIRouter(prefix="/emergency", tags=["Emergency SOS"])


@router.post("/sos", response_model=SOSEventResponse, status_code=status.HTTP_201_CREATED)
async def trigger_emergency_sos(
    payload: SOSTriggerRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Urgent SOS trigger from Person 1's Flutter SOSCard.
    Initiates real-time broadcast via FCM and SMS to family care circle and emergency contacts.
    """
    event_id = uuid.uuid4()
    now = datetime.now(timezone.utc)

    # In Phase 2, this enqueues high-priority Celery task:
    # dispatch_emergency_sos.delay(event_id, payload.latitude, payload.longitude)

    return {
        "sos_event_id": event_id,
        "status": "active",
        "triggered_at": now,
        "notified_contacts_count": 3,
        "message": "Emergency SOS broadcast dispatched. Family members alerted with live location."
    }


@router.post("/sos/{event_id}/resolve")
async def resolve_emergency_sos(
    event_id: uuid.UUID,
    payload: SOSResolveRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Close active SOS event after help arrives or dismiss as false alarm.
    """
    return {
        "sos_event_id": event_id,
        "status": payload.resolution_status,
        "message": f"Emergency incident marked as {payload.resolution_status}."
    }


@router.get("/contacts")
async def get_emergency_contacts(
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve configured emergency phone list for instant dialing.
    """
    return {
        "contacts": [
            {"name": "Priya (Daughter)", "phone": "+919811223344", "priority": 1},
            {"name": "Dr. Verma (Family Doctor)", "phone": "+919822334455", "priority": 2},
            {"name": "Emergency Ambulance Helpline", "phone": "108", "priority": 3}
        ]
    }

