# Authentication API Contracts Specification
**SeniorCare Multi-Persona Authentication & Biometric Identity**
**Version:** 2.0.0  
**Base URL:** `http://localhost:8000/api/v1`

---

## 1. Unified Response Envelope

All API endpoints return responses in the following standard JSON envelope:

```json
{
  "success": true,
  "message": "Human-readable status or error description",
  "data": { ... }
}
```

HTTP Status Codes:
- `200 OK`: Request succeeded.
- `201 Created`: Resource created successfully.
- `400 Bad Request`: Validation failure or business rule violation.
- `401 Unauthorized`: Missing, expired, or invalid credentials.
- `403 Forbidden`: Authenticated user lacks permission or role mismatch.
- `404 Not Found`: Target entity not found.
- `409 Conflict`: Phone number or email already registered.
- `422 Unprocessable Entity`: Input field validation failure.

---

## 2. Senior Citizen Endpoints

### 2.1 Senior Registration
- **URL:** `POST /api/v1/auth/register/senior`
- **Request Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "fullName": "Kailash Chand Sharma",
  "preferredName": "दादाजी",
  "phoneNumber": "+919876543210",
  "email": "kailash.sharma@example.com",
  "password": "ValidPassword123!",
  "dateOfBirth": "1948-03-20",
  "age": 78,
  "gender": "male",
  "bloodGroup": "O+",
  "emergencyNotes": "Diabetic, pacemaker fitted"
}
```
- **Response `201 Created`:**
```json
{
  "success": true,
  "message": "Senior citizen registered successfully",
  "data": {
    "userId": "b47c0b89-21b2-4d1a-8e2b-f38b0b5c9284",
    "seniorProfileId": "c59d1a90-32c3-5e2b-9f3c-a49c1c6d0395",
    "fullName": "Kailash Chand Sharma",
    "preferredName": "दादाजी",
    "role": "senior"
  }
}
```

---

### 2.2 Senior Biometric Face Enrollment
- **URL:** `POST /api/v1/auth/face/enroll`
- **Request Headers:** 
  - `Authorization: Bearer <access_token>`
  - `Content-Type: multipart/form-data`
- **Form Data:**
  - `face_image`: Binary image file (JPEG or PNG, minimum $120 \times 120$ px).
- **Enforces:**
  - Active informed biometric consent in `user_consents`.
  - Anti-spoofing liveness check ($\ge 0.35$).
  - AES-256-GCM encryption of 512-D ArcFace embedding.
- **Response `201 Created`:**
```json
{
  "success": true,
  "message": "Face biometric enrolled and encrypted successfully",
  "data": {
    "faceProfileId": "d60e2b01-43d4-6f3c-a04d-b50d2d7e14a6",
    "qualityScore": 0.94,
    "livenessScore": 0.88,
    "modelVersion": "arcface-512-v1",
    "enrolledAt": "2026-11-11T00:30:00Z"
  }
}
```

---

### 2.3 Senior Biometric Face Login
- **URL:** `POST /api/v1/auth/face/verify`
- **Request Headers:** `Content-Type: multipart/form-data`
- **Form Data:**
  - `identifier`: Registered mobile number or email.
  - `face_image`: Fresh captured live face photo.
  - `device_uuid`: Device identifier for token binding.
- **Verification Workflow:**
  1. Fetches senior account and enrolled AES-256-GCM encrypted embedding.
  2. Runs anti-spoofing liveness check on fresh capture.
  3. Decrypts stored embedding and computes Cosine Similarity.
  4. Requires similarity score $\ge 0.68$.
  5. Upon match, generates JWT access and rotating refresh tokens.
- **Response `200 OK`:**
```json
{
  "success": true,
  "message": "Face verification successful. Welcome back!",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
    "refresh_token": "a1b2c3d4e5f6...",
    "token_type": "bearer",
    "expires_in": 1800,
    "user": {
      "id": "b47c0b89-21b2-4d1a-8e2b-f38b0b5c9284",
      "fullName": "Kailash Chand Sharma",
      "phoneNumber": "+919876543210",
      "role": "senior"
    }
  }
}
```

---

## 3. Family Member Endpoints

### 3.1 Family Registration
- **URL:** `POST /api/v1/auth/register/family`
- **Request Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "fullName": "Aarav Sharma",
  "email": "aarav.sharma@example.com",
  "phoneNumber": "+919812345678",
  "password": "StrongPassword123!",
  "relationshipType": "son",
  "alternatePhone": "+919812345679"
}
```
- **Response `201 Created`:**
```json
{
  "success": true,
  "message": "Family member registered successfully",
  "data": {
    "userId": "e71f3c12-54e5-7a4d-b15e-c61e3e8f25b7",
    "familyProfileId": "f82a4d23-65f6-8b5e-c26f-d72f4f9a36c8",
    "fullName": "Aarav Sharma",
    "role": "family"
  }
}
```

---

### 3.2 Family Login
- **URL:** `POST /api/v1/auth/login/family` (or `POST /api/v1/auth/login`)
- **Request Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "emailOrPhone": "+919812345678",
  "password": "StrongPassword123!",
  "role": "family",
  "deviceUuid": "flutter-android-device-1"
}
```
- **Response `200 OK`:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
    "refresh_token": "f7e6d5c4b3a2...",
    "token_type": "bearer",
    "expires_in": 1800,
    "user": {
      "id": "e71f3c12-54e5-7a4d-b15e-c61e3e8f25b7",
      "fullName": "Aarav Sharma",
      "phoneNumber": "+919812345678",
      "email": "aarav.sharma@example.com",
      "role": "family"
    }
  }
}
```

---

## 4. Caretaker (Caregiver) Endpoints

### 4.1 Caretaker Registration
- **URL:** `POST /api/v1/auth/register/caregiver`
- **Request Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "fullName": "Sunita Verma",
  "phoneNumber": "+919845678901",
  "email": "sunita.verma@example.com",
  "password": "CaregiverPass123!",
  "gender": "female",
  "hourlyRate": 300.0,
  "serviceCity": "Delhi NCR",
  "experienceYears": 5,
  "bio": "Certified geriatric healthcare assistant with elderly mobility training."
}
```
- **Response `201 Created`:**
```json
{
  "success": true,
  "message": "Caregiver registered successfully",
  "data": {
    "userId": "a12b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
    "caregiverProfileId": "b23c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
    "fullName": "Sunita Verma",
    "role": "caregiver"
  }
}
```

---

### 4.2 Caretaker Login
- **URL:** `POST /api/v1/auth/login/caregiver` (or `POST /api/v1/auth/login`)
- **Request Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "emailOrPhone": "+919845678901",
  "password": "CaregiverPass123!",
  "role": "caregiver",
  "deviceUuid": "flutter-android-device-1"
}
```
- **Response `200 OK`:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
    "refresh_token": "9876543210ab...",
    "token_type": "bearer",
    "expires_in": 1800,
    "user": {
      "id": "a12b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
      "fullName": "Sunita Verma",
      "phoneNumber": "+919845678901",
      "email": "sunita.verma@example.com",
      "role": "caregiver"
    }
  }
}
```

---

## 5. Token Refresh & Revocation Endpoints

### 5.1 Single-Use Token Rotation
- **URL:** `POST /api/v1/auth/refresh`
- **Request Body:**
```json
{
  "refreshToken": "a1b2c3d4e5f6...",
  "deviceUuid": "flutter-android-device-1"
}
```
- **Response `200 OK`:**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
    "refresh_token": "new-rotating-token-here...",
    "token_type": "bearer",
    "expires_in": 1800
  }
}
```

---

### 5.2 Server-Side Session Revocation (Logout)
- **URL:** `POST /api/v1/auth/logout`
- **Request Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**
```json
{
  "refreshToken": "new-rotating-token-here..."
}
```
- **Response `200 OK`:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

