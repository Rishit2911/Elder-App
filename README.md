# SeniorCare – AI-Powered Elderly Healthcare & Caregiving Platform

SeniorCare is a comprehensive, AI-powered elderly healthcare and caregiving platform connecting senior citizens with family members, verified caregivers, and medical professionals. It provides passwordless face recognition, remote family monitoring, caregiver booking, medicine adherence tracking, emergency SOS dispatch, doctor teleconsultations, and an empathetic AI voice assistant.

---

## 1. Project Organization & Team Roles

SeniorCare is developed across 7 collaborative phases by two core engineers:
* **Person 1 (Frontend Lead):** Flutter mobile application development, UI/UX screens, widgets, and user interaction flows ([`Elder-App/`](file:///d:/Elder%20Seva%20app/Elder-App/)).
* **Person 2 (Backend Architect & Database Designer):** System architecture, PostgreSQL database schema, REST API specifications, biometrics & security engineering, and backend skeleton ([`backend/`](file:///d:/Elder%20Seva%20app/backend/) & [`docs/`](file:///d:/Elder%20Seva%20app/docs/)).

```text
Elder Seva app/
│
├── Elder-App/                        # Person 1: Flutter Frontend Application
│   ├── lib/
│   │   └── main.dart                 # Primary HomeDashboard & UI widgets
│   ├── assets/images/                # Illustrations & Dadaji profile picture
│   └── pubspec.yaml                  # Flutter package configuration
│
├── backend/                          # Person 2: FastAPI Async Backend
│   ├── app/
│   │   ├── api/v1/                   # REST API routes (Auth, Face, Healthcare, SOS, Family, Caregivers)
│   │   ├── core/                     # Config, Argon2id security, JWT, and ReBAC permissions
│   │   ├── database/                 # SQLAlchemy 2.0 async engine and declarative base
│   │   ├── models/                   # 37 Relational PostgreSQL tables across 11 modules
│   │   ├── schemas/                  # Pydantic v2 validation schemas
│   │   ├── services/                 # OpenCV FaceNet, LangGraph RAG, and FCM Push services
│   │   ├── workers/                  # Celery background workers and Beat reminder schedulers
│   │   └── main.py                   # FastAPI ASGI entrypoint
│   ├── migrations/                   # Alembic database migration environment
│   ├── tests/                        # Pytest async test suite
│   ├── Dockerfile                    # Multi-stage production container
│   ├── docker-compose.yml            # Multi-service stack (FastAPI, Postgres, Redis, Celery)
│   └── requirements.txt              # Locked Python dependencies
│
└── docs/                             # Person 2: System Architecture & Design Documentation
    ├── architecture/
    │   └── backend_architecture.md   # System topology, microservices, and Mermaid architecture diagram
    ├── database/
    │   ├── database_design.md        # Comprehensive 37-table database specification across 11 modules
    │   ├── er_diagram.md             # Complete Mermaid Entity-Relationship diagram
    │   └── schema.dbml               # dbdiagram.io compatible DBML file
    ├── api/
    │   ├── api_documentation.md      # Human-readable REST endpoint catalog
    │   └── openapi.yaml              # Complete OpenAPI 3.0 YAML specification
    ├── security/
    │   ├── user_roles_and_permissions.md # ReBAC + RBAC matrix and invitation workflows
    │   ├── security_architecture.md  # Argon2id, JWT rotation, AES-256-GCM, and audit logging
    │   └── face_recognition_architecture.md # OpenCV + ArcFace pipeline & anti-spoofing
    └── integration/
        └── frontend_backend_mapping.md # Direct mapping of Person 1's screens to backend endpoints
```

---

## 2. Technology Stack

* **Frontend:** Flutter 3.x, Dart, Material 3
* **Backend:** Python 3.11+, FastAPI (Async), Pydantic v2
* **Database:** PostgreSQL 16+ with `pgvector`, SQLAlchemy 2.0 (Async), Alembic
* **Cache & Broker:** Redis 7, Celery & Celery Beat
* **Biometric Vision:** OpenCV 4.10+, ArcFace (ResNet-50)
* **AI & Conversational RAG:** LangGraph, LangChain, Ollama/Llama 3
* **Push & Telephony:** Firebase Cloud Messaging (FCM), Twilio SMS
* **Containerization:** Docker & Docker Compose

---

## 3. Quick Start Guide (Backend)

### Option A: Running via Docker Compose (Recommended)
```bash
cd backend
docker compose up --build -d
```
API documentation will be immediately available at:
* Swagger UI: [http://localhost:8000/docs](http://localhost:8000/docs)
* ReDoc: [http://localhost:8000/redoc](http://localhost:8000/redoc)
* Health Probe: [http://localhost:8000/health](http://localhost:8000/health)

### Option B: Local Python Development
```bash
cd backend
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --port 8000
```

---

## 4. Phase 1 Completion Deliverables

All deliverables required for Phase 1 (Person 2) are complete and verified:
1. System Architecture: [`docs/architecture/backend_architecture.md`](file:///d:/Elder%20Seva%20app/docs/architecture/backend_architecture.md)
2. Database Schema: [`docs/database/database_design.md`](file:///d:/Elder%20Seva%20app/docs/database/database_design.md)
3. ER Diagram: [`docs/database/er_diagram.md`](file:///d:/Elder%20Seva%20app/docs/database/er_diagram.md)
4. DBML File: [`docs/database/schema.dbml`](file:///d:/Elder%20Seva%20app/docs/database/schema.dbml)
5. Roles & Permissions: [`docs/security/user_roles_and_permissions.md`](file:///d:/Elder%20Seva%20app/docs/security/user_roles_and_permissions.md)
6. Face Recognition: [`docs/security/face_recognition_architecture.md`](file:///d:/Elder%20Seva%20app/docs/security/face_recognition_architecture.md)
7. Security Architecture: [`docs/security/security_architecture.md`](file:///d:/Elder%20Seva%20app/docs/security/security_architecture.md)
8. REST API Guide: [`docs/api/api_documentation.md`](file:///d:/Elder%20Seva%20app/docs/api/api_documentation.md)
9. OpenAPI 3.0 Spec: [`docs/api/openapi.yaml`](file:///d:/Elder%20Seva%20app/docs/api/openapi.yaml)
10. Screen Mapping: [`docs/integration/frontend_backend_mapping.md`](file:///d:/Elder%20Seva%20app/docs/integration/frontend_backend_mapping.md)
11. Modular Backend Code: [`backend/`](file:///d:/Elder%20Seva%20app/backend/)

