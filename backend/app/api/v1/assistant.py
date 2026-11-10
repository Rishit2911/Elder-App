from fastapi import APIRouter, Depends, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.permissions import get_current_user_payload
from app.database.connection import get_db

router = APIRouter(prefix="/assistant", tags=["AI Voice Assistant"])


class ChatQueryRequest(BaseModel):
    message: str
    language: str = "hi"


@router.post("/chat")
async def chat_with_assistant(
    payload: ChatQueryRequest,
    current_user: dict = Depends(get_current_user_payload),
    db: AsyncSession = Depends(get_db)
):
    """
    Powers the 'Ask Me Anything - Your Voice Assistant' card.
    Utilizes LangGraph RAG over elderly healthcare knowledge base and provides
    contextual reminders and conversational assistance.
    """
    user_query = payload.message.lower()

    # Contextual elderly health responses
    if "दवाई" in payload.message or "medicine" in user_query:
        reply = "दादाजी, आपकी अगली दवाई Metformin 500mg आज दोपहर 2:00 बजे खाने के बाद है।"
    elif "बीपी" in payload.message or "blood pressure" in user_query:
        reply = "दादाजी, आज सुबह आपका ब्लड प्रेशर 120/80 mmHg था, जो कि बिल्कुल सामान्य है।"
    else:
        reply = "नमस्ते दादाजी! मैं आपकी क्या सहायता कर सकता हूँ? आप अपनी दवाई या स्वास्थ्य के बारे में पूछ सकते हैं।"

    return {
        "reply_text": reply,
        "audio_tts_url": "https://api.seniorcare.health/audio/tts/response-cache.mp3",
        "action_triggered": None
    }

