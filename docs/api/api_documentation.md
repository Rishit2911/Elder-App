# SeniorCare – REST API Architecture & Endpoint Specification
**Phase 1 Deliverable | Role: Person 2 (API Architect & Backend Designer)**
**Base URL:** `https://api.seniorcare.health/api/v1` (Production) / `http://localhost:8000/api/v1` (Local Dev)
**API Standard:** RESTful JSON with OpenAPI 3.0 Compliance

---

## 1. Global API Conventions & Standards

1. **Authentication:** All protected endpoints require standard HTTP Bearer token authentication:
   `Authorization: Bearer <JWT_ACCESS_TOKEN>`
2. **Standard Response Wrapper:** All successful responses return JSON. Lists are paginated with `items`, `total`, `page`, and `limit`.
3. **Standard Error Payload:**
   ```json
   {
     "error_code": "RESOURCE_NOT_FOUND",
     "message": "The requested health record was not found.",
     "timestamp": "2026-11-06T12:00:00Z",
     "details": null
   }
   ```
4. **Common HTTP Status Codes:**
   * `200 OK`: Request succeeded; entity returned in response body.
   * `201 Created`: Entity successfully created (e.g., SOS triggered, booking requested).
   * `204 No Content`: Successful action with no response body (e.g., delete/revoke).
   * `400 Bad Request`: Invalid input format or business constraint violation.
   * `401 Unauthorized`: Missing, expired, or invalid JWT access token.
   * `403 Forbidden`: Role or ReBAC permission denied for the target resource.
   * `404 Not Found`: Entity not found.
   * `409 Conflict`: Conflict (e.g., phone number already exists, duplicate booking).
   * `422 Unprocessable Entity`: Pydantic schema validation failure.
   * `429 Too Many Requests`: Rate limit exceeded.
   * `500 Internal Server Error`: Unhandled server exception.

---

## 2. Endpoint Catalog by Domain

---

### 2.1 Authentication & Profile Module

#### `POST /auth/register/senior`
* **Purpose:** Register a new senior citizen with basic information and trigger mobile verification OTP.
* **Authentication:** None (Public).
* **Role / Permission:** Public.
* **Request Body:**
  ```json
  {
    "phone_number": "+919876543210",
    "full_name": "Ramesh Sharma",
    "preferred_name": "दादाजी",
    "date_of_birth": "1952-08-15",
    "gender": "male",
    "address": "402, Shanti Niketan, Civil Lines",
    "city": "Jaipur",
    "postal_code": "302006",
    "primary_language": "hi"
  }
  ```
* **Expected Response (`201 Created`):**
  ```json
  {
    "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "message": "OTP sent successfully to +919876543210",
    "otp_expires_in_seconds": 300
  }
  ```
* **Error Responses:** `400 Bad Request`, `409 Conflict` (Phone already registered).

---

#### `POST /auth/register/family`
* **Purpose:** Register a remote family member / guardian account.
* **Authentication:** None (Public).
* **Role / Permission:** Public.
* **Request Body:**
  ```json
  {
    "phone_number": "+919811223344",
    "email": "priya.sharma@example.com",
    "password": "SecurePassword123!",
    "full_name": "Priya Sharma",
    "relationship_description": "Daughter"
  }
  ```
* **Expected Response (`201 Created`):** Returns created user object and verification challenge.

---

#### `POST /auth/login`
* **Purpose:** Standard credential login via phone/email and password.
* **Authentication:** None (Public).
* **Request Body:**
  ```json
  {
    "username": "+919811223344",
    "password": "SecurePassword123!",
    "device_uuid": "device-uuid-abc-123",
    "platform": "android"
  }
  ```
* **Expected Response (`200 OK`):**
  ```json
  {
    "access_token": "eyJhbGciOi...",
    "refresh_token": "dGhpcy1pcy1hLXJlZnJlc2gtdG9rZW4...",
    "token_type": "bearer",
    "expires_in": 900,
    "user": {
      "id": "11111111-2222-3333-4444-555555555555",
      "role": "family",
      "full_name": "Priya Sharma"
    }
  }
  ```
* **Error Responses:** `401 Unauthorized` (Invalid credentials).

---

#### `POST /auth/refresh`
* **Purpose:** Refresh an expired short-lived access token using a rotating refresh token.
* **Authentication:** None (Refresh token provided in body).
* **Request Body:**
  ```json
  {
    "refresh_token": "dGhpcy1pcy1hLXJlZnJlc2gtdG9rZW4...",
    "device_uuid": "device-uuid-abc-123"
  }
  ```
* **Expected Response (`200 OK`):** New `access_token` and rotated `refresh_token`.
* **Error Responses:** `401 Unauthorized` (Revoked or expired token).

---

#### `POST /auth/logout`
* **Purpose:** Revoke the active refresh token and add current access token to the Redis blacklist.
* **Authentication:** Bearer Token.
* **Request Body:** `{"device_uuid": "device-uuid-abc-123"}`
* **Expected Response (`204 No Content`)**

---

#### `GET /users/me`
* **Purpose:** Retrieve the active logged-in user profile, roles, and linked dependencies.
* **Authentication:** Bearer Token.
* **Expected Response (`200 OK`):** Full profile with relevant senior or family profile details.

---

### 2.2 Face Recognition Biometric Module

#### `POST /auth/face/register`
* **Purpose:** Enroll senior's face by uploading 3 high-resolution facial frames for liveness check and ArcFace embedding generation.
* **Authentication:** Bearer Token (`senior` role).
* **Request Body (Multipart Form-Data):**
  * `frame_1`: File (JPEG image, frontal view)
  * `frame_2`: File (JPEG image, slight head turn or blink verification)
  * `frame_3`: File (JPEG image, smiling/neutral)
* **Expected Response (`201 Created`):**
  ```json
  {
    "status": "enrolled",
    "quality_score": 0.94,
    "liveness_verified": true,
    "message": "Face profile successfully registered for passwordless login."
  }
  ```
* **Error Responses:** `400 Bad Request` (Face not detected, blurry image, or spoof attempt detected).

---

#### `POST /auth/face/verify-login`
* **Purpose:** Authenticate senior via camera snapshot without entering a password.
* **Authentication:** None (Public).
* **Request Body (Multipart Form-Data):**
  * `phone_number`: `"+919876543210"`
  * `live_frame`: File (JPEG image)
  * `device_uuid`: `"device-uuid-abc-123"`
* **Expected Response (`200 OK`):**
  ```json
  {
    "match": true,
    "similarity_score": 0.88,
    "access_token": "eyJhbGciOi...",
    "refresh_token": "...",
    "user": {
      "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "role": "senior",
      "name": "दादाजी"
    }
  }
  ```
* **Error Responses:** `401 Unauthorized` (Face mismatch, below threshold 0.65), `429 Too Many Requests`.

---

#### `DELETE /auth/face/profile`
* **Purpose:** Allow senior citizen or guardian to permanently delete biometric embeddings (DPDP / GDPR compliance).
* **Authentication:** Bearer Token (`senior` or authorized `family`).
* **Expected Response (`204 No Content`)**

---

### 2.3 Family Connection & Permission Module

#### `POST /family/invitations`
* **Purpose:** Senior initiates an invitation to a family member via mobile number.
* **Authentication:** Bearer Token (`senior` role).
* **Request Body:**
  ```json
  {
    "invitee_phone": "+919811223344",
    "relation_proposed": "daughter"
  }
  ```
* **Expected Response (`201 Created`):**
  ```json
  {
    "invitation_id": "c1f7a220-410a-48a6-8be8-27b2d56a2981",
    "invitation_code": "INV-784920",
    "expires_at": "2026-11-08T12:00:00Z",
    "status": "pending"
  }
  ```

---

#### `POST /family/invitations/accept`
* **Purpose:** Family member accepts a pending invitation using the received code.
* **Authentication:** Bearer Token (`family` role).
* **Request Body:** `{"invitation_code": "INV-784920"}`
* **Expected Response (`200 OK`):**
  ```json
  {
    "relationship_id": "4e724b0b-36f7-41b4-b91c-7193dc5bc1e7",
    "senior": {
      "id": "senior-uuid-123",
      "name": "दादाजी Ramesh Sharma"
    },
    "status": "active"
  }
  ```

---

#### `GET /family/seniors`
* **Purpose:** Retrieve all seniors connected to the logged-in family member (supporting multi-senior accounts).
* **Authentication:** Bearer Token (`family` role).
* **Expected Response (`200 OK`):** Array of senior summary cards with vital alerts.

---

#### `GET /family/seniors/{senior_id}/permissions`
* **Purpose:** Inspect current ReBAC permissions granted to the logged-in user for this senior.
* **Authentication:** Bearer Token (`family` or `senior`).
* **Expected Response (`200 OK`):** List of modules and their `access_level` (`none`, `view_only`, `full_management`).

---

#### `PUT /family/relationships/{relationship_id}/permissions`
* **Purpose:** Senior updates or restricts permissions for a connected family member.
* **Authentication:** Bearer Token (`senior` role).
* **Request Body:**
  ```json
  {
    "permissions": [
      {"module": "health_records", "level": "view_only"},
      {"module": "medicines", "level": "full_management"},
      {"module": "live_location", "level": "view_only"},
      {"module": "caregiver_bookings", "level": "full_management"}
    ]
  }
  ```
* **Expected Response (`200 OK`)**

---

#### `DELETE /family/relationships/{relationship_id}`
* **Purpose:** Revoke family connection permanently.
* **Authentication:** Bearer Token (`senior` or connected `family`).
* **Expected Response (`204 No Content`)**

---

### 2.4 Healthcare & Medicine Schedules Module

#### `GET /healthcare/seniors/{senior_id}/dashboard-summary`
* **Purpose:** Powers Person 1's Flutter `HomeDashboard` with senior greeting, upcoming dose, health tracker status, and caregiver badge.
* **Authentication:** Bearer Token (`senior` or authorized `family`).
* **Expected Response (`200 OK`):**
  ```json
  {
    "senior_name": "दादाजी",
    "greeting": "नमस्ते दादाजी",
    "subtitle": "Take care and stay healthy!",
    "profile_image_url": "https://api.seniorcare.health/assets/images/dadaji_profile.png",
    "next_medicine": {
      "id": "med-uuid-1",
      "name": "Metformin 500mg",
      "time": "14:00:00",
      "meal_relation": "after_meal",
      "dose": "1 tablet"
    },
    "recent_vitals": {
      "bp": "120/80",
      "sugar": "110 mg/dL",
      "recorded_at": "2026-11-06T08:30:00Z"
    },
    "caregiver_status": "No active booking for today",
    "unread_notifications_count": 2
  }
  ```

---

#### `GET /healthcare/seniors/{senior_id}/medicines`
* **Purpose:** Retrieve active medicine list for "My Medicines" card and "Reminders" tab.
* **Authentication:** Bearer Token.
* **ReBAC Requirement:** `medicines:view_only`.
* **Expected Response (`200 OK`):** Array of medicines with schedules and intake history.

---

#### `POST /healthcare/seniors/{senior_id}/medicines`
* **Purpose:** Add a new medicine and generate recurring schedules.
* **Authentication:** Bearer Token.
* **ReBAC Requirement:** `medicines:full_management`.
* **Request Body:**
  ```json
  {
    "name": "Amlodipine 5mg",
    "dosage_strength": "5mg",
    "form": "tablet",
    "meal_relation": "after_meal",
    "start_date": "2026-11-06",
    "instructions": "Take with water in the morning",
    "schedules": [
      {"time_of_day": "09:00:00", "dose_quantity": 1.0}
    ]
  }
  ```
* **Expected Response (`201 Created`)**

---

#### `POST /healthcare/medicines/logs`
* **Purpose:** Record senior taking, snoozing, or missing a scheduled medicine.
* **Authentication:** Bearer Token.
* **Request Body:**
  ```json
  {
    "schedule_id": "sched-uuid-456",
    "senior_id": "senior-uuid-123",
    "scheduled_timestamp": "2026-11-06T09:00:00Z",
    "status": "taken",
    "notes": "Taken on time after breakfast"
  }
  ```
* **Expected Response (`200 OK`)**

---

#### `GET /healthcare/seniors/{senior_id}/records`
* **Purpose:** Retrieve health tracker vitals history and medical documents.
* **Authentication:** Bearer Token.
* **ReBAC Requirement:** `health_records:view_only`.
* **Query Parameters:** `record_type`, `from_date`, `to_date`, `page`, `limit`.
* **Expected Response (`200 OK`):** Paginated records list with vital signs and secure expiring S3 download links.

---

#### `POST /healthcare/seniors/{senior_id}/records`
* **Purpose:** Add vitals reading (BP, Sugar, Pulse) or upload doctor discharge summary.
* **Authentication:** Bearer Token.
* **ReBAC Requirement:** `health_records:full_management`.
* **Request Body:**
  ```json
  {
    "title": "Evening Blood Pressure",
    "record_type": "vitals",
    "recorded_at": "2026-11-06T18:00:00Z",
    "vital_bp_systolic": 128,
    "vital_bp_diastolic": 82,
    "vital_heart_rate": 72,
    "notes": "Felt completely normal"
  }
  ```
* **Expected Response (`201 Created`)**

---

### 2.5 Emergency SOS Module

#### `POST /emergency/sos`
* **Purpose:** Immediate emergency trigger from Person 1's `SOSCard`.
* **Authentication:** Bearer Token (`senior` role).
* **Request Body:**
  ```json
  {
    "latitude": 26.9124,
    "longitude": 75.7873,
    "approximate_address": "Civil Lines, Jaipur, Rajasthan",
    "trigger_source": "in_app_button",
    "battery_level_percent": 84
  }
  ```
* **Expected Response (`201 Created`):**
  ```json
  {
    "sos_event_id": "sos-uuid-999",
    "status": "active",
    "triggered_at": "2026-11-06T12:35:10Z",
    "notified_contacts_count": 3,
    "message": "Emergency broadcast initiated. Family alerted via push and SMS."
  }
  ```
* **SLA:** Response returns within $< 800\text{ ms}$; Celery background worker dispatches FCM pushes and SMS concurrently.

---

#### `POST /emergency/sos/{event_id}/resolve`
* **Purpose:** Close an active SOS incident after help arrives or dismiss a false alarm.
* **Authentication:** Bearer Token (`senior` or linked `family`).
* **Request Body:**
  ```json
  {
    "resolution_status": "resolved",
    "notes": "Caregiver arrived, senior is stable."
  }
  ```
* **Expected Response (`200 OK`)**

---

#### `GET /emergency/contacts`
* **Purpose:** Retrieve configured emergency dial list for the senior.
* **Authentication:** Bearer Token.
* **Expected Response (`200 OK`):** List of prioritized emergency contacts.

---

### 2.6 Caregiver Booking & Verification Module

#### `GET /caregivers/search`
* **Purpose:** Search and filter verified caregivers for Person 1's "Book a Caregiver" card.
* **Authentication:** Bearer Token.
* **Query Parameters:** `city`, `service_category`, `min_rating`, `max_hourly_rate`, `gender`, `page`, `limit`.
* **Expected Response (`200 OK`):** Paginated list of caregiver summary profiles with reviews and rates.

---

#### `GET /caregivers/{caregiver_id}`
* **Purpose:** Inspect detailed profile, badges, experience, qualifications, and reviews.
* **Authentication:** Bearer Token.
* **Expected Response (`200 OK`):** Full profile detail.

---

#### `POST /caregivers/bookings`
* **Purpose:** Create a booking request for home care.
* **Authentication:** Bearer Token (`family` or `senior`).
* **ReBAC Requirement:** `caregiver_bookings:full_management`.
* **Request Body:**
  ```json
  {
    "senior_id": "senior-uuid-123",
    "caregiver_id": "caregiver-uuid-456",
    "service_id": "service-uuid-789",
    "booking_type": "daily",
    "start_datetime": "2026-11-10T09:00:00Z",
    "end_datetime": "2026-11-10T17:00:00Z",
    "special_instructions": "Dadaji needs assistance with walking and lunch."
  }
  ```
* **Expected Response (`201 Created`):** Booking object with status `requested` and computed fee.

---

#### `GET /caregivers/bookings/{booking_id}/visit-report`
* **Purpose:** View shift visit report (vitals recorded, meal notes, photos) submitted by caregiver.
* **Authentication:** Bearer Token.
* **Expected Response (`200 OK`)**

---

### 2.7 AI Voice Assistant & RAG Module

#### `POST /assistant/chat`
* **Purpose:** Powers the "Ask Me Anything" voice assistant card. Handles spoken or typed questions.
* **Authentication:** Bearer Token (`senior` role).
* **Request Body:**
  ```json
  {
    "message": "दादाजी को आज शाम को कौन सी दवाई लेनी है?",
    "audio_input_url": null,
    "language": "hi"
  }
  ```
* **Expected Response (`200 OK`):**
  ```json
  {
    "reply_text": "दादाजी, आज शाम 8:00 बजे आपको खाने के बाद Metformin 500mg लेनी है। क्या मैं आपके लिए पानी का रिमाइंडर लगा दूँ?",
    "audio_tts_url": "https://api.seniorcare.health/audio/tts/cache-992.mp3",
    "action_triggered": null
  }
  ```

---

### 2.8 Doctor Consultations & Nearby Hospitals Module

#### `GET /consultations/nearby-hospitals`
* **Purpose:** Powers the "Nearby Hospitals" card on Person 1's Home Dashboard.
* **Authentication:** Bearer Token.
* **Query Parameters:** `latitude`, `longitude`, `radius_km`.
* **Expected Response (`200 OK`):**
  ```json
  {
    "hospitals": [
      {
        "name": "SMS Hospital & Emergency Care",
        "distance_km": 2.4,
        "emergency_helpline": "108",
        "phone": "+911412560291",
        "address": "Jawaharlal Nehru Marg, Jaipur",
        "has_cardiac_emergency": true
      }
    ]
  }
  ```

---

#### `POST /consultations/appointments`
* **Purpose:** Book doctor appointment for "Talk to a Doctor" card.
* **Authentication:** Bearer Token.
* **Request Body:** Doctor ID, senior ID, scheduled time, consultation type (`video_consult` or `clinic_visit`).
* **Expected Response (`201 Created`)**

---

### 2.9 Notifications & Family Moments Module

#### `GET /notifications`
* **Purpose:** Retrieve user notifications list with read/unread flags.
* **Authentication:** Bearer Token.
* **Expected Response (`200 OK`):** Array of notification cards with deep links.

---

#### `GET /family/updates/moments`
* **Purpose:** Feed of family photos, greeting messages, and milestones displayed on "My Family" screen.
* **Authentication:** Bearer Token.
* **Expected Response (`200 OK`):** Timeline moments list with photos and captions.

