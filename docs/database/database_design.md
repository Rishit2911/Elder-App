# SeniorCare – Database Schema & Architecture Design
**Phase 1 Deliverable | Role: Person 2 (Database Designer & API Architect)**
**Target Engine:** PostgreSQL 16+ (with `pgcrypto` and `uuid-ossp` extensions)

---

## 1. Database Architecture & Design Standards

To satisfy the demanding requirements of a mission-critical elderly care and healthcare platform, the schema adheres to the following core engineering standards:

1. **UUIDv4 Primary Keys:** All entity primary keys use 128-bit RFC 4122 UUIDs (`UUID`) generated via `gen_random_uuid()` to prevent enumeration attacks, allow offline/distributed ID generation, and facilitate database sharding.
2. **Strict Referential Integrity:** Foreign keys enforce explicit `ON DELETE` semantics (e.g., `CASCADE` for child logs or profiles, `RESTRICT` for critical audit/billing entities, `SET NULL` for optional references).
3. **Time Zone Awareness:** All temporal fields use `TIMESTAMP WITH TIME ZONE` (`TIMESTAMPTZ`) defaulted to `CURRENT_TIMESTAMP` to accurately track operations across time zones.
4. **Relationship-Based Access Control (ReBAC) Modeling:** The database models a Many-to-Many relationship between seniors and family members via `family_relationships`, coupled with an explicit, granular `access_permissions` table.
5. **No Raw Biometrics or File Blobs:**
   - Raw face photographs are never stored. The `face_profiles` table stores encrypted 512-dimensional embedding vectors (`BYTEA`) protected by AES-256-GCM.
   - Medical scans, prescriptions, and identity verification proofs are stored in private S3 object storage; database tables store secure URI keys and cryptographic file hashes (`SHA-256`).
6. **Optimized Indexing:** B-Tree indexes are applied to foreign keys, search tokens, filter flags, and composite queries (`senior_id` + `scheduled_time`).

---

## 2. Comprehensive Module Schema Specifications

### Module A: User Management

#### 1. `users`
Central identity table storing core authentication and account credentials.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `email` (`VARCHAR(255)`, UNIQUE, NULLABLE) - Optional for seniors who register via mobile phone.
  * `phone_number` (`VARCHAR(20)`, UNIQUE, NOT NULL) - Primary contact for OTP, login, and alerts.
  * `hashed_password` (`VARCHAR(255)`, NULLABLE) - Argon2id password hash (null for passwordless biometric/OTP seniors).
  * `role` (`VARCHAR(30)`, NOT NULL) - Enum check: `senior`, `family`, `caregiver`, `doctor`, `admin`.
  * `is_active` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`) - Account status flag.
  * `is_verified` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`) - Identity verification status.
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints & Indexes:**
  * Unique: `email` (where not null), `phone_number`.
  * Index: `idx_users_phone`, `idx_users_role`.

#### 2. `senior_profiles`
Specific demographic and medical baseline profile for elderly users.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, UNIQUE, NOT NULL)
  * `full_name` (`VARCHAR(150)`, NOT NULL) - e.g., "Dadaji Ramesh Sharma".
  * `preferred_name` (`VARCHAR(100)`, NULLABLE) - Display name used in greeting (e.g., "दादाजी").
  * `date_of_birth` (`DATE`, NOT NULL)
  * `gender` (`VARCHAR(20)`, NOT NULL) - `male`, `female`, `other`.
  * `blood_group` (`VARCHAR(5)`, NULLABLE) - `A+`, `O+`, `B+`, etc.
  * `address` (`TEXT`, NOT NULL) - Physical home address for caregiver visits & emergency dispatch.
  * `city` (`VARCHAR(100)`, NOT NULL)
  * `postal_code` (`VARCHAR(20)`, NOT NULL)
  * `latitude` (`DECIMAL(10, 8)`, NULLABLE) - Geolocation for SOS and nearby hospitals.
  * `longitude` (`DECIMAL(11, 8)`, NULLABLE)
  * `primary_language` (`VARCHAR(20)`, NOT NULL, `DEFAULT 'hi'`) - Hindi, English, etc.
  * `emergency_notes` (`TEXT`, NULLABLE) - Critical notes (e.g., "Diabetic, pacemaker installed").
  * `profile_picture_url` (`VARCHAR(500)`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints & Indexes:**
  * Unique: `user_id`.
  * Index: `idx_seniors_city_geo` (`city`, `latitude`, `longitude`).

#### 3. `family_profiles`
Profile of relatives or legal guardians caring for seniors remotely.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, UNIQUE, NOT NULL)
  * `full_name` (`VARCHAR(150)`, NOT NULL)
  * `alternate_phone` (`VARCHAR(20)`, NULLABLE)
  * `relationship_description` (`VARCHAR(100)`, NULLABLE) - e.g., "Eldest Son", "Granddaughter".
  * `notification_preferences_json` (`JSONB`, `DEFAULT '{}'`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 4. `caregiver_profiles`
Professional caregivers offering home assistance and nursing care.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, UNIQUE, NOT NULL)
  * `full_name` (`VARCHAR(150)`, NOT NULL)
  * `gender` (`VARCHAR(20)`, NOT NULL)
  * `bio` (`TEXT`, NULLABLE)
  * `experience_years` (`INTEGER`, NOT NULL, `DEFAULT 0`)
  * `hourly_rate` (`DECIMAL(10, 2)`, NOT NULL) - Hourly fee in INR.
  * `daily_rate` (`DECIMAL(10, 2)`, NULLABLE) - Full day fee in INR.
  * `verification_status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'pending'`) - `pending`, `verified`, `rejected`, `suspended`.
  * `police_clearance_verified` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `medical_training_verified` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `rating_average` (`DECIMAL(3, 2)`, NOT NULL, `DEFAULT 0.00`)
  * `total_reviews` (`INTEGER`, NOT NULL, `DEFAULT 0`)
  * `is_available_for_hire` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `service_city` (`VARCHAR(100)`, NOT NULL)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Indexes:**
  * Index: `idx_caregivers_city_verified` (`service_city`, `verification_status`, `is_available_for_hire`).

#### 5. `doctor_profiles`
Licensed medical doctors providing teleconsultations and prescription oversight.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, UNIQUE, NOT NULL)
  * `full_name` (`VARCHAR(150)`, NOT NULL)
  * `specialization` (`VARCHAR(100)`, NOT NULL) - Geriatrician, Cardiologist, Physician.
  * `medical_license_number` (`VARCHAR(100)`, UNIQUE, NOT NULL)
  * `qualifications` (`VARCHAR(200)`, NOT NULL) - e.g., "MBBS, MD (Medicine)".
  * `hospital_affiliation` (`VARCHAR(200)`, NULLABLE)
  * `consultation_fee` (`DECIMAL(10, 2)`, NOT NULL)
  * `is_verified` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `rating_average` (`DECIMAL(3, 2)`, NOT NULL, `DEFAULT 0.00`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

---

### Module B: Family Connections & ReBAC Permissions

#### 6. `family_relationships`
Represents verified links connecting senior citizens and family members.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `family_user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, NOT NULL)
  * `relation_type` (`VARCHAR(50)`, NOT NULL) - `son`, `daughter`, `spouse`, `grandchild`, `guardian`, `other`.
  * `is_primary_caregiver_contact` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `is_emergency_contact` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'active'`) - `active`, `paused`, `revoked`.
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints:**
  * Unique: `uq_senior_family_link` (`senior_id`, `family_user_id`).
  * Index: `idx_rel_senior`, `idx_rel_family`.

#### 7. `family_invitations`
Handles the secure invitation flow when seniors invite family members or vice versa.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `inviter_user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, NOT NULL)
  * `invitee_phone` (`VARCHAR(20)`, NOT NULL)
  * `invitee_email` (`VARCHAR(255)`, NULLABLE)
  * `invitation_code` (`VARCHAR(64)`, UNIQUE, NOT NULL) - High-entropy URL-safe cryptographic token.
  * `relation_proposed` (`VARCHAR(50)`, NOT NULL)
  * `status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'pending'`) - `pending`, `accepted`, `rejected`, `expired`, `cancelled`.
  * `expires_at` (`TIMESTAMPTZ`, NOT NULL)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints:**
  * Index: `idx_invitations_code` (`invitation_code`), `idx_invitations_status` (`invitee_phone`, `status`).

#### 8. `access_permissions`
Granular, per-feature access rights delegated by a senior to a linked family member.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `relationship_id` (`UUID`, FK `family_relationships.id` ON DELETE CASCADE, NOT NULL)
  * `permission_module` (`VARCHAR(50)`, NOT NULL) - `health_records`, `medicines`, `live_location`, `caregiver_bookings`, `doctor_consultations`, `financial_billing`.
  * `access_level` (`VARCHAR(20)`, NOT NULL) - `none`, `view_only`, `full_management`.
  * `granted_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints:**
  * Unique: `uq_rel_permission_module` (`relationship_id`, `permission_module`).

---

### Module C: Authentication, Sessions & Face Biometrics

#### 9. `devices`
Tracks registered physical devices and their push notification tokens.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, NOT NULL)
  * `device_uuid` (`VARCHAR(100)`, NOT NULL)
  * `fcm_token` (`TEXT`, NULLABLE) - FCM Registration token for push alerts.
  * `platform` (`VARCHAR(20)`, NOT NULL) - `android`, `ios`, `web`.
  * `device_model` (`VARCHAR(100)`, NULLABLE)
  * `app_version` (`VARCHAR(20)`, NULLABLE)
  * `last_active_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints:**
  * Unique: `uq_user_device` (`user_id`, `device_uuid`).

#### 10. `refresh_tokens`
Stores hashed cryptographic refresh tokens for rotating JWT sessions.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, NOT NULL)
  * `device_id` (`UUID`, FK `devices.id` ON DELETE CASCADE, NOT NULL)
  * `token_hash` (`VARCHAR(255)`, UNIQUE, NOT NULL) - SHA-256 hash of refresh token.
  * `expires_at` (`TIMESTAMPTZ`, NOT NULL)
  * `is_revoked` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Indexes:**
  * Index: `idx_refresh_lookup` (`token_hash`, `is_revoked`).

#### 11. `login_sessions`
Security audit trail recording login attempts and active connections.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, NOT NULL)
  * `auth_method` (`VARCHAR(30)`, NOT NULL) - `password`, `face_recognition`, `otp_sms`.
  * `ip_address` (`VARCHAR(45)`, NULLABLE)
  * `user_agent` (`TEXT`, NULLABLE)
  * `is_successful` (`BOOLEAN`, NOT NULL)
  * `failure_reason` (`VARCHAR(100)`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 12. `face_profiles`
Encrypted biometric templates for senior face recognition login.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, UNIQUE, NOT NULL)
  * `encrypted_embedding` (`BYTEA`, NOT NULL) - AES-256-GCM ciphertext of 512-D float array.
  * `encryption_iv` (`BYTEA`, NOT NULL) - Initialization vector (12 bytes) for GCM.
  * `encryption_tag` (`BYTEA`, NOT NULL) - Authentication tag (16 bytes) for GCM integrity.
  * `model_version` (`VARCHAR(50)`, NOT NULL) - `arcface_r50_v1`.
  * `quality_score` (`DECIMAL(4, 3)`, NOT NULL) - Image quality metric (0.0 to 1.0).
  * `liveness_score` (`DECIMAL(4, 3)`, NOT NULL) - Anti-spoofing confidence.
  * `is_active` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints:**
  * Unique: `user_id`.

---

### Module D: Healthcare & Medicine Schedules

#### 13. `health_records`
Stores vital signs, lab reports, doctor summaries, and health metrics.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `title` (`VARCHAR(200)`, NOT NULL) - e.g., "Blood Sugar Report - Post Meal".
  * `record_type` (`VARCHAR(50)`, NOT NULL) - `vitals`, `lab_test`, `doctor_summary`, `discharge_summary`, `vaccination`.
  * `recorded_at` (`TIMESTAMPTZ`, NOT NULL)
  * `recorded_by_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `vital_bp_systolic` (`INTEGER`, NULLABLE)
  * `vital_bp_diastolic` (`INTEGER`, NULLABLE)
  * `vital_heart_rate` (`INTEGER`, NULLABLE)
  * `vital_blood_glucose` (`DECIMAL(5, 1)`, NULLABLE)
  * `vital_oxygen_saturation` (`DECIMAL(4, 1)`, NULLABLE)
  * `vital_temperature` (`DECIMAL(4, 1)`, NULLABLE)
  * `notes` (`TEXT`, NULLABLE)
  * `document_s3_key` (`VARCHAR(500)`, NULLABLE)
  * `document_file_hash` (`VARCHAR(64)`, NULLABLE) - SHA-256 of attachment.
  * `document_mime_type` (`VARCHAR(100)`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Indexes:**
  * Index: `idx_health_senior_date` (`senior_id`, `recorded_at` DESC).

#### 14. `prescriptions`
Prescriptions uploaded by doctors or family members.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `prescribing_doctor_id` (`UUID`, FK `doctor_profiles.id` ON DELETE SET NULL, NULLABLE)
  * `prescribing_doctor_name` (`VARCHAR(150)`, NULLABLE) - Fallback for external clinics.
  * `diagnosis` (`TEXT`, NULLABLE)
  * `issued_date` (`DATE`, NOT NULL)
  * `valid_until` (`DATE`, NULLABLE)
  * `document_s3_key` (`VARCHAR(500)`, NULLABLE)
  * `notes` (`TEXT`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 15. `medicines`
Catalog of medications prescribed to a senior citizen.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `prescription_id` (`UUID`, FK `prescriptions.id` ON DELETE SET NULL, NULLABLE)
  * `name` (`VARCHAR(150)`, NOT NULL) - e.g., "Metformin 500mg".
  * `dosage_strength` (`VARCHAR(50)`, NOT NULL) - e.g., "500 mg".
  * `form` (`VARCHAR(30)`, NOT NULL) - `tablet`, `capsule`, `syrup`, `injection`, `drops`.
  * `meal_relation` (`VARCHAR(30)`, NOT NULL) - `before_meal`, `after_meal`, `with_meal`, `empty_stomach`.
  * `color_code` (`VARCHAR(10)`, NULLABLE) - Hex color for easy visual identification by seniors.
  * `start_date` (`DATE`, NOT NULL)
  * `end_date` (`DATE`, NULLABLE)
  * `instructions` (`TEXT`, NULLABLE) - Hindi/English guidance (e.g., "पानी के साथ लें").
  * `is_active` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 16. `medicine_schedules`
Defines timing patterns for each daily medicine dose.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `medicine_id` (`UUID`, FK `medicines.id` ON DELETE CASCADE, NOT NULL)
  * `time_of_day` (`TIME`, NOT NULL) - e.g., `09:00:00`, `20:00:00`.
  * `days_of_week` (`INTEGER[]`, NULLABLE) - Array `[1,2,3,4,5,6,7]` where 1 = Monday; null means every day.
  * `dose_quantity` (`DECIMAL(3, 1)`, NOT NULL, `DEFAULT 1.0`)
  * `reminder_lead_minutes` (`INTEGER`, NOT NULL, `DEFAULT 10`)
* **Indexes:**
  * Index: `idx_schedules_time` (`time_of_day`).

#### 17. `medicine_logs`
Tracks intake adherence when a senior accepts or misses a dose.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `schedule_id` (`UUID`, FK `medicine_schedules.id` ON DELETE CASCADE, NOT NULL)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `scheduled_timestamp` (`TIMESTAMPTZ`, NOT NULL)
  * `status` (`VARCHAR(30)`, NOT NULL) - `taken`, `missed`, `skipped`, `snoozed`.
  * `logged_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `acknowledged_by_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `notes` (`TEXT`, NULLABLE)
* **Constraints & Indexes:**
  * Unique: `uq_schedule_dose` (`schedule_id`, `scheduled_timestamp`).
  * Index: `idx_medlogs_senior_status` (`senior_id`, `status`, `scheduled_timestamp`).

---

### Module E: Caregiver Services & Bookings

#### 18. `services`
Catalog of caregiving services available for booking (e.g., Elderly Day Care, Post-Op Nursing).
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `title` (`VARCHAR(150)`, NOT NULL)
  * `category` (`VARCHAR(50)`, NOT NULL) - `daily_companion`, `nursing_care`, `physiotherapy`, `mobility_support`.
  * `description` (`TEXT`, NOT NULL)
  * `base_hourly_rate` (`DECIMAL(10, 2)`, NOT NULL)
  * `icon_key` (`VARCHAR(50)`, NULLABLE)
  * `is_active` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)

#### 19. `caregiver_qualifications`
Educational degrees, nursing diplomas, and training certifications.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `caregiver_id` (`UUID`, FK `caregiver_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `qualification_title` (`VARCHAR(200)`, NOT NULL)
  * `institution` (`VARCHAR(200)`, NOT NULL)
  * `year_completed` (`INTEGER`, NOT NULL)
  * `certificate_s3_key` (`VARCHAR(500)`, NULLABLE)
  * `is_verified` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)

#### 20. `caregiver_verification_documents`
KYC, Police Clearance, and government ID cards.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `caregiver_id` (`UUID`, FK `caregiver_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `document_type` (`VARCHAR(50)`, NOT NULL) - `aadhaar`, `pan_card`, `police_verification`, `nursing_council_cert`.
  * `document_number` (`VARCHAR(100)`, NOT NULL)
  * `document_s3_key` (`VARCHAR(500)`, NOT NULL)
  * `verification_status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'pending'`) - `pending`, `verified`, `rejected`.
  * `reviewed_by_admin_id` (`UUID`, FK `users.id` ON DELETE SET NULL, NULLABLE)
  * `rejection_reason` (`TEXT`, NULLABLE)
  * `reviewed_at` (`TIMESTAMPTZ`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 21. `caregiver_availability`
Weekly recurring schedule of availability for caregivers.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `caregiver_id` (`UUID`, FK `caregiver_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `day_of_week` (`INTEGER`, NOT NULL) - 1 (Monday) through 7 (Sunday).
  * `start_time` (`TIME`, NOT NULL)
  * `end_time` (`TIME`, NOT NULL)
  * `is_active` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)

#### 22. `bookings`
Service contract between a senior (or family member) and a professional caregiver.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE RESTRICT, NOT NULL)
  * `booked_by_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `caregiver_id` (`UUID`, FK `caregiver_profiles.id` ON DELETE RESTRICT, NOT NULL)
  * `service_id` (`UUID`, FK `services.id` ON DELETE RESTRICT, NOT NULL)
  * `booking_type` (`VARCHAR(30)`, NOT NULL) - `hourly`, `daily`, `weekly`, `monthly`.
  * `start_datetime` (`TIMESTAMPTZ`, NOT NULL)
  * `end_datetime` (`TIMESTAMPTZ`, NOT NULL)
  * `special_instructions` (`TEXT`, NULLABLE)
  * `total_hours` (`DECIMAL(5, 2)`, NOT NULL)
  * `hourly_rate_agreed` (`DECIMAL(10, 2)`, NOT NULL)
  * `total_amount` (`DECIMAL(10, 2)`, NOT NULL)
  * `payment_status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'unpaid'`) - `unpaid`, `escrow_held`, `paid`, `refunded`.
  * `status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'requested'`) - `requested`, `confirmed`, `in_progress`, `completed`, `cancelled`.
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Indexes:**
  * Index: `idx_bookings_senior` (`senior_id`), `idx_bookings_caregiver` (`caregiver_id`, `status`).

#### 23. `booking_status_history`
Audit log recording every lifecycle state change in a booking.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `booking_id` (`UUID`, FK `bookings.id` ON DELETE CASCADE, NOT NULL)
  * `previous_status` (`VARCHAR(30)`, NULLABLE)
  * `new_status` (`VARCHAR(30)`, NOT NULL)
  * `changed_by_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `reason_or_notes` (`TEXT`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 24. `caregiver_visit_reports`
Detailed report filed by the caregiver at the end of each shift.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `booking_id` (`UUID`, FK `bookings.id` ON DELETE CASCADE, NOT NULL)
  * `caregiver_id` (`UUID`, FK `caregiver_profiles.id` ON DELETE RESTRICT, NOT NULL)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE RESTRICT, NOT NULL)
  * `check_in_time` (`TIMESTAMPTZ`, NOT NULL)
  * `check_out_time` (`TIMESTAMPTZ`, NOT NULL)
  * `check_in_latitude` (`DECIMAL(10, 8)`, NULLABLE)
  * `check_in_longitude` (`DECIMAL(11, 8)`, NULLABLE)
  * `activities_performed` (`JSONB`, NOT NULL) - e.g., `["sponge_bath", "lunch_served", "walk_in_garden"]`.
  * `vital_blood_pressure` (`VARCHAR(20)`, NULLABLE)
  * `vital_pulse` (`INTEGER`, NULLABLE)
  * `vital_sugar` (`DECIMAL(5, 1)`, NULLABLE)
  * `mood_observation` (`VARCHAR(50)`, NOT NULL) - `cheerful`, `calm`, `confused`, `in_pain`, `lethargic`.
  * `caregiver_notes` (`TEXT`, NOT NULL)
  * `report_photo_s3_key` (`VARCHAR(500)`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

---

### Module F: Medical Consultations & Lab Bookings

#### 25. `doctor_appointments`
Telehealth or clinic appointments connecting seniors to doctors.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE RESTRICT, NOT NULL)
  * `doctor_id` (`UUID`, FK `doctor_profiles.id` ON DELETE RESTRICT, NOT NULL)
  * `booked_by_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `scheduled_time` (`TIMESTAMPTZ`, NOT NULL)
  * `appointment_type` (`VARCHAR(30)`, NOT NULL) - `video_consult`, `clinic_visit`, `home_visit`.
  * `status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'scheduled'`) - `scheduled`, `in_progress`, `completed`, `cancelled`, `no_show`.
  * `reason_for_consultation` (`TEXT`, NOT NULL)
  * `video_room_id` (`VARCHAR(100)`, NULLABLE) - WebRTC room ID.
  * `doctor_notes` (`TEXT`, NULLABLE)
  * `fee_amount` (`DECIMAL(10, 2)`, NOT NULL)
  * `payment_status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'pending'`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `updated_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 26. `lab_bookings`
Diagnostic lab tests and home blood sample collection bookings.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE RESTRICT, NOT NULL)
  * `booked_by_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `lab_provider_name` (`VARCHAR(150)`, NOT NULL)
  * `test_package_name` (`VARCHAR(200)`, NOT NULL) - e.g., "Complete Senior Citizen Lipid & Kidney Profile".
  * `scheduled_date` (`DATE`, NOT NULL)
  * `collection_type` (`VARCHAR(30)`, NOT NULL) - `home_sample_collection`, `diagnostic_center_visit`.
  * `status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'booked'`) - `booked`, `sample_collected`, `processing`, `completed`, `cancelled`.
  * `total_cost` (`DECIMAL(10, 2)`, NOT NULL)
  * `report_s3_key` (`VARCHAR(500)`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

---

### Module G: Emergency SOS & Contacts

#### 27. `emergency_contacts`
Direct phone contacts dialed during SOS triggers.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `contact_name` (`VARCHAR(150)`, NOT NULL)
  * `phone_number` (`VARCHAR(20)`, NOT NULL)
  * `relationship` (`VARCHAR(50)`, NOT NULL) - e.g., "Daughter", "Neighbor", "Family Doctor".
  * `priority_order` (`INTEGER`, NOT NULL, `DEFAULT 1`) - 1 is dialed first.
  * `is_active` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints:**
  * Index: `idx_emergency_senior_priority` (`senior_id`, `priority_order`).

#### 28. `sos_events`
Critical incident records created when the SOS button is triggered.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE RESTRICT, NOT NULL)
  * `triggered_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `trigger_source` (`VARCHAR(30)`, NOT NULL) - `in_app_button`, `voice_assistant_keyword`, `fall_detection_sensor`.
  * `latitude` (`DECIMAL(10, 8)`, NOT NULL)
  * `longitude` (`DECIMAL(11, 8)`, NOT NULL)
  * `approximate_address` (`TEXT`, NULLABLE)
  * `battery_level_percent` (`INTEGER`, NULLABLE)
  * `status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'active'`) - `active`, `acknowledged`, `resolved`, `false_alarm`.
  * `acknowledged_at` (`TIMESTAMPTZ`, NULLABLE)
  * `resolved_at` (`TIMESTAMPTZ`, NULLABLE)
  * `resolved_by_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NULLABLE)
  * `resolution_notes` (`TEXT`, NULLABLE)
  * `broadcast_payload` (`JSONB`, `DEFAULT '{}'`) - Snapshot of sent SMS and FCM recipient lists.
* **Indexes:**
  * Index: `idx_sos_active` (`senior_id`, `status`) WHERE `status = 'active'`.

---

### Module H: Family Communication & Updates

#### 29. `family_updates`
Family timeline feed where children/grandchildren post pictures and messages to keep seniors happy.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `senior_id` (`UUID`, FK `senior_profiles.id` ON DELETE CASCADE, NOT NULL)
  * `author_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `caption` (`TEXT`, NOT NULL)
  * `update_type` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'photo'`) - `photo`, `video`, `health_announcement`, `greeting`.
  * `is_pinned` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 30. `update_attachments`
Images or videos attached to a family update.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `update_id` (`UUID`, FK `family_updates.id` ON DELETE CASCADE, NOT NULL)
  * `attachment_s3_key` (`VARCHAR(500)`, NOT NULL)
  * `file_mime_type` (`VARCHAR(50)`, NOT NULL)
  * `file_size_bytes` (`INTEGER`, NOT NULL)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

---

### Module I: Payments & Subscriptions

#### 31. `subscription_plans`
Platform membership tiers (e.g., Free, SeniorCare Plus, Premium Concierge).
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `plan_code` (`VARCHAR(50)`, UNIQUE, NOT NULL) - `basic_free`, `plus_monthly`, `plus_annual`.
  * `name` (`VARCHAR(100)`, NOT NULL)
  * `description` (`TEXT`, NOT NULL)
  * `price_inr` (`DECIMAL(10, 2)`, NOT NULL)
  * `billing_interval` (`VARCHAR(20)`, NOT NULL) - `monthly`, `quarterly`, `yearly`.
  * `features_json` (`JSONB`, NOT NULL)
  * `is_active` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)

#### 32. `subscriptions`
User active subscription contracts.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `plan_id` (`UUID`, FK `subscription_plans.id` ON DELETE RESTRICT, NOT NULL)
  * `status` (`VARCHAR(30)`, NOT NULL) - `active`, `past_due`, `cancelled`, `expired`.
  * `start_date` (`DATE`, NOT NULL)
  * `end_date` (`DATE`, NOT NULL)
  * `auto_renew` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

#### 33. `payments`
Financial transactions for caregiver bookings, doctor consultations, or subscriptions.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `booking_id` (`UUID`, FK `bookings.id` ON DELETE SET NULL, NULLABLE)
  * `subscription_id` (`UUID`, FK `subscriptions.id` ON DELETE SET NULL, NULLABLE)
  * `appointment_id` (`UUID`, FK `doctor_appointments.id` ON DELETE SET NULL, NULLABLE)
  * `amount` (`DECIMAL(10, 2)`, NOT NULL)
  * `currency` (`VARCHAR(5)`, NOT NULL, `DEFAULT 'INR'`)
  * `gateway_provider` (`VARCHAR(30)`, NOT NULL) - `razorpay`, `stripe`, `cash_on_service`.
  * `gateway_order_id` (`VARCHAR(100)`, NULLABLE)
  * `gateway_payment_id` (`VARCHAR(100)`, NULLABLE)
  * `status` (`VARCHAR(30)`, NOT NULL, `DEFAULT 'created'`) - `created`, `captured`, `failed`, `refunded`.
  * `receipt_url` (`VARCHAR(500)`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)

---

### Module J: Notifications & Preferences

#### 34. `notifications`
Push and in-app notifications generated by the system.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, NOT NULL)
  * `title` (`VARCHAR(200)`, NOT NULL)
  * `body` (`TEXT`, NOT NULL)
  * `category` (`VARCHAR(50)`, NOT NULL) - `medicine_reminder`, `sos_emergency`, `caregiver_update`, `family_message`, `appointment`.
  * `deep_link_screen` (`VARCHAR(100)`, NULLABLE) - Target Flutter route (e.g., `/reminders`, `/sos/view`).
  * `reference_entity_id` (`UUID`, NULLABLE)
  * `is_read` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `sent_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
  * `read_at` (`TIMESTAMPTZ`, NULLABLE)
* **Indexes:**
  * Index: `idx_notifs_user_read` (`user_id`, `is_read`, `sent_at` DESC).

#### 35. `notification_preferences`
User controls for quiet hours and channel delivery.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `user_id` (`UUID`, FK `users.id` ON DELETE CASCADE, UNIQUE, NOT NULL)
  * `push_enabled` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `sms_enabled` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `whatsapp_enabled` (`BOOLEAN`, NOT NULL, `DEFAULT TRUE`)
  * `email_enabled` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `quiet_hours_enabled` (`BOOLEAN`, NOT NULL, `DEFAULT FALSE`)
  * `quiet_hours_start` (`TIME`, NULLABLE)
  * `quiet_hours_end` (`TIME`, NULLABLE)

---

### Module K: Reviews & Compliance Audit Logs

#### 36. `reviews`
Ratings and testimonials for caregivers and doctors.
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `reviewer_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `target_type` (`VARCHAR(30)`, NOT NULL) - `caregiver`, `doctor`.
  * `target_id` (`UUID`, NOT NULL) - FK to `caregiver_profiles.id` or `doctor_profiles.id`.
  * `booking_id` (`UUID`, FK `bookings.id` ON DELETE SET NULL, NULLABLE)
  * `rating` (`INTEGER`, NOT NULL) - Range 1 to 5.
  * `review_text` (`TEXT`, NULLABLE)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Constraints:**
  * Check: `chk_rating_range` (`rating >= 1 AND rating <= 5`).
  * Index: `idx_reviews_target` (`target_type`, `target_id`).

#### 37. `audit_logs`
Immutable compliance log recording all sensitive operations (e.g., medical record access, permission modifications, emergency SOS closures).
* **Columns:**
  * `id` (`UUID`, PK, `DEFAULT gen_random_uuid()`)
  * `actor_user_id` (`UUID`, FK `users.id` ON DELETE RESTRICT, NOT NULL)
  * `target_entity_type` (`VARCHAR(50)`, NOT NULL) - `health_record`, `access_permission`, `sos_event`, `face_profile`.
  * `target_entity_id` (`UUID`, NOT NULL)
  * `action` (`VARCHAR(50)`, NOT NULL) - `CREATE`, `READ`, `UPDATE`, `REVOKE`, `DELETE`.
  * `ip_address` (`VARCHAR(45)`, NULLABLE)
  * `details_json` (`JSONB`, `DEFAULT '{}'`)
  * `created_at` (`TIMESTAMPTZ`, NOT NULL, `DEFAULT CURRENT_TIMESTAMP`)
* **Indexes:**
  * Index: `idx_audit_actor_target` (`actor_user_id`, `target_entity_type`, `created_at` DESC).

