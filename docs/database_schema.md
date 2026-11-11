# SeniorCare Platform — Phase 2 Database Schema Specification

**Database Engine:** PostgreSQL 18  
**ORM:** SQLAlchemy 2.x  
**Migration Tool:** Alembic  
**Target Database:** `seniorcare_db`  

---

## 1. Core Tables for Phase 2 Implementation

### 1.1 `users`
Central user table supporting all application roles (Senior, Family, Caregiver, Admin).
* `id` (UUID, Primary Key, default `gen_random_uuid()`)
* `full_name` (VARCHAR(150), NOT NULL)
* `email` (VARCHAR(255), UNIQUE, NULLABLE)
* `phone` / `mobile_number` (VARCHAR(20), UNIQUE, NOT NULL)
* `password_hash` (VARCHAR(255), NULLABLE for passwordless seniors)
* `role` (VARCHAR(50), NOT NULL, default `'senior'`) — CHECK: `role IN ('senior', 'family', 'caregiver', 'doctor', 'admin')`
* `status` (VARCHAR(50), NOT NULL, default `'active'`)
* `is_phone_verified` (BOOLEAN, default FALSE)
* `is_email_verified` (BOOLEAN, default FALSE)
* `created_at` (TIMESTAMPTZ, default `now()`)
* `updated_at` (TIMESTAMPTZ, default `now()`)

### 1.2 `senior_profiles`
Profile metadata specific to elderly citizens.
* `id` (UUID, Primary Key)
* `user_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE CASCADE, UNIQUE)
* `date_of_birth` (DATE, NULLABLE)
* `blood_group` (VARCHAR(10), NULLABLE)
* `gender` (VARCHAR(20), NULLABLE)
* `address` (TEXT, NULLABLE)
* `city` (VARCHAR(100), NULLABLE)
* `state` (VARCHAR(100), NULLABLE)
* `postal_code` (VARCHAR(20), NULLABLE)
* `latitude` (DECIMAL(10, 8), NULLABLE)
* `longitude` (DECIMAL(11, 8), NULLABLE)
* `primary_emergency_contact` (VARCHAR(20), NULLABLE)
* `created_at` (TIMESTAMPTZ, default `now()`)
* `updated_at` (TIMESTAMPTZ, default `now()`)

### 1.3 `family_profiles`
Metadata for remote family members.
* `id` (UUID, Primary Key)
* `user_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE CASCADE, UNIQUE)
* `relationship_type` (VARCHAR(50), NOT NULL) — e.g. `'son'`, `'daughter'`, `'spouse'`
* `emergency_priority` (INT, default 2)
* `can_receive_alerts` (BOOLEAN, default TRUE)
* `created_at` (TIMESTAMPTZ, default `now()`)
* `updated_at` (TIMESTAMPTZ, default `now()`)

### 1.4 `family_relationships`
Relationship links connecting multiple family members to seniors.
* `id` (UUID, Primary Key)
* `senior_id` (UUID, Foreign Key $\rightarrow$ `senior_profiles.id` ON DELETE CASCADE)
* `family_user_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE CASCADE)
* `relationship_type` (VARCHAR(50), NOT NULL)
* `is_active` (BOOLEAN, default TRUE)
* `emergency_priority` (INT, default 2)
* `can_manage_medications` (BOOLEAN, default FALSE)
* `can_view_records` (BOOLEAN, default FALSE)
* `can_book_services` (BOOLEAN, default FALSE)
* `created_at` (TIMESTAMPTZ, default `now()`)
* `updated_at` (TIMESTAMPTZ, default `now()`)
* **Constraint:** UNIQUE(`senior_id`, `family_user_id`)

### 1.5 `family_invitations`
Invitation tokens for connection requests.
* `id` (UUID, Primary Key)
* `inviter_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE CASCADE)
* `invitee_phone` (VARCHAR(20), NOT NULL)
* `invitee_email` (VARCHAR(255), NULLABLE)
* `relationship_type` (VARCHAR(50), NOT NULL)
* `token` (VARCHAR(255), UNIQUE, NOT NULL)
* `status` (VARCHAR(50), default `'pending'`) — CHECK: `status IN ('pending', 'accepted', 'rejected', 'expired', 'revoked')`
* `expires_at` (TIMESTAMPTZ, NOT NULL)
* `created_at` (TIMESTAMPTZ, default `now()`)
* `updated_at` (TIMESTAMPTZ, default `now()`)

### 1.6 `access_permissions`
Granular ReBAC authorization permissions.
* `id` (UUID, Primary Key)
* `relationship_id` (UUID, Foreign Key $\rightarrow$ `family_relationships.id` ON DELETE CASCADE)
* `module` (VARCHAR(50), NOT NULL) — e.g. `'medications'`, `'vitals'`, `'prescriptions'`, `'records'`
* `can_read` (BOOLEAN, default TRUE)
* `can_write` (BOOLEAN, default FALSE)
* `can_emergency_override` (BOOLEAN, default FALSE)
* `granted_at` (TIMESTAMPTZ, default `now()`)
* `updated_at` (TIMESTAMPTZ, default `now()`)

### 1.7 `face_profiles`
Encrypted ArcFace biometric embeddings.
* `id` (UUID, Primary Key)
* `user_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE CASCADE, UNIQUE)
* `face_embedding_encrypted` (TEXT, NOT NULL) — AES-256-GCM ciphertext
* `model_version` (VARCHAR(50), NOT NULL, default `'arcface-512-v1'`)
* `quality_score` (DECIMAL(4, 3), default 0.000)
* `is_active` (BOOLEAN, default TRUE)
* `created_at` (TIMESTAMPTZ, default `now()`)
* `updated_at` (TIMESTAMPTZ, default `now()`)

### 1.8 `devices` & `refresh_tokens`
Device binding and single-use refresh token rotation.
* **`devices`**:
  * `id` (UUID, Primary Key)
  * `user_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE CASCADE)
  * `device_token` (VARCHAR(255), NOT NULL)
  * `device_type` (VARCHAR(50), NOT NULL) — `'android'`, `'ios'`, `'web'`
  * `is_active` (BOOLEAN, default TRUE)
  * `created_at` (TIMESTAMPTZ, default `now()`)
* **`refresh_tokens`**:
  * `id` (UUID, Primary Key)
  * `user_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE CASCADE)
  * `token_hash` (VARCHAR(255), UNIQUE, NOT NULL) — SHA-256 hash of refresh token
  * `device_id` (UUID, Foreign Key $\rightarrow$ `devices.id` ON DELETE SET NULL, NULLABLE)
  * `expires_at` (TIMESTAMPTZ, NOT NULL)
  * `is_revoked` (BOOLEAN, default FALSE)
  * `created_at` (TIMESTAMPTZ, default `now()`)

### 1.9 `user_consents`
Explicit informed biometric and health consent tracking.
* `id` (UUID, Primary Key)
* `user_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE CASCADE)
* `consent_type` (VARCHAR(50), NOT NULL) — `'biometric_face_auth'`, `'health_data_sharing'`
* `consent_version` (VARCHAR(20), NOT NULL, default `'1.0'`)
* `is_granted` (BOOLEAN, default TRUE)
* `granted_at` (TIMESTAMPTZ, default `now()`)
* `withdrawn_at` (TIMESTAMPTZ, NULLABLE)

### 1.10 `audit_logs`
Security event audit trail.
* `id` (UUID, Primary Key)
* `user_id` (UUID, Foreign Key $\rightarrow$ `users.id` ON DELETE SET NULL, NULLABLE)
* `action` (VARCHAR(100), NOT NULL) — `'REGISTER'`, `'LOGIN'`, `'FACE_ENROLL'`, `'FACE_VERIFY'`, `'LINK_REQUEST'`, `'LINK_APPROVE'`, `'LOGOUT'`
* `entity_type` (VARCHAR(50), NOT NULL)
* `entity_id` (UUID, NULLABLE)
* `old_values` (JSONB, NULLABLE)
* `new_values` (JSONB, NULLABLE)
* `ip_address` (VARCHAR(45), NULLABLE)
* `user_agent` (VARCHAR(255), NULLABLE)
* `created_at` (TIMESTAMPTZ, default `now()`)

