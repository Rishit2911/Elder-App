# Diagnostic Audit: Authentication, Navigation, and Database Storage
**SeniorCare Application — Comprehensive System Audit**
**Date:** November 11, 2026  
**Auditor:** Senior Full-Stack Engineer, Security & Biometrics Architect

---

## 1. Executive Summary

This diagnostic audit examines the frontend (`Elder-App/`), backend (`backend/`), and database (`seniorcare_db`) architectures. The investigation was initiated to resolve core functional discrepancies:
1. **Mocked Navigation:** Frontend registration and login currently use simulated timeouts (`Future.delayed`) rather than live HTTP communication.
2. **Unified UI vs. Role-Specific Authentication:** All three personas (Senior Citizen, Family Member, Caretaker) currently present the identical textfield login form without role-distinct authentication flows.
3. **Missing Senior Face Authentication UI:** While the FastAPI backend implements OpenCV-based face detection, anti-spoofing liveness, and AES-256-GCM encrypted 512-D ArcFace biometrics, the Flutter frontend lacks the camera/biometric capture screens and biometric consent workflows.
4. **Backend Endpoint Gaps for Caretaker:** The backend contains dedicated registration endpoints for Senior (`/auth/register/senior`) and Family (`/auth/register/family`), but lacks dedicated endpoints for Caretaker registration (`/auth/register/caregiver`) and Caretaker login (`/auth/login/caregiver`).
5. **Session & Token Persistence:** Tokens (`access_token`, `refresh_token`) and authenticated session metadata are not stored or maintained in Flutter client state, resulting in unauthenticated app launches and navigation disconnects.

---

## 2. Existing Frontend Architecture (`Elder-App/`)

### 2.1 File & Directory Structure
- Entry point: `lib/main.dart` with static routes:
  - `/welcome` ➔ `WelcomeScreen`
  - `/login` ➔ `LoginScreen`
  - `/register` ➔ `RegistrationScreen`
  - `/senior-dashboard` ➔ `SeniorDashboardScreen`
  - `/family-dashboard` ➔ `FamilyDashboardScreen`
  - `/caregiver-dashboard` ➔ `CaregiverDashboardScreen`
- Role Interfaces:
  - `lib/features/senior/` ➔ Comprehensive 5-tab senior dashboard, medicine bottle adherence widget, SOS button, voice assistant screen.
  - `lib/features/family/` ➔ Family dashboard with remote vitals, medicine compliance, and senior health details.
  - `lib/features/caregiver/` ➔ Caregiver dashboard with visit schedules and visit task checklists.
- Contracts & Mock Data:
  - `lib/data/repositories/backend_contract.dart` defines `AuthRepository` abstract interface.
  - `lib/data/repositories/app_mock_data.dart` provides in-memory mock datasets.

### 2.2 Critical Flaws Discovered in Frontend
1. **Zero HTTP Client Implementation:**
   - Neither `package:http` nor `package:dio` nor `dart:io HttpClient` is currently invoked in `login_screen.dart` or `registration_screen.dart`.
   - `_handleLogin()` in `login_screen.dart` executes a `Future.delayed(const Duration(milliseconds: 400))` and immediately calls `Navigator.pushAndRemoveUntil`.
   - `_handleRegister()` in `registration_screen.dart` executes a `Future.delayed(const Duration(milliseconds: 500))` and immediately calls `Navigator.pushAndRemoveUntil`.
2. **No Real Validation:** Invalid passwords or unregistered accounts always succeed and navigate because the frontend does not contact the backend.
3. **No Face Capture or Biometric Consent:**
   - Seniors cannot enroll their face during registration.
   - Seniors cannot authenticate using face recognition on login.
4. **No Session Token Storage:**
   - JWT tokens returned by the backend are neither parsed nor saved.
   - The user's role is determined only by a temporary UI pill toggle rather than cryptographic server authorization.

---

## 3. Existing Backend Architecture (`backend/`)

### 3.1 Framework & Core Modules
- **FastAPI 0.115+** with ASGI lifespan and CORS middleware.
- **SQLAlchemy 2.0 Async Engine** connected to PostgreSQL `seniorcare_db`.
- **Argon2id Hashing:** Password hashing configured with memory cost 64 MB ($m=65536$), iteration count ($t=3$), parallelism ($p=4$).
- **JWT Management:** HS256 JWT access tokens (30 min) and SHA-256 hashed refresh tokens (7 days) with single-use rotation.
- **Biometric Pipeline (`FaceRecognitionService`):**
  - OpenCV image validation & normalization.
  - Frequency domain FFT and texture Laplacian anti-spoofing liveness check.
  - 512-D ArcFace-compatible embedding extraction.
  - AES-256-GCM encryption/decryption at rest.
  - Calibrated Cosine Similarity matching ($\ge 0.68$).

### 3.2 Endpoint Inventory & Persona Gaps
- `POST /api/v1/auth/register` (Universal registration supporting `senior`, `family`, `caregiver`).
- `POST /api/v1/auth/register/senior` (Dedicated Senior registration).
- `POST /api/v1/auth/register/family` (Dedicated Family registration).
- `POST /api/v1/auth/register/caregiver` ➔ **MISSING:** Caregivers must use the universal endpoint, which doesn't capture caregiver-specific fields (hourly rate, service city, experience).
- `POST /api/v1/auth/login` (Unified login with `emailOrPhone`, `password`, and optional `role` verification).
- `POST /api/v1/auth/login/family` (Family login alias).
- `POST /api/v1/auth/login/caregiver` ➔ **MISSING:** Explicit Caregiver login alias enforcing `role="caregiver"`.
- `POST /api/v1/auth/face/enroll` (Biometric face enrollment for Senior).
- `POST /api/v1/auth/face/verify` (Biometric face login for Senior).

---

## 4. Existing Database Tables & Relationships (`seniorcare_db`)

Inspection of live PostgreSQL database reveals **39 tables**:
- `users`: Core authentication identity table (204 rows). Contains `id`, `phone_number`, `email`, `hashed_password`, `role`, `is_active`.
- `senior_profiles`: Linked 1:1 with `users` (112 rows). Contains senior medical, address, and profile data.
- `family_profiles`: Linked 1:1 with `users` (92 rows). Contains family member contact and relationship info.
- `caregiver_profiles`: Linked 1:1 with `users` (0 rows). Contains caregiver hourly rates, ratings, and verification status.
- `face_profiles`: Linked 1:1 with `senior_profiles` (5 rows). Stores `encrypted_embedding`, `iv`, `auth_tag`, `quality_score`, `liveness_score`.
- `user_consents`: Tracks explicit biometric and data consents (9 rows).
- `refresh_tokens`: Active and revoked cryptographic session tokens (119 rows).
- `devices`: FCM push token and hardware binding (108 rows).
- `audit_logs`: Immutable security event trail (389 rows).
- `family_relationships` & `access_permissions`: ReBAC relationships and granular module grants (11 rows, 33 grants).

---

## 5. Root Causes of Observed Problems

| Problem | Root Cause |
|---|---|
| Registration & login do not contact database | `login_screen.dart` and `registration_screen.dart` use local `Future.delayed` mocks with hardcoded `Navigator.pushAndRemoveUntil` instead of calling an HTTP API service. |
| All 3 roles share same login screen | `login_screen.dart` only provides a single generic form for email/password and a UI role pill, with no dedicated Senior Face Login flow. |
| Senior cannot login with face | No camera capture UI, biometric consent dialog, or multipart upload to `/api/v1/auth/face/enroll` and `/api/v1/auth/face/verify` exist in Flutter. |
| Caregiver registration lacks backend specialization | Backend lacks dedicated `/api/v1/auth/register/caregiver` and `/api/v1/auth/login/caregiver` endpoints to store full caregiver qualifications and enforce role segregation. |
| Navigation disconnects after login | No authentication state provider or token storage exists; the app does not store the returned user ID or role, nor does it check backend success before navigating. |

---

## 6. Comprehensive Action Plan

1. **Backend Enhancements:**
   - Add `POST /api/v1/auth/register/caregiver` with schema `CaregiverRegisterRequest` (hourly rate, service city, experience).
   - Add `POST /api/v1/auth/login/caregiver` enforcing `role == 'caregiver'`.
   - Ensure `POST /api/v1/auth/face/enroll` and `/api/v1/auth/face/verify` support both raw binary and base64 payloads to accommodate all client environments.
2. **Frontend Real Network & Auth Client Implementation:**
   - Create `Elder-App/lib/data/services/auth_api_service.dart` using standard Dart `HttpClient` / `http` to communicate with `http://localhost:8000/api/v1`.
   - Implement real API calls for Senior, Family, and Caregiver registration and login.
   - Store active user session (tokens, userId, role, fullName).
3. **Role-Specific Authentication Interfaces:**
   - **Senior Citizen:**
     - Registration includes personal details and explicit Biometric Consent check.
     - Face enrollment screen captures face sample and enrolls with `/api/v1/auth/face/enroll`.
     - Face login screen captures face sample, posts to `/api/v1/auth/face/verify`, and falls back to password/phone if face verification fails.
   - **Family Member:** Dedicated password-based registration and login calling `/api/v1/auth/register/family` and `/api/v1/auth/login/family`.
   - **Caretaker:** Dedicated registration and login calling `/api/v1/auth/register/caregiver` and `/api/v1/auth/login/caregiver`.
4. **Reliable Navigation Flow:**
   - Navigate to `SeniorDashboardScreen`, `FamilyDashboardScreen`, or `CaregiverDashboardScreen` **only** upon HTTP 200/201 response and role match.
   - Display real, user-friendly error banners on invalid credentials, duplicate accounts, or biometric mismatch.
5. **Automated Testing & Database Verification:**
   - Add backend tests for caregiver endpoints and biometrics.
   - Execute test suite and verify new database records directly in PostgreSQL.

