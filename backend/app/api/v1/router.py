from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.face import router as face_router
from app.api.v1.family import router as family_router
from app.api.v1.healthcare import router as healthcare_router
from app.api.v1.emergency import router as emergency_router
from app.api.v1.caregivers import router as caregivers_router
from app.api.v1.assistant import router as assistant_router
from app.api.v1.consultations import router as consultations_router

api_router = APIRouter()

api_router.include_router(auth_router)
api_router.include_router(face_router)
api_router.include_router(family_router)
api_router.include_router(healthcare_router)
api_router.include_router(emergency_router)
api_router.include_router(caregivers_router)
api_router.include_router(assistant_router)
api_router.include_router(consultations_router)

