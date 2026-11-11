-- ==============================================================================
-- SeniorCare Platform – Complete PostgreSQL DDL Script
-- Target Engine: PostgreSQL 16+ / 18
-- Creates all 37 tables, constraints, foreign keys, and indexes
-- ==============================================================================

-- Enable UUID and Cryptographic extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -------------------------------------------------------------
-- MODULE A: USER MANAGEMENT & PROFILES
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    hashed_password VARCHAR(255),
    role VARCHAR(30) NOT NULL CHECK (role IN ('senior', 'family', 'caregiver', 'doctor', 'admin')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_phone ON users (phone_number);
CREATE INDEX IF NOT EXISTS idx_users_role ON users (role);

CREATE TABLE IF NOT EXISTS user_consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    consent_type VARCHAR(50) NOT NULL,
    consent_version VARCHAR(20) NOT NULL DEFAULT '1.0',
    is_granted BOOLEAN NOT NULL DEFAULT TRUE,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    withdrawn_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_user_consents_user ON user_consents (user_id);

CREATE TABLE IF NOT EXISTS senior_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    preferred_name VARCHAR(100),
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    blood_group VARCHAR(5),
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    primary_language VARCHAR(20) NOT NULL DEFAULT 'hi',
    emergency_notes TEXT,
    profile_picture_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_seniors_city_geo ON senior_profiles (city, latitude, longitude);

CREATE TABLE IF NOT EXISTS family_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    alternate_phone VARCHAR(20),
    relationship_description VARCHAR(100),
    notification_preferences_json JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS caregiver_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    bio TEXT,
    experience_years INTEGER NOT NULL DEFAULT 0,
    hourly_rate DECIMAL(10, 2) NOT NULL,
    daily_rate DECIMAL(10, 2),
    verification_status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected', 'suspended')),
    police_clearance_verified BOOLEAN NOT NULL DEFAULT FALSE,
    medical_training_verified BOOLEAN NOT NULL DEFAULT FALSE,
    rating_average DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    total_reviews INTEGER NOT NULL DEFAULT 0,
    is_available_for_hire BOOLEAN NOT NULL DEFAULT TRUE,
    service_city VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_caregivers_city_verified ON caregiver_profiles (service_city, verification_status, is_available_for_hire);

CREATE TABLE IF NOT EXISTS doctor_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    medical_license_number VARCHAR(100) UNIQUE NOT NULL,
    qualifications VARCHAR(200) NOT NULL,
    hospital_affiliation VARCHAR(200),
    consultation_fee DECIMAL(10, 2) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    rating_average DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- MODULE B: FAMILY CONNECTIONS & REBAC PERMISSIONS
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS family_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE CASCADE,
    family_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    relation_type VARCHAR(50) NOT NULL,
    is_primary_caregiver_contact BOOLEAN NOT NULL DEFAULT FALSE,
    is_emergency_contact BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'revoked')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_senior_family_link UNIQUE (senior_id, family_user_id)
);

CREATE INDEX IF NOT EXISTS idx_rel_senior ON family_relationships (senior_id);
CREATE INDEX IF NOT EXISTS idx_rel_family ON family_relationships (family_user_id);

CREATE TABLE IF NOT EXISTS family_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE CASCADE,
    inviter_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invitee_phone VARCHAR(20) NOT NULL,
    invitee_email VARCHAR(255),
    invitation_code VARCHAR(64) UNIQUE NOT NULL,
    relation_proposed VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired', 'cancelled')),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_invitations_code ON family_invitations (invitation_code);
CREATE INDEX IF NOT EXISTS idx_invitations_status ON family_invitations (invitee_phone, status);

CREATE TABLE IF NOT EXISTS access_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    relationship_id UUID NOT NULL REFERENCES family_relationships(id) ON DELETE CASCADE,
    permission_module VARCHAR(50) NOT NULL CHECK (permission_module IN ('health_records', 'medicines', 'live_location', 'caregiver_bookings', 'doctor_consultations', 'financial_billing')),
    access_level VARCHAR(20) NOT NULL CHECK (access_level IN ('none', 'view_only', 'full_management')),
    granted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_rel_permission_module UNIQUE (relationship_id, permission_module)
);

-- -------------------------------------------------------------
-- MODULE C: AUTHENTICATION, SESSIONS & BIOMETRICS
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_uuid VARCHAR(100) NOT NULL,
    fcm_token TEXT,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
    device_model VARCHAR(100),
    app_version VARCHAR(20),
    last_active_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_device UNIQUE (user_id, device_uuid)
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_refresh_lookup ON refresh_tokens (token_hash, is_revoked);

CREATE TABLE IF NOT EXISTS login_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    auth_method VARCHAR(30) NOT NULL CHECK (auth_method IN ('password', 'face_recognition', 'otp_sms')),
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_successful BOOLEAN NOT NULL,
    failure_reason VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS face_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    encrypted_embedding BYTEA NOT NULL,
    encryption_iv BYTEA NOT NULL,
    encryption_tag BYTEA NOT NULL,
    model_version VARCHAR(50) NOT NULL DEFAULT 'arcface_r50_v1',
    quality_score DECIMAL(4, 3) NOT NULL,
    liveness_score DECIMAL(4, 3) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- MODULE D: HEALTHCARE & MEDICINES
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS health_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    record_type VARCHAR(50) NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL,
    recorded_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    vital_bp_systolic INTEGER,
    vital_bp_diastolic INTEGER,
    vital_heart_rate INTEGER,
    vital_blood_glucose DECIMAL(5, 1),
    vital_oxygen_saturation DECIMAL(4, 1),
    vital_temperature DECIMAL(4, 1),
    notes TEXT,
    document_s3_key VARCHAR(500),
    document_file_hash VARCHAR(64),
    document_mime_type VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_health_senior_date ON health_records (senior_id, recorded_at DESC);

CREATE TABLE IF NOT EXISTS prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE CASCADE,
    prescribing_doctor_id UUID REFERENCES doctor_profiles(id) ON DELETE SET NULL,
    prescribing_doctor_name VARCHAR(150),
    diagnosis TEXT,
    issued_date DATE NOT NULL,
    valid_until DATE,
    document_s3_key VARCHAR(500),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS medicines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE CASCADE,
    prescription_id UUID REFERENCES prescriptions(id) ON DELETE SET NULL,
    name VARCHAR(150) NOT NULL,
    dosage_strength VARCHAR(50) NOT NULL,
    form VARCHAR(30) NOT NULL,
    meal_relation VARCHAR(30) NOT NULL,
    color_code VARCHAR(10),
    start_date DATE NOT NULL,
    end_date DATE,
    instructions TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS medicine_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medicine_id UUID NOT NULL REFERENCES medicines(id) ON DELETE CASCADE,
    time_of_day TIME NOT NULL,
    days_of_week INTEGER[],
    dose_quantity DECIMAL(3, 1) NOT NULL DEFAULT 1.0,
    reminder_lead_minutes INTEGER NOT NULL DEFAULT 10
);

CREATE INDEX IF NOT EXISTS idx_schedules_time ON medicine_schedules (time_of_day);

CREATE TABLE IF NOT EXISTS medicine_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID NOT NULL REFERENCES medicine_schedules(id) ON DELETE CASCADE,
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE CASCADE,
    scheduled_timestamp TIMESTAMPTZ NOT NULL,
    status VARCHAR(30) NOT NULL CHECK (status IN ('taken', 'missed', 'skipped', 'snoozed')),
    logged_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    acknowledged_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    notes TEXT,
    CONSTRAINT uq_schedule_dose UNIQUE (schedule_id, scheduled_timestamp)
);

CREATE INDEX IF NOT EXISTS idx_medlogs_senior_status ON medicine_logs (senior_id, status, scheduled_timestamp);

-- -------------------------------------------------------------
-- MODULE E: CAREGIVER SERVICES & BOOKINGS
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    base_hourly_rate DECIMAL(10, 2) NOT NULL,
    icon_key VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS caregiver_qualifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE CASCADE,
    qualification_title VARCHAR(200) NOT NULL,
    institution VARCHAR(200) NOT NULL,
    year_completed INTEGER NOT NULL,
    certificate_s3_key VARCHAR(500),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS caregiver_verification_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(100) NOT NULL,
    document_s3_key VARCHAR(500) NOT NULL,
    verification_status VARCHAR(30) NOT NULL DEFAULT 'pending',
    reviewed_by_admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    rejection_reason TEXT,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS caregiver_availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE RESTRICT,
    booked_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE RESTRICT,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    booking_type VARCHAR(30) NOT NULL,
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    special_instructions TEXT,
    total_hours DECIMAL(5, 2) NOT NULL,
    hourly_rate_agreed DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(30) NOT NULL DEFAULT 'unpaid',
    status VARCHAR(30) NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bookings_senior ON bookings (senior_id);
CREATE INDEX IF NOT EXISTS idx_bookings_caregiver ON bookings (caregiver_id, status);

CREATE TABLE IF NOT EXISTS booking_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    previous_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    reason_or_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS caregiver_visit_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID UNIQUE NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE RESTRICT,
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE RESTRICT,
    check_in_time TIMESTAMPTZ NOT NULL,
    check_out_time TIMESTAMPTZ NOT NULL,
    check_in_latitude DECIMAL(10, 8),
    check_in_longitude DECIMAL(11, 8),
    activities_performed JSONB NOT NULL,
    vital_blood_pressure VARCHAR(20),
    vital_pulse INTEGER,
    vital_sugar DECIMAL(5, 1),
    mood_observation VARCHAR(50) NOT NULL,
    caregiver_notes TEXT NOT NULL,
    report_photo_s3_key VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- MODULE F: MEDICAL CONSULTATIONS & LAB BOOKINGS
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS doctor_appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE RESTRICT,
    doctor_id UUID NOT NULL REFERENCES doctor_profiles(id) ON DELETE RESTRICT,
    booked_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    scheduled_time TIMESTAMPTZ NOT NULL,
    appointment_type VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'scheduled',
    reason_for_consultation TEXT NOT NULL,
    video_room_id VARCHAR(100),
    doctor_notes TEXT,
    fee_amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(30) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lab_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE RESTRICT,
    booked_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    lab_provider_name VARCHAR(150) NOT NULL,
    test_package_name VARCHAR(200) NOT NULL,
    scheduled_date DATE NOT NULL,
    collection_type VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'booked',
    total_cost DECIMAL(10, 2) NOT NULL,
    report_s3_key VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- MODULE G: EMERGENCY SOS & CONTACTS
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS emergency_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE CASCADE,
    contact_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    priority_order INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_emergency_senior_priority ON emergency_contacts (senior_id, priority_order);

CREATE TABLE IF NOT EXISTS sos_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE RESTRICT,
    triggered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    trigger_source VARCHAR(30) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    approximate_address TEXT,
    battery_level_percent INTEGER,
    status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'acknowledged', 'resolved', 'false_alarm')),
    acknowledged_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    resolved_by_user_id UUID REFERENCES users(id) ON DELETE RESTRICT,
    resolution_notes TEXT,
    broadcast_payload JSONB DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_sos_active ON sos_events (senior_id, status);

-- -------------------------------------------------------------
-- MODULE H: FAMILY COMMUNICATION & UPDATES
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS family_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    senior_id UUID NOT NULL REFERENCES senior_profiles(id) ON DELETE CASCADE,
    author_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    caption TEXT NOT NULL,
    update_type VARCHAR(30) NOT NULL DEFAULT 'photo',
    is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS update_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    update_id UUID NOT NULL REFERENCES family_updates(id) ON DELETE CASCADE,
    attachment_s3_key VARCHAR(500) NOT NULL,
    file_mime_type VARCHAR(50) NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- MODULE I: PAYMENTS & SUBSCRIPTIONS
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    price_inr DECIMAL(10, 2) NOT NULL,
    billing_interval VARCHAR(20) NOT NULL,
    features_json JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE RESTRICT,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
    appointment_id UUID REFERENCES doctor_appointments(id) ON DELETE SET NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(5) NOT NULL DEFAULT 'INR',
    gateway_provider VARCHAR(30) NOT NULL,
    gateway_order_id VARCHAR(100),
    gateway_payment_id VARCHAR(100),
    status VARCHAR(30) NOT NULL DEFAULT 'created',
    receipt_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- MODULE J: NOTIFICATIONS & PREFERENCES
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    deep_link_screen VARCHAR(100),
    reference_entity_id UUID,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_notifs_user_read ON notifications (user_id, is_read, sent_at DESC);

CREATE TABLE IF NOT EXISTS notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    push_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    sms_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    whatsapp_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    email_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    quiet_hours_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME
);

-- -------------------------------------------------------------
-- MODULE K: REVIEWS & AUDIT LOGS
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    target_type VARCHAR(30) NOT NULL,
    target_id UUID NOT NULL,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_reviews_target ON reviews (target_type, target_id);

CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    target_entity_type VARCHAR(50) NOT NULL,
    target_entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45),
    details_json JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_actor_target ON audit_logs (actor_user_id, target_entity_type, created_at DESC);

-- -------------------------------------------------------------
-- SEED INITIAL SERVICES & SUBSCRIPTION TIERS
-- -------------------------------------------------------------

INSERT INTO services (title, category, description, base_hourly_rate, icon_key)
VALUES 
('Elderly Day Companion', 'daily_companion', 'Friendly companion for walking, conversations, reading, and gentle assistance.', 250.00, 'volunteer_activism_rounded'),
('Nursing & Medication Care', 'nursing_care', 'Certified nursing support for injections, vitals tracking, dressing, and catheter care.', 450.00, 'medical_services_rounded'),
('Senior Mobility & Physiotherapy', 'physiotherapy', 'Assistance with gentle stretching, joint mobility exercises, and fall prevention.', 400.00, 'accessibility_new_rounded')
ON CONFLICT DO NOTHING;

INSERT INTO subscription_plans (plan_code, name, description, price_inr, billing_interval, features_json)
VALUES 
('basic_free', 'SeniorCare Free', 'Essential medicine reminders, emergency SOS, and family care circle.', 0.00, 'monthly', '{"sos": true, "reminders": true, "max_family_members": 2}'),
('care_plus_monthly', 'SeniorCare Plus', 'Unlimited family members, AI voice assistant, weekly health insights, priority doctor bookings.', 499.00, 'monthly', '{"sos": true, "reminders": true, "ai_assistant": true, "unlimited_family": true}')
ON CONFLICT DO NOTHING;

