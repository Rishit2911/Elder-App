# SeniorCare Platform — Frontend & Backend Compatibility Analysis

**Phase:** Phase 2 — Core Authentication, Biometrics, User Profiles & Family Linking  
**Auditor / Architect:** Senior Backend Architect & API Integration Engineer (Person 2)  
**Source of Truth:** Git Commit `d44b3a7` (Person 1's Flutter Implementation)  
**Date:** November 10, 2026  

---

## 1. Executive Summary

This document establishes the bidirectional compatibility matrix between **Person 1's Flutter frontend** (`Elder-App/`) and **Person 2's FastAPI backend** (`backend/`). The analysis traces actual UI forms, state models, repository contracts, and event handlers to guarantee seamless future integration without requiring breaking modifications to Person 1's frontend code.

---

## 2. Person 1's Existing Frontend Implementation Analysis

### 2.1 User Roles Represented
In `Elder-App/lib/data/models/user_model.dart`, Person 1 defined the enum:
```dart
enum UserRole {
  senior,
  family,
  caregiver,
}
```
*Backend Alignment:* The backend database (`users.role`) supports `senior`, `family`, `caregiver`, and `admin`. The API seamlessly accepts and returns `senior`, `family`, and `caregiver`.

### 2.2 Registration Screen (`lib/features/auth/registration_screen.dart`)
- **UI Form Fields:**
  - `Full Name`: string, required, trimmed (`_nameController`).
  - `Email Address`: string, required, validated for `@` and `.` (`_emailController`).
  - `Phone Number`: string, required (`_phoneController`).
  - `Password`: string, required, minimum 6 characters (`_passwordController`).
  - `Confirm Password`: string, required, matching password (`_confirmPasswordController`).
  - `Role Selection`: pill toggle for `senior`, `family`, or `caregiver` (`_selectedRole`).
  - `Terms Agreement`: boolean toggle (must be accepted).
- **Frontend Submission Target:**
  - Noted in UI: `POST /api/v1/auth/register` (universal registration) and role-specific endpoints `POST /api/v1/auth/register/senior`, `POST /api/v1/auth/register/family`.

### 2.3 Login Screen (`lib/features/auth/login_screen.dart`)
- **UI Form Fields:**
  - `Email or Mobile Number`: string, required (`_identifierController`). Accepts both email or phone number.
  - `Password`: string, required (`_passwordController`).
  - `Role Selection`: pill selector (`senior`, `family`, `caregiver`).
- **Frontend Submission Target:**
  - Noted in UI: `POST /api/v1/auth/login` and `POST /api/v1/auth/login/family`.
  - Body payload: `{ "emailOrPhone": "...", "password": "...", "role": "..." }`.

### 2.4 Family-Senior Relationships (`lib/data/models/family_member_model.dart` & `lib/features/senior/tabs/family_tab.dart`)
- **Supported Relationship Types in UI:**
  - `son`, `daughter`, `spouse`, `grandchild`, `sibling`, `other` (with custom title).
- **Attributes Tracked:**
  - `isPrimaryEmergencyContact`: boolean
  - `connectionStatus`: string (e.g. "Active now", "Pending approval")
  - `hasSharedHealthConsent`: boolean (consent to view medical records)
- **Frontend Submission Target:**
  - `POST /api/v1/family/link/request` (request relationship via invite code or senior phone)
  - `POST /api/v1/family/link/approve` (senior approves relationship)
  - `GET /api/v1/family/links` (list active connections)

---

## 3. Frontend-to-Backend Field Mapping Matrix

To eliminate naming friction, the FastAPI backend uses **Pydantic v2 `Field(alias=...)` and `ConfigDict(populate_by_name=True)`**, permitting the API to accept both camelCase (Flutter style) and snake_case (Python style) interchangeably:

| Flutter Field (CamelCase) | Backend Field (Snake_case) | Database Column | Data Type | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `fullName` | `full_name` | `users.full_name` | `VARCHAR(150)` | Required across all roles |
| `email` | `email` | `users.email` | `VARCHAR(255)` | Unique, nullable for seniors |
| `phoneNumber` / `phone` | `mobile_number` / `phone` | `users.mobile_number` | `VARCHAR(20)` | Unique, indexed for login |
| `password` | `password` | `users.password_hash` | `VARCHAR(255)` | Hashed with Argon2id; never stored raw |
| `role` | `role` | `users.role` | `VARCHAR(50)` | `senior`, `family`, `caregiver`, `admin` |
| `emailOrPhone` | `identifier` / `email_or_phone` | Looked up in `email` OR `mobile_number` | `VARCHAR(255)` | Login identifier |
| `profilePhoto` | `profile_photo` / `avatar_url` | `senior_profiles.address` / files | `VARCHAR(500)` | S3 / local static URL |
| `isPrimaryEmergencyContact` | `is_emergency_priority` | `family_relationships.emergency_priority` | `INT` | 1 = primary, 2 = secondary |
| `relationship` | `relationship` | `family_relationships.relationship_type` | `VARCHAR(50)` | Lowercase enum string |

---

## 4. Standard Response Envelope Contract

Person 1's frontend expects standardized JSON envelopes with clear status indicators and error codes:

### Success Envelope
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... }
}
```

### Error Envelope
```json
{
  "success": false,
  "message": "Descriptive human-readable error message",
  "error_code": "INVALID_CREDENTIALS",
  "details": null
}
```

---

## 5. Identified Gaps & Backend Compensations

1. **Passwordless Senior Accounts:**
   - *Observation:* Seniors can be registered without a password if assisted by family, relying on Face Recognition or OTP.
   - *Backend Compensation:* `users.password_hash` is nullable in PostgreSQL. If a senior registers without a password, they authenticate using Face Recognition (`POST /api/v1/auth/face/verify`).
2. **Biometric Consent:**
   - *Observation:* Biometric enrollment requires explicit informed consent before face images are processed.
   - *Backend Compensation:* The backend provides `POST /api/v1/auth/face/enroll` which strictly enforces that an active record exists in `user_consents` (consent type: `biometric_face_auth`).
3. **Emergency Override Permissions:**
   - *Observation:* In emergencies, family members designated as `isPrimaryEmergencyContact` need instant read access to medications and health vitals.
   - *Backend Compensation:* ReBAC engine evaluates `access_permissions.can_emergency_override` when an active emergency alert exists.

