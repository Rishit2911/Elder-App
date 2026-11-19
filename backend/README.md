# SeniorCare Backend — Phase 2 Implementation

This is the production-grade FastAPI backend for SeniorCare, built independently for Phase 2 with full compatibility for Person 1's Flutter frontend.

---

## 1. Prerequisites

- Python 3.11+ (Python 3.13 supported)
- PostgreSQL 15+ (with `pgcrypto` / `gen_random_uuid`)
- OpenCV 4.x / 5.x headless

---

## 2. Environment Setup & Configuration

Create a `.env` file in `backend/` (or copy from `.env.example`):

```ini
APP_NAME=SeniorCare Backend
ENVIRONMENT=development
DEBUG=True
API_V1_PREFIX=/api/v1
SECRET_KEY=production-grade-super-secret-key-32-bytes-minimum!
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/seniorcare_db
FACE_ENCRYPTION_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
```

Activate the virtual environment and install dependencies:
```powershell
cd backend
.\venv\Scripts\activate
pip install -r requirements.txt
```

---

## 3. Database Migrations

Apply Alembic migrations to set up or update the schema:
```powershell
python -m alembic upgrade head
```

---

## 4. Running the Development Server

Start the FastAPI application with Uvicorn:
```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Interactive API documentation:
- **Swagger UI:** [http://localhost:8000/docs](http://localhost:8000/docs)
- **ReDoc:** [http://localhost:8000/redoc](http://localhost:8000/redoc)
- **Health Check:** [http://localhost:8000/api/v1/health](http://localhost:8000/api/v1/health)

---

## 5. Running Automated Tests

Run the full Pytest test suite with code coverage:
```powershell
python -m pytest tests/ -v
```

Run test suite with coverage report:
```powershell
python -m pytest --cov=app tests/
```

---

## 6. Phase 2 Core Modules & Features

1. **Dual Registration Endpoints:**
   - `POST /api/v1/auth/register` (Universal / Flutter frontend compatible)
   - `POST /api/v1/auth/register/senior` (Dedicated senior onboarding with age, emergency notes)
   - `POST /api/v1/auth/register/family` (Dedicated family onboarding with relationship description)
2. **Secure Authentication & Token Management:**
   - `POST /api/v1/auth/login` (Unified phone/email + password login)
   - `POST /api/v1/auth/login/family` (Family alias)
   - `POST /api/v1/auth/refresh` (Single-use refresh token rotation with immediate invalidation)
   - `POST /api/v1/auth/logout` (Server-side revocation of refresh tokens)
   - `GET /api/v1/auth/me` (Current authenticated user profile)
3. **Biometric Face Recognition & Anti-Spoofing:**
   - `POST /api/v1/auth/face/enroll` (OpenCV liveness verification + 512-D ArcFace embedding + AES-256-GCM encryption at rest)
   - `POST /api/v1/auth/face/verify` (Anti-spoofing check + Cosine similarity threshold >= 0.68 + token issuance)
   - Enforces explicit biometric informed consent before enrollment
4. **Family-Senior Cryptographic Linking (ReBAC):**
   - `POST /api/v1/family/link/request` (Generates cryptographically secure `SC-XXXXXX` code)
   - `POST /api/v1/family/link/approve` (Senior approval with granular module permissions)
   - `GET /api/v1/family/links` (Active and pending connections)
   - `PATCH /api/v1/family/links/{id}/permissions` (Update granular module access)
   - `POST /api/v1/family/links/{id}/revoke` (Instant disconnection)
5. **User Profile & IDOR Security:**
   - `GET /api/v1/users/me` & `PATCH /api/v1/users/me` (Self profile management, mass-assignment protected)
   - `GET /api/v1/users/{user_id}` (IDOR safe: strictly verifies active relationship before disclosing senior records)
6. **Consent & Audit Logging:**
   - `POST /api/v1/auth/consent` (Audit-logged consent record)
   - Immutable audit logging for all authentication, linking, and biometric events

