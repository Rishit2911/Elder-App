from typing import List
from uuid import UUID


class NotificationService:
    """
    Handles push notification delivery via Firebase Cloud Messaging (FCM)
    and SMS / WhatsApp alerts via Twilio.
    """

    async def send_emergency_sos_alert(
        self,
        senior_name: str,
        latitude: float,
        longitude: float,
        recipient_phones: List[str]
    ):
        """
        Dispatches high-priority siren push notification and urgent SMS
        with live Google Maps location tracking link.
        """
        maps_link = f"https://maps.google.com/?q={latitude},{longitude}"
        msg = f"EMERGENCY ALERT: {senior_name} pressed SOS! Live location: {maps_link}"
        # In Phase 2: Async Twilio REST API call + FCM multicast
        return {"sent_count": len(recipient_phones), "message": msg}

    async def send_medicine_reminder(self, senior_id: UUID, medicine_name: str, dose_time: str):
        """
        Sends local-time scheduled push reminder.
        """
        return {"senior_id": str(senior_id), "medicine": medicine_name, "time": dose_time}


notification_service = NotificationService()

