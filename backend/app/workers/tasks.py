from uuid import UUID
from app.workers.celery_app import celery


@celery.task(bind=True, max_retries=3, default_retry_delay=5)
def dispatch_emergency_sos(self, event_id: str, latitude: float, longitude: float):
    """
    High-priority background worker task to broadcast SOS alerts via FCM
    and Twilio SMS to all family members and emergency contacts.
    """
    try:
        # In Phase 2: Query PostgreSQL for contacts, dispatch concurrently
        return {"status": "broadcast_completed", "event_id": event_id}
    except Exception as exc:
        raise self.retry(exc=exc)


@celery.task
def check_medicine_reminders():
    """
    Periodic cron task run by Celery Beat every 60 seconds to find
    upcoming medicine doses and enqueue push alerts.
    """
    # In Phase 2: Select medicine_schedules WHERE time_of_day ~ current_time
    return {"status": "checked", "notifications_queued": 0}

