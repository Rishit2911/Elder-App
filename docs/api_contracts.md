# SeniorCare Platform — Phase 2 REST API Contracts

**Version:** 1.0.0 (Phase 2)  
**Base URL:** `/api/v1`  
**Authentication Scheme:** `Bearer <JWT_ACCESS_TOKEN>` in `Authorization` header  

---

## 1. Authentication & Registration Endpoints

### 1.1 Universal User Registration
* **Endpoint:** `POST /api/v1/auth/register`
* **Auth Required:** No
* **Description:** Used directly by Flutter `RegistrationScreen`. Registers a senior, family member, or caregiver.
* **Request Body:**
  ```json
  {
    "fullName": "Ramesh Sharma",
    "email": "ramesh@example.com",
    "phoneNumber": "+919876543210",
    "password": "SecurePassword123",
    "role": "senior"
  }
  ```
* **Success Response (201 Created):**
  ```json
  {
    "success": true,
    "message": "User registered successfully",
    "data": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "fullName": "Ramesh Sharma",
      "email": "ramesh@example.com",
      "phoneNumber": "+919876543210",
      "role": "senior",
      "isVerified": false,
      "createdAt": "2026-11-10T12:00:00Z"
    }
  }
  ```

### 1.2 Senior Citizen Registration (Specialized)
* **Endpoint:** `POST /api/v1/auth/register/senior`
* **Auth Required:** Optional (supports self-registration or assisted registration by family member)
* **Request Body:**
  ```json
  {
    "fullName": "Ramesh Sharma",
    "phoneNumber": "+919876543210",
    "email": "ramesh@example.com",
    "password": "OptionalPassword123",
    "dateOfBirth": "1952-05-15",
    "bloodGroup": "B+",
    "gender": "male",
    "address": "123 Green Valley, Delhi",
    "assistedByUserId": null
  }
  ```
* **Success Response (201 Created):**
  ```json
  {
    "success": true,
    "message": "Senior citizen registered successfully",
    "data": {
      "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "seniorProfileId": "7b85f64-5717-4562-b3fc-2c963f66afa7",
      "fullName": "Ramesh Sharma",
      "role": "senior"
    }
  }
  ```

### 1.3 Family Member Registration
* **Endpoint:** `POST /api/v1/auth/register/family`
* **Auth Required:** No
* **Request Body:**
  ```json
  {
    "fullName": "Rajesh Sharma",
    "email": "rajesh@example.com",
    "phoneNumber": "+919876543211",
    "password": "StrongPassword123!",
    "relationshipType": "son"
  }
  ```
* **Success Response (201 Created):**
  ```json
  {
    "success": true,
    "message": "Family member registered successfully",
    "data": {
      "userId": "4fa85f64-5717-4562-b3fc-2c963f66afa8",
      "fullName": "Rajesh Sharma",
      "role": "family"
    }
  }
  ```

### 1.4 User Login (Universal & Family)
* **Endpoint:** `POST /api/v1/auth/login` (and alias `POST /api/v1/auth/login/family`)
* **Auth Required:** No
* **Request Body:**
  ```json
  {
    "emailOrPhone": "rajesh@example.com",
    "password": "StrongPassword123!",
    "role": "family",
    "deviceId": "flutter-android-device-uuid"
  }
  ```
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Login successful",
    "data": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "d8e8f8...",
      "tokenType": "bearer",
      "expiresIn": 900,
      "user": {
        "id": "4fa85f64-5717-4562-b3fc-2c963f66afa8",
        "fullName": "Rajesh Sharma",
        "email": "rajesh@example.com",
        "phoneNumber": "+919876543211",
        "role": "family"
      }
    }
  }
  ```

### 1.5 Refresh Token Rotation
* **Endpoint:** `POST /api/v1/auth/refresh`
* **Auth Required:** No (Token supplied in body)
* **Request Body:**
  ```json
  {
    "refreshToken": "d8e8f8...",
    "deviceId": "flutter-android-device-uuid"
  }
  ```
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Token refreshed successfully",
    "data": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "f9a0b1...",
      "tokenType": "bearer",
      "expiresIn": 900
    }
  }
  ```

### 1.6 User Logout
* **Endpoint:** `POST /api/v1/auth/logout`
* **Auth Required:** Yes (`Bearer <JWT>`)
* **Request Body:**
  ```json
  {
    "refreshToken": "d8e8f8..."
  }
  ```
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Logged out successfully"
  }
  ```

### 1.7 Current Authenticated User (`/auth/me`)
* **Endpoint:** `GET /api/v1/auth/me`
* **Auth Required:** Yes (`Bearer <JWT>`)
* **Success Response (200 OK):** Returns current user account and role.

---

## 2. Biometric Face Authentication Endpoints

### 2.1 Face Enrollment
* **Endpoint:** `POST /api/v1/auth/face/enroll`
* **Auth Required:** Yes (`Bearer <JWT>` of senior or assisting representative)
* **Content-Type:** `multipart/form-data`
* **Form Fields:**
  - `senior_id`: UUID
  - `face_image`: binary image file (JPEG / PNG, max 5MB)
  - `consent_id`: UUID (reference to explicit `user_consents` record)
* **Success Response (201 Created):**
  ```json
  {
    "success": true,
    "message": "Face biometric enrolled and encrypted successfully",
    "data": {
      "faceProfileId": "9fa85f64-5717-4562-b3fc-2c963f66afb0",
      "qualityScore": 0.94,
      "modelVersion": "arcface-512-v1",
      "enrolledAt": "2026-11-10T12:05:00Z"
    }
  }
  ```

### 2.2 Face Verification & Biometric Login
* **Endpoint:** `POST /api/v1/auth/face/verify`
* **Auth Required:** No
* **Content-Type:** `multipart/form-data`
* **Form Fields:**
  - `identifier`: string (email or phone number of senior)
  - `face_image`: binary image file
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Biometric face verification successful",
    "data": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "e7b1a2...",
      "tokenType": "bearer",
      "user": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "fullName": "Ramesh Sharma",
        "role": "senior"
      }
    }
  }
  ```

---

## 3. Family-Senior Account Linking Endpoints

### 3.1 Request Connection / Generate Invitation
* **Endpoint:** `POST /api/v1/family/link/request`
* **Auth Required:** Yes (`Bearer <JWT>` of family member or senior)
* **Request Body:**
  ```json
  {
    "targetPhone": "+919876543210",
    "relationship": "son",
    "customRelationship": "Eldest Son"
  }
  ```
* **Success Response (201 Created):**
  ```json
  {
    "success": true,
    "message": "Connection request created successfully",
    "data": {
      "invitationId": "5fa85f64-5717-4562-b3fc-2c963f66afc1",
      "invitationCode": "SC-982143",
      "status": "pending",
      "expiresAt": "2026-11-17T12:00:00Z"
    }
  }
  ```

### 3.2 Approve Connection Request
* **Endpoint:** `POST /api/v1/family/link/approve`
* **Auth Required:** Yes (`Bearer <JWT>` of senior citizen)
* **Request Body:**
  ```json
  {
    "invitationId": "5fa85f64-5717-4562-b3fc-2c963f66afc1",
    "approved": true,
    "permissions": {
      "canViewRecords": true,
      "canManageMedications": true,
      "canBookServices": true,
      "emergencyPriority": 1
    }
  }
  ```
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Family connection approved and permissions assigned",
    "data": {
      "relationshipId": "6fa85f64-5717-4562-b3fc-2c963f66afd2",
      "status": "active"
    }
  }
  ```

### 3.3 List Active Family Links
* **Endpoint:** `GET /api/v1/family/links`
* **Auth Required:** Yes (`Bearer <JWT>`)
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Links retrieved successfully",
    "data": [
      {
        "id": "6fa85f64-5717-4562-b3fc-2c963f66afd2",
        "seniorId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "seniorName": "Ramesh Sharma",
        "familyUserId": "4fa85f64-5717-4562-b3fc-2c963f66afa8",
        "familyName": "Rajesh Sharma",
        "relationship": "son",
        "status": "active",
        "permissions": {
          "canViewRecords": true,
          "canManageMedications": true,
          "canBookServices": true
        }
      }
    ]
  }
  ```

### 3.4 Update Permissions & Revocation
* **`PATCH /api/v1/family/links/{id}/permissions`**: Update granular permission toggles.
* **`POST /api/v1/family/links/{id}/revoke`**: Terminate relationship link instantly.

---

## 4. User Profile Management Endpoints

* **`GET /api/v1/users/me`**: Returns complete user profile and role details.
* **`PATCH /api/v1/users/me`**: Updates permitted personal fields (name, language, phone, address).
* **`GET /api/v1/users/{user_id}`**: Retrieves user profile subject to relationship ReBAC permission checks.

