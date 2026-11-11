from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version="1.0.0",
    description="Backend REST API for SeniorCare – AI-Powered Elderly Healthcare & Caregiving Platform",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# Cross-Origin Resource Sharing (CORS) Middleware
# Uses allow_origin_regex to support dynamic Flutter Web dev ports while allowing credentials
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^https?://.*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount Version 1 REST API Router
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/health", tags=["Health & Diagnostics"])
@app.get(f"{settings.API_V1_PREFIX}/health", tags=["Health & Diagnostics"])
async def health_check():
    """
    Standard liveness and readiness probe for Docker / Kubernetes orchestrators.
    """
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "environment": settings.ENVIRONMENT,
        "version": "1.0.0"
    }


@app.get("/", tags=["Health & Diagnostics"])
async def root():
    """
    Root informational endpoint.
    """
    return {
        "message": "Welcome to SeniorCare API",
        "documentation": "/docs",
        "api_v1": settings.API_V1_PREFIX
    }

