from celery import Celery
from app.core.config import settings

# Celery instance configuration with Redis broker
celery = Celery(
    "seniorcare_worker",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=["app.workers.tasks"]
)

celery.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="Asia/Kolkata",
    enable_utc=True,
    task_routes={
        "app.workers.tasks.dispatch_emergency_sos": {"queue": "critical"},
        "app.workers.tasks.check_medicine_reminders": {"queue": "schedules"},
    },
    beat_schedule={
        # Check every 60 seconds for upcoming medication reminders
        "medicine-reminder-cron": {
            "task": "app.workers.tasks.check_medicine_reminders",
            "schedule": 60.0,
        },
    }
)

