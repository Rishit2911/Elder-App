-- =============================================================================
-- Elderly Seva – Complete Production MySQL Database Schema
-- Database: elderly_seva_db
-- Charset: utf8mb4  |  Collation: utf8mb4_unicode_ci
-- Compatible with MySQL 8.0+ and MySQL 8.4/9.x (Windows / Linux)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `elderly_seva_db`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `elderly_seva_db`;

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------------
-- 1. USERS: Authentication, credentials, and persona roles
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
    `id`              VARCHAR(36)  NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `phone_number`    VARCHAR(20)  NOT NULL UNIQUE COMMENT 'Normalized mobile number',
    `email`           VARCHAR(255)          UNIQUE COMMENT 'User email address',
    `hashed_password` VARCHAR(255)          COMMENT 'Argon2id password hash',
    `role`            VARCHAR(30)  NOT NULL COMMENT 'senior | family | caregiver | doctor | admin',
    `is_active`       TINYINT(1)   NOT NULL DEFAULT 1,
    `is_verified`     TINYINT(1)   NOT NULL DEFAULT 0,
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `ix_users_phone_number` (`phone_number`),
    INDEX `ix_users_email` (`email`),
    INDEX `ix_users_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 2. SENIOR PROFILES: Detailed senior citizen demographic & health metadata
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `senior_profiles` (
    `id`                  VARCHAR(36)     NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`             VARCHAR(36)     NOT NULL UNIQUE COMMENT 'FK to users table',
    `full_name`           VARCHAR(150)    NOT NULL,
    `preferred_name`      VARCHAR(100)    DEFAULT 'Dadaji',
    `date_of_birth`       DATE            NOT NULL,
    `gender`              VARCHAR(20)     NOT NULL DEFAULT 'other',
    `blood_group`         VARCHAR(5)      DEFAULT NULL,
    `address`             TEXT            NOT NULL,
    `city`                VARCHAR(100)    NOT NULL DEFAULT 'Delhi NCR',
    `postal_code`         VARCHAR(20)     NOT NULL DEFAULT '110001',
    `latitude`            DECIMAL(10,8)   DEFAULT NULL,
    `longitude`           DECIMAL(11,8)   DEFAULT NULL,
    `primary_language`    VARCHAR(20)     NOT NULL DEFAULT 'hi',
    `emergency_notes`     TEXT            DEFAULT NULL,
    `profile_picture_url` VARCHAR(500)    DEFAULT NULL,
    `created_at`          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `ix_senior_profiles_city` (`city`),
    CONSTRAINT `fk_senior_profiles_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 3. FAMILY MEMBERS: Relationships, guardianship, and access permissions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `family_members` (
    `id`                           VARCHAR(36)  NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `senior_id`                    VARCHAR(36)  NOT NULL COMMENT 'FK to senior_profiles',
    `family_user_id`               VARCHAR(36)  NOT NULL COMMENT 'FK to users',
    `relationship_type`            VARCHAR(50)  NOT NULL COMMENT 'son | daughter | spouse | grandchild | guardian',
    `is_primary_caregiver_contact` TINYINT(1)  NOT NULL DEFAULT 0,
    `is_emergency_contact`         TINYINT(1)  NOT NULL DEFAULT 1,
    `can_manage_medications`       TINYINT(1)  NOT NULL DEFAULT 1,
    `can_view_records`             TINYINT(1)  NOT NULL DEFAULT 1,
    `can_book_services`            TINYINT(1)  NOT NULL DEFAULT 1,
    `status`                       VARCHAR(30)  NOT NULL DEFAULT 'active' COMMENT 'active | paused | revoked',
    `created_at`                   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`                   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_family_senior_user` (`senior_id`, `family_user_id`),
    INDEX `ix_family_members_senior_id` (`senior_id`),
    INDEX `ix_family_members_family_user_id` (`family_user_id`),
    CONSTRAINT `fk_family_members_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_family_members_user_id`
        FOREIGN KEY (`family_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 4. EMERGENCY CONTACTS: Rapid SOS dial targets for senior citizens
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `emergency_contacts` (
    `id`           VARCHAR(36)  NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `senior_id`    VARCHAR(36)  NOT NULL COMMENT 'FK to senior_profiles',
    `contact_name` VARCHAR(150) NOT NULL,
    `relation`     VARCHAR(50)  NOT NULL,
    `phone_number` VARCHAR(20)  NOT NULL,
    `is_primary`   TINYINT(1)  NOT NULL DEFAULT 0,
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_emergency_contacts_senior_id` (`senior_id`),
    CONSTRAINT `fk_emergency_contacts_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 5. MEDICINES: Form, strength, meal instruction, and 3-bottle inventory
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `medicines` (
    `id`                       VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `senior_id`                VARCHAR(36)   NOT NULL COMMENT 'FK to senior_profiles',
    `name`                     VARCHAR(150)  NOT NULL,
    `dosage_strength`          VARCHAR(50)   NOT NULL COMMENT 'e.g. 500mg, 10ml, 1 puff',
    `form`                     VARCHAR(30)   NOT NULL COMMENT 'tablet | capsule | syrup | injection',
    `meal_relation`            VARCHAR(30)   NOT NULL COMMENT 'before_meal | after_meal | with_meal',
    `bottle_quantity_remaining` INT          NOT NULL DEFAULT 30 COMMENT 'Remaining pills/units in bottle',
    `bottle_total_quantity`    INT           NOT NULL DEFAULT 30 COMMENT 'Initial bottle capacity',
    `color_code`               VARCHAR(10)   DEFAULT '#2E7D32',
    `start_date`               DATE          NOT NULL,
    `end_date`                 DATE          DEFAULT NULL,
    `instructions`             TEXT          DEFAULT NULL,
    `is_active`                TINYINT(1)   NOT NULL DEFAULT 1,
    `created_at`               DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_medicines_senior_id` (`senior_id`),
    INDEX `ix_medicines_is_active` (`is_active`),
    CONSTRAINT `fk_medicines_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 6. MEDICINE REMINDERS: Dosage timings, frequency schedules & intake tracking
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `medicine_reminders` (
    `id`                 VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `medicine_id`        VARCHAR(36)   NOT NULL COMMENT 'FK to medicines',
    `senior_id`          VARCHAR(36)   NOT NULL COMMENT 'FK to senior_profiles',
    `reminder_time`      TIME          NOT NULL COMMENT 'Scheduled intake time',
    `dosage_quantity`    DECIMAL(5,2)  NOT NULL DEFAULT 1.00 COMMENT 'Quantity per dose',
    `days_of_week`       VARCHAR(50)   NOT NULL DEFAULT '[1,2,3,4,5,6,7]' COMMENT 'JSON array: 1=Mon..7=Sun',
    `is_active`          TINYINT(1)   NOT NULL DEFAULT 1,
    `last_taken_at`      DATETIME      DEFAULT NULL,
    `status`             VARCHAR(20)   NOT NULL DEFAULT 'pending' COMMENT 'pending | taken | skipped | missed',
    `created_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_medicine_reminders_medicine_id` (`medicine_id`),
    INDEX `ix_medicine_reminders_senior_id` (`senior_id`),
    CONSTRAINT `fk_medicine_reminders_medicine_id`
        FOREIGN KEY (`medicine_id`) REFERENCES `medicines` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_medicine_reminders_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 7. HEALTH RECORDS: Clinical summaries, allergies, chronic conditions & labs
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_records` (
    `id`                  VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `senior_id`           VARCHAR(36)   NOT NULL COMMENT 'FK to senior_profiles',
    `title`               VARCHAR(200)  NOT NULL,
    `record_type`         VARCHAR(50)   NOT NULL COMMENT 'vitals | lab_test | doctor_summary | prescription',
    `allergies`           TEXT          DEFAULT NULL COMMENT 'Known drug or food allergies',
    `chronic_conditions`  TEXT          DEFAULT NULL COMMENT 'Hypertension, Diabetes, etc.',
    `diagnosis`           TEXT          DEFAULT NULL,
    `recorded_at`         DATETIME      NOT NULL,
    `recorded_by_user_id` VARCHAR(36)   NOT NULL COMMENT 'FK to users',
    `notes`               TEXT          DEFAULT NULL,
    `document_s3_key`     VARCHAR(500)  DEFAULT NULL,
    `created_at`          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_health_records_senior_id` (`senior_id`),
    INDEX `ix_health_records_recorded_at` (`recorded_at`),
    CONSTRAINT `fk_health_records_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_health_records_recorded_by_user_id`
        FOREIGN KEY (`recorded_by_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 8. HEALTH READINGS: Time-series vitals (blood pressure, sugar, pulse, SpO2)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_readings` (
    `id`                      VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `senior_id`               VARCHAR(36)   NOT NULL COMMENT 'FK to senior_profiles',
    `reading_type`            VARCHAR(50)   NOT NULL COMMENT 'blood_pressure | blood_sugar | pulse | oxygen | weight',
    `value_numeric`           DECIMAL(7,2)  NOT NULL COMMENT 'Primary value (e.g. Systolic BP, Sugar level)',
    `secondary_value_numeric` DECIMAL(7,2)  DEFAULT NULL COMMENT 'Secondary value (e.g. Diastolic BP)',
    `unit`                    VARCHAR(20)   NOT NULL COMMENT 'mmHg | mg/dL | bpm | % | kg',
    `measured_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `recorded_by_user_id`     VARCHAR(36)   NOT NULL COMMENT 'FK to users',
    `is_abnormal`             TINYINT(1)   NOT NULL DEFAULT 0,
    `notes`                   TEXT          DEFAULT NULL,
    `created_at`              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_health_readings_senior_id` (`senior_id`),
    INDEX `ix_health_readings_measured_at` (`measured_at`),
    INDEX `ix_health_readings_reading_type` (`reading_type`),
    CONSTRAINT `fk_health_readings_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_health_readings_recorded_by_user_id`
        FOREIGN KEY (`recorded_by_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 9. AGENCIES: Accredited third-party elderly caregiver agencies
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `agencies` (
    `id`                  VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `name`                VARCHAR(200)  NOT NULL,
    `registration_number` VARCHAR(100)  NOT NULL UNIQUE,
    `contact_email`       VARCHAR(255)  NOT NULL,
    `contact_phone`       VARCHAR(20)   NOT NULL,
    `address`             TEXT          NOT NULL,
    `city`                VARCHAR(100)  NOT NULL,
    `is_verified`         TINYINT(1)   NOT NULL DEFAULT 1,
    `rating_average`      DECIMAL(3,2)  NOT NULL DEFAULT 4.80,
    `total_caregivers`    INT           NOT NULL DEFAULT 15,
    `created_at`          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_agencies_city` (`city`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 10. DOCTORS: Certified consulting geriatricians & specialists
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `doctors` (
    `id`                     VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`                VARCHAR(36)   NOT NULL UNIQUE COMMENT 'FK to users',
    `full_name`              VARCHAR(150)  NOT NULL,
    `specialization`         VARCHAR(100)  NOT NULL,
    `medical_license_number` VARCHAR(100)  NOT NULL UNIQUE,
    `qualifications`         VARCHAR(200)  NOT NULL,
    `hospital_affiliation`   VARCHAR(200)  DEFAULT NULL,
    `consultation_fee`       DECIMAL(10,2) NOT NULL DEFAULT 500.00,
    `is_verified`            TINYINT(1)   NOT NULL DEFAULT 1,
    `rating_average`         DECIMAL(3,2)  NOT NULL DEFAULT 4.90,
    `service_city`           VARCHAR(100)  NOT NULL DEFAULT 'Delhi NCR',
    `created_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `ix_doctors_specialization` (`specialization`),
    INDEX `ix_doctors_service_city` (`service_city`),
    CONSTRAINT `fk_doctors_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 11. CAREGIVERS: Vetted in-home care attendants, nurses & companions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `caregivers` (
    `id`                        VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`                   VARCHAR(36)   NOT NULL UNIQUE COMMENT 'FK to users',
    `agency_id`                 VARCHAR(36)   DEFAULT NULL COMMENT 'FK to agencies',
    `full_name`                 VARCHAR(150)  NOT NULL,
    `gender`                    VARCHAR(20)   NOT NULL DEFAULT 'female',
    `bio`                       TEXT          DEFAULT NULL,
    `experience_years`          INT           NOT NULL DEFAULT 5,
    `hourly_rate`               DECIMAL(10,2) NOT NULL DEFAULT 250.00,
    `daily_rate`                DECIMAL(10,2) DEFAULT 1800.00,
    `verification_status`       VARCHAR(30)   NOT NULL DEFAULT 'verified' COMMENT 'pending | verified | rejected',
    `police_clearance_verified` TINYINT(1)   NOT NULL DEFAULT 1,
    `medical_training_verified` TINYINT(1)   NOT NULL DEFAULT 1,
    `rating_average`            DECIMAL(3,2)  NOT NULL DEFAULT 4.85,
    `total_reviews`             INT           NOT NULL DEFAULT 24,
    `is_available_for_hire`     TINYINT(1)   NOT NULL DEFAULT 1,
    `service_city`              VARCHAR(100)  NOT NULL DEFAULT 'Delhi NCR',
    `created_at`                DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`                DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `ix_caregivers_service_city` (`service_city`),
    INDEX `ix_caregivers_verification_status` (`verification_status`),
    CONSTRAINT `fk_caregivers_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_caregivers_agency_id`
        FOREIGN KEY (`agency_id`) REFERENCES `agencies` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 12. APPOINTMENTS: Doctor teleconsultation and clinic booking requests
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `appointments` (
    `id`                      VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `senior_id`               VARCHAR(36)   NOT NULL COMMENT 'FK to senior_profiles',
    `doctor_id`               VARCHAR(36)   NOT NULL COMMENT 'FK to doctors',
    `booked_by_user_id`       VARCHAR(36)   NOT NULL COMMENT 'FK to users',
    `scheduled_time`          DATETIME      NOT NULL,
    `appointment_type`        VARCHAR(30)   NOT NULL DEFAULT 'video_consult' COMMENT 'video_consult | clinic_visit | home_visit',
    `status`                  VARCHAR(30)   NOT NULL DEFAULT 'scheduled' COMMENT 'scheduled | completed | cancelled',
    `reason_for_consultation` TEXT          NOT NULL,
    `video_room_id`           VARCHAR(100)  DEFAULT NULL,
    `doctor_notes`            TEXT          DEFAULT NULL,
    `fee_amount`              DECIMAL(10,2) NOT NULL DEFAULT 500.00,
    `payment_status`          VARCHAR(30)   NOT NULL DEFAULT 'paid' COMMENT 'pending | paid | refunded',
    `created_at`              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `ix_appointments_senior_id` (`senior_id`),
    INDEX `ix_appointments_doctor_id` (`doctor_id`),
    INDEX `ix_appointments_scheduled_time` (`scheduled_time`),
    INDEX `ix_appointments_status` (`status`),
    CONSTRAINT `fk_appointments_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_appointments_doctor_id`
        FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_appointments_booked_by_user_id`
        FOREIGN KEY (`booked_by_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 13. CAREGIVER BOOKINGS: In-home care shift reservations & tracking
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `caregiver_bookings` (
    `id`                   VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `senior_id`            VARCHAR(36)   NOT NULL COMMENT 'FK to senior_profiles',
    `booked_by_user_id`    VARCHAR(36)   NOT NULL COMMENT 'FK to users',
    `agency_id`            VARCHAR(36)   DEFAULT NULL COMMENT 'FK to agencies',
    `caregiver_id`         VARCHAR(36)   NOT NULL COMMENT 'FK to caregivers',
    `booking_type`         VARCHAR(30)   NOT NULL DEFAULT 'daily' COMMENT 'hourly | daily | weekly | monthly',
    `start_datetime`       DATETIME      NOT NULL,
    `end_datetime`         DATETIME      NOT NULL,
    `special_instructions` TEXT          DEFAULT NULL,
    `total_hours`          DECIMAL(5,2)  NOT NULL DEFAULT 8.00,
    `hourly_rate_agreed`   DECIMAL(10,2) NOT NULL DEFAULT 250.00,
    `total_amount`         DECIMAL(10,2) NOT NULL DEFAULT 2000.00,
    `payment_status`       VARCHAR(30)   NOT NULL DEFAULT 'paid' COMMENT 'unpaid | paid | refunded',
    `status`               VARCHAR(30)   NOT NULL DEFAULT 'confirmed' COMMENT 'requested | confirmed | in_progress | completed | cancelled',
    `created_at`           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `ix_caregiver_bookings_senior_id` (`senior_id`),
    INDEX `ix_caregiver_bookings_caregiver_id` (`caregiver_id`),
    INDEX `ix_caregiver_bookings_start_datetime` (`start_datetime`),
    INDEX `ix_caregiver_bookings_status` (`status`),
    CONSTRAINT `fk_caregiver_bookings_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_caregiver_bookings_caregiver_id`
        FOREIGN KEY (`caregiver_id`) REFERENCES `caregivers` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_caregiver_bookings_booked_by_user_id`
        FOREIGN KEY (`booked_by_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_caregiver_bookings_agency_id`
        FOREIGN KEY (`agency_id`) REFERENCES `agencies` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 14. NOTIFICATIONS: Push alerts, medicine rings, family visit notices
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
    `id`                  VARCHAR(36)  NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`             VARCHAR(36)  NOT NULL COMMENT 'FK to users',
    `title`               VARCHAR(200) NOT NULL,
    `body`                TEXT         NOT NULL,
    `category`            VARCHAR(50)  NOT NULL COMMENT 'medicine_reminder | sos_emergency | caregiver_update | appointment',
    `deep_link_screen`    VARCHAR(100) DEFAULT NULL,
    `reference_entity_id` VARCHAR(36)  DEFAULT NULL,
    `is_read`             TINYINT(1)  NOT NULL DEFAULT 0,
    `sent_at`             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `read_at`             DATETIME     DEFAULT NULL,
    INDEX `ix_notifications_user_id` (`user_id`),
    INDEX `ix_notifications_is_read` (`is_read`),
    CONSTRAINT `fk_notifications_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 15. SUBSCRIPTIONS: SeniorCare membership tiers and benefits
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `subscriptions` (
    `id`          VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`     VARCHAR(36)   NOT NULL COMMENT 'FK to users',
    `plan_code`   VARCHAR(50)   NOT NULL COMMENT 'basic_monthly | family_monthly | premium_monthly',
    `plan_name`   VARCHAR(100)  NOT NULL,
    `price_inr`   DECIMAL(10,2) NOT NULL,
    `status`      VARCHAR(30)   NOT NULL DEFAULT 'active' COMMENT 'active | expired | cancelled | trial',
    `start_date`  DATE          NOT NULL,
    `end_date`    DATE          NOT NULL,
    `auto_renew`  TINYINT(1)   NOT NULL DEFAULT 1,
    `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `ix_subscriptions_user_id` (`user_id`),
    INDEX `ix_subscriptions_status` (`status`),
    CONSTRAINT `fk_subscriptions_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 16. PAYMENTS: Financial ledger for memberships, consults, and care visits
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `payments` (
    `id`                 VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`            VARCHAR(36)   NOT NULL COMMENT 'FK to users',
    `amount_inr`         DECIMAL(10,2) NOT NULL,
    `currency`           VARCHAR(10)   NOT NULL DEFAULT 'INR',
    `purpose`            VARCHAR(50)   NOT NULL COMMENT 'subscription | booking | appointment | lab_test',
    `reference_id`       VARCHAR(36)   DEFAULT NULL COMMENT 'FK to bookings / appointments',
    `gateway_provider`   VARCHAR(30)   NOT NULL DEFAULT 'razorpay' COMMENT 'razorpay | stripe',
    `gateway_order_id`   VARCHAR(100)  DEFAULT NULL,
    `gateway_payment_id` VARCHAR(100)  DEFAULT NULL,
    `status`             VARCHAR(30)   NOT NULL DEFAULT 'captured' COMMENT 'created | captured | failed | refunded',
    `receipt_url`        VARCHAR(500)  DEFAULT NULL,
    `created_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_payments_user_id` (`user_id`),
    INDEX `ix_payments_status` (`status`),
    CONSTRAINT `fk_payments_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 17. AI CHAT HISTORY: RAM AI assistant conversation history & privacy controls
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ai_chat_history` (
    `id`              VARCHAR(36)  NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`         VARCHAR(36)  NOT NULL COMMENT 'FK to users',
    `senior_id`       VARCHAR(36)  DEFAULT NULL COMMENT 'FK to senior_profiles',
    `session_id`      VARCHAR(64)  NOT NULL COMMENT 'Unique chat session token',
    `role`            VARCHAR(20)  NOT NULL COMMENT 'user | assistant | system',
    `assistant_name`  VARCHAR(20)  NOT NULL DEFAULT 'RAM' COMMENT 'RAM AI Assistant',
    `message_text`    TEXT         NOT NULL,
    `intent_detected` VARCHAR(100) DEFAULT NULL COMMENT 'medicine_inquiry | reminder_query | sos_trigger | general',
    `is_private`      TINYINT(1)  NOT NULL DEFAULT 1 COMMENT 'Enforces senior privacy controls',
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_ai_chat_user_id` (`user_id`),
    INDEX `ix_ai_chat_session_id` (`session_id`),
    CONSTRAINT `fk_ai_chat_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_ai_chat_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- SUPPORTING TABLES: Devices & Auth Sessions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `devices` (
    `id`             VARCHAR(36)  NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`        VARCHAR(36)  NOT NULL,
    `device_uuid`    VARCHAR(100) NOT NULL,
    `fcm_token`      TEXT         DEFAULT NULL,
    `platform`       VARCHAR(20)  NOT NULL DEFAULT 'android',
    `device_model`   VARCHAR(100) DEFAULT NULL,
    `app_version`    VARCHAR(20)  DEFAULT NULL,
    `last_active_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_devices_user_id` (`user_id`),
    INDEX `ix_devices_device_uuid` (`device_uuid`),
    CONSTRAINT `fk_devices_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `refresh_tokens` (
    `id`         VARCHAR(36)  NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `user_id`    VARCHAR(36)  NOT NULL,
    `device_id`  VARCHAR(36)  NOT NULL,
    `token_hash` VARCHAR(255) NOT NULL UNIQUE,
    `expires_at` DATETIME     NOT NULL,
    `is_revoked` TINYINT(1)  NOT NULL DEFAULT 0,
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_refresh_tokens_user_id` (`user_id`),
    INDEX `ix_refresh_tokens_token_hash` (`token_hash`),
    CONSTRAINT `fk_refresh_tokens_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_refresh_tokens_device_id`
        FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sos_events` (
    `id`                   VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `senior_id`            VARCHAR(36)   NOT NULL,
    `triggered_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `trigger_source`       VARCHAR(30)   NOT NULL DEFAULT 'in_app_button',
    `latitude`             DECIMAL(10,8) NOT NULL,
    `longitude`            DECIMAL(11,8) NOT NULL,
    `approximate_address`  TEXT          DEFAULT NULL,
    `battery_level_percent` INT          DEFAULT NULL,
    `status`               VARCHAR(30)   NOT NULL DEFAULT 'active',
    `acknowledged_at`      DATETIME      DEFAULT NULL,
    `resolved_at`          DATETIME      DEFAULT NULL,
    `resolved_by_user_id`  VARCHAR(36)   DEFAULT NULL,
    `resolution_notes`     TEXT          DEFAULT NULL,
    `broadcast_payload`    JSON          DEFAULT NULL,
    INDEX `ix_sos_events_senior_id` (`senior_id`),
    CONSTRAINT `fk_sos_events_senior_id`
        FOREIGN KEY (`senior_id`) REFERENCES `senior_profiles` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id`                 VARCHAR(36)  NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    `actor_user_id`      VARCHAR(36)  NOT NULL,
    `target_entity_type` VARCHAR(50)  NOT NULL,
    `target_entity_id`   VARCHAR(36)  NOT NULL,
    `action`             VARCHAR(50)  NOT NULL,
    `ip_address`         VARCHAR(45)  DEFAULT NULL,
    `details_json`       JSON         DEFAULT NULL,
    `created_at`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_audit_logs_actor_user_id` (`actor_user_id`),
    CONSTRAINT `fk_audit_logs_actor_user_id`
        FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- COMPATIBILITY VIEWS for existing backend services
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW `family_relationships` AS
SELECT
    `id`,
    `senior_id`,
    `family_user_id`,
    `relationship_type` AS `relation_type`,
    `is_primary_caregiver_contact`,
    `is_emergency_contact`,
    `status`,
    `created_at`,
    `updated_at`
FROM `family_members`;

CREATE OR REPLACE VIEW `caregiver_profiles` AS
SELECT
    `id`,
    `user_id`,
    `full_name`,
    `gender`,
    `bio`,
    `experience_years`,
    `hourly_rate`,
    `daily_rate`,
    `verification_status`,
    `police_clearance_verified`,
    `medical_training_verified`,
    `rating_average`,
    `total_reviews`,
    `is_available_for_hire`,
    `service_city`,
    `created_at`,
    `updated_at`
FROM `caregivers`;

CREATE OR REPLACE VIEW `doctor_profiles` AS
SELECT
    `id`,
    `user_id`,
    `full_name`,
    `specialization`,
    `medical_license_number`,
    `qualifications`,
    `hospital_affiliation`,
    `consultation_fee`,
    `is_verified`,
    `rating_average`,
    `created_at`,
    `updated_at`
FROM `doctors`;

CREATE OR REPLACE VIEW `bookings` AS
SELECT
    `id`,
    `senior_id`,
    `booked_by_user_id`,
    `caregiver_id`,
    `agency_id` AS `service_id`,
    `booking_type`,
    `start_datetime`,
    `end_datetime`,
    `special_instructions`,
    `total_hours`,
    `hourly_rate_agreed`,
    `total_amount`,
    `payment_status`,
    `status`,
    `created_at`,
    `updated_at`
FROM `caregiver_bookings`;

CREATE OR REPLACE VIEW `doctor_appointments` AS
SELECT
    `id`,
    `senior_id`,
    `doctor_id`,
    `booked_by_user_id`,
    `scheduled_time`,
    `appointment_type`,
    `status`,
    `reason_for_consultation`,
    `video_room_id`,
    `doctor_notes`,
    `fee_amount`,
    `payment_status`,
    `created_at`,
    `updated_at`
FROM `appointments`;

-- ---------------------------------------------------------------------------
-- SEED DATA: Demo Users, Profiles, Medicines (3 Transparent Bottles) & Data
-- ---------------------------------------------------------------------------

-- 1. Demo Agency
INSERT IGNORE INTO `agencies` (`id`, `name`, `registration_number`, `contact_email`, `contact_phone`, `address`, `city`, `is_verified`, `rating_average`, `total_caregivers`)
VALUES (
    'a1111111-1111-1111-1111-111111111111',
    'Seva ElderCare Network',
    'REG-DEL-2024-8842',
    'care@sevaeldercare.in',
    '+911145678900',
    'Connaught Place, Central Delhi',
    'Delhi NCR',
    1,
    4.90,
    30
);

-- 2. Demo Users (Argon2id hashes for demo passwords)
-- ValidPassword123! => $argon2id$v=19$m=65536,t=3,p=4$...
INSERT IGNORE INTO `users` (`id`, `phone_number`, `email`, `hashed_password`, `role`, `is_active`, `is_verified`)
VALUES
    ('u1111111-1111-1111-1111-111111111111', '+919876543210', 'kailash.sharma@example.com', '$argon2id$v=19$m=65536,t=3,p=4$l78f/dG8sK9R+1Xw2P5yKg$8tVJn/jN4ZlJ9/4t3L2a8B7c6D5e4F3g2H1i0J9k8L7', 'senior', 1, 1),
    ('u2222222-2222-2222-2222-222222222222', '+919812345678', 'rajesh.sharma@example.com',  '$argon2id$v=19$m=65536,t=3,p=4$m89g/eH9tL0S+2Yx3Q6zLh$9uWKo/kO5AmK0/5u4M3b9C8d7E6f5G4h3I2j1K0l9M8', 'family', 1, 1),
    ('u3333333-3333-3333-3333-333333333333', '+919845678901', 'anjali.rao@example.com',    '$argon2id$v=19$m=65536,t=3,p=4$n90h/fI0uM1T+3Zy4R7aMi$0vXLp/lP6BnL1/6v5N4c0D9e8F7g6H5i4J3k2L1m0N9', 'caregiver', 1, 1),
    ('u4444444-4444-4444-4444-444444444444', '+919899112233', 'dr.verma@example.com',       '$argon2id$v=19$m=65536,t=3,p=4$o01i/gJ1vN2U+4Az5S8bNj$1wYMq/mQ7CoM2/7w6O5d1E0f9G8h7I6j5K4l3M2n1O0', 'doctor', 1, 1);

-- 3. Senior Citizen Profile (Kailash Chand Sharma)
INSERT IGNORE INTO `senior_profiles` (`id`, `user_id`, `full_name`, `preferred_name`, `date_of_birth`, `gender`, `blood_group`, `address`, `city`, `postal_code`, `primary_language`, `emergency_notes`)
VALUES (
    's1111111-1111-1111-1111-111111111111',
    'u1111111-1111-1111-1111-111111111111',
    'Kailash Chand Sharma',
    'Dadaji',
    '1948-03-20',
    'male',
    'B+',
    'B-42, Vasant Kunj',
    'New Delhi',
    '110070',
    'hi',
    'Penicillin allergy. Diabetic. Mild hypertension.'
);

-- 4. Family Member Link
INSERT IGNORE INTO `family_members` (`id`, `senior_id`, `family_user_id`, `relationship_type`, `is_primary_caregiver_contact`, `is_emergency_contact`, `can_manage_medications`, `can_view_records`, `can_book_services`, `status`)
VALUES (
    'f1111111-1111-1111-1111-111111111111',
    's1111111-1111-1111-1111-111111111111',
    'u2222222-2222-2222-2222-222222222222',
    'son',
    1,
    1,
    1,
    1,
    1,
    'active'
);

-- 5. Emergency Contacts
INSERT IGNORE INTO `emergency_contacts` (`id`, `senior_id`, `contact_name`, `relation`, `phone_number`, `is_primary`)
VALUES
    ('e1111111-1111-1111-1111-111111111111', 's1111111-1111-1111-1111-111111111111', 'Rajesh Sharma', 'Son', '+919812345678', 1),
    ('e2222222-2222-2222-2222-222222222222', 's1111111-1111-1111-1111-111111111111', 'Priya Sharma',  'Daughter', '+919811223344', 0),
    ('e3333333-3333-3333-3333-333333333333', 's1111111-1111-1111-1111-111111111111', 'Max Hospital ER', 'Emergency', '+911126515050', 0);

-- 6. MEDICINES: Exact 3 Medicines for the 3 Transparent Medicine Bottles
INSERT IGNORE INTO `medicines` (`id`, `senior_id`, `name`, `dosage_strength`, `form`, `meal_relation`, `bottle_quantity_remaining`, `bottle_total_quantity`, `color_code`, `start_date`, `end_date`, `instructions`, `is_active`)
VALUES
    ('m1111111-1111-1111-1111-111111111111', 's1111111-1111-1111-1111-111111111111', 'Metformin HCl', '500 mg', 'tablet',  'after_meal', 24, 30, '#1E88E5', '2026-01-01', '2026-12-31', 'Take 1 tablet after breakfast and dinner', 1),
    ('m2222222-2222-2222-2222-222222222222', 's1111111-1111-1111-1111-111111111111', 'Amlodipine',    '5 mg',   'tablet',  'after_meal', 18, 30, '#43A047', '2026-01-01', '2026-12-31', 'Take 1 tablet in the morning after breakfast', 1),
    ('m3333333-3333-3333-3333-333333333333', 's1111111-1111-1111-1111-111111111111', 'Atorvastatin',  '10 mg',  'capsule', 'after_meal', 12, 30, '#FB8C00', '2026-01-01', '2026-12-31', 'Take 1 capsule at night after dinner', 1);

-- 7. Medicine Reminders
INSERT IGNORE INTO `medicine_reminders` (`id`, `medicine_id`, `senior_id`, `reminder_time`, `dosage_quantity`, `days_of_week`, `is_active`, `status`)
VALUES
    ('r1111111-1111-1111-1111-111111111111', 'm1111111-1111-1111-1111-111111111111', 's1111111-1111-1111-1111-111111111111', '08:30:00', 1.00, '[1,2,3,4,5,6,7]', 1, 'taken'),
    ('r2222222-2222-2222-2222-222222222222', 'm2222222-2222-2222-2222-222222222222', 's1111111-1111-1111-1111-111111111111', '08:30:00', 1.00, '[1,2,3,4,5,6,7]', 1, 'taken'),
    ('r3333333-3333-3333-3333-333333333333', 'm3333333-3333-3333-3333-333333333333', 's1111111-1111-1111-1111-111111111111', '20:30:00', 1.00, '[1,2,3,4,5,6,7]', 1, 'pending');

-- 8. Health Records
INSERT IGNORE INTO `health_records` (`id`, `senior_id`, `title`, `record_type`, `allergies`, `chronic_conditions`, `diagnosis`, `recorded_at`, `recorded_by_user_id`, `notes`)
VALUES (
    'hr111111-1111-1111-1111-111111111111',
    's1111111-1111-1111-1111-111111111111',
    'Quarterly Health Assessment',
    'doctor_summary',
    'Penicillin allergy',
    'Type 2 Diabetes Mellitus, Stage 1 Hypertension',
    'Stable condition. Blood sugar well managed on Metformin.',
    '2026-10-15 11:30:00',
    'u4444444-4444-4444-4444-444444444444',
    'Advised morning walk and 2.5L water daily.'
);

-- 9. Health Readings
INSERT IGNORE INTO `health_readings` (`id`, `senior_id`, `reading_type`, `value_numeric`, `secondary_value_numeric`, `unit`, `measured_at`, `recorded_by_user_id`, `is_abnormal`, `notes`)
VALUES
    ('rd111111-1111-1111-1111-111111111111', 's1111111-1111-1111-1111-111111111111', 'blood_pressure', 124.00, 82.00, 'mmHg', '2026-11-12 08:00:00', 'u1111111-1111-1111-1111-111111111111', 0, 'Morning resting BP'),
    ('rd222222-2222-2222-2222-222222222222', 's1111111-1111-1111-1111-111111111111', 'blood_sugar',    118.00, NULL,  'mg/dL', '2026-11-12 08:15:00', 'u1111111-1111-1111-1111-111111111111', 0, 'Fasting blood glucose'),
    ('rd333333-3333-3333-3333-333333333333', 's1111111-1111-1111-1111-111111111111', 'pulse',          72.00,  NULL,  'bpm',   '2026-11-12 08:00:00', 'u1111111-1111-1111-1111-111111111111', 0, 'Normal resting rhythm');

-- 10. Doctor Profile
INSERT IGNORE INTO `doctors` (`id`, `user_id`, `full_name`, `specialization`, `medical_license_number`, `qualifications`, `hospital_affiliation`, `consultation_fee`, `is_verified`, `rating_average`, `service_city`)
VALUES (
    'd1111111-1111-1111-1111-111111111111',
    'u4444444-4444-4444-4444-444444444444',
    'Dr. Sameer Verma',
    'Geriatric Medicine & Internal Care',
    'MCI-DL-2012-44912',
    'MBBS, MD (Medicine), Fellow in Geriatrics',
    'Max Super Speciality Hospital, Saket',
    600.00,
    1,
    4.92,
    'Delhi NCR'
);

-- 11. Caregiver Profile
INSERT IGNORE INTO `caregivers` (`id`, `user_id`, `agency_id`, `full_name`, `gender`, `bio`, `experience_years`, `hourly_rate`, `daily_rate`, `verification_status`, `police_clearance_verified`, `medical_training_verified`, `rating_average`, `total_reviews`, `is_available_for_hire`, `service_city`)
VALUES (
    'c1111111-1111-1111-1111-111111111111',
    'u3333333-3333-3333-3333-333333333333',
    'a1111111-1111-1111-1111-111111111111',
    'Anjali Rao',
    'female',
    'Certified geriatric nursing specialist with 8 years of intensive elderly care experience.',
    8,
    300.00,
    2200.00,
    'verified',
    1,
    1,
    4.90,
    42,
    1,
    'Delhi NCR'
);

-- 12. Doctor Appointment Booking
INSERT IGNORE INTO `appointments` (`id`, `senior_id`, `doctor_id`, `booked_by_user_id`, `scheduled_time`, `appointment_type`, `status`, `reason_for_consultation`, `fee_amount`, `payment_status`)
VALUES (
    'apt11111-1111-1111-1111-111111111111',
    's1111111-1111-1111-1111-111111111111',
    'd1111111-1111-1111-1111-111111111111',
    'u2222222-2222-2222-2222-222222222222',
    '2026-11-18 10:00:00',
    'video_consult',
    'scheduled',
    'Routine diabetes follow-up and blood pressure review',
    600.00,
    'paid'
);

-- 13. Caregiver Booking
INSERT IGNORE INTO `caregiver_bookings` (`id`, `senior_id`, `booked_by_user_id`, `agency_id`, `caregiver_id`, `booking_type`, `start_datetime`, `end_datetime`, `special_instructions`, `total_hours`, `hourly_rate_agreed`, `total_amount`, `payment_status`, `status`)
VALUES (
    'bkg11111-1111-1111-1111-111111111111',
    's1111111-1111-1111-1111-111111111111',
    'u2222222-2222-2222-2222-222222222222',
    'a1111111-1111-1111-1111-111111111111',
    'c1111111-1111-1111-1111-111111111111',
    'daily',
    '2026-11-15 09:00:00',
    '2026-11-15 17:00:00',
    'Assist with morning mobility exercises, medication reminders, and lunch prep',
    8.00,
    275.00,
    2200.00,
    'paid',
    'confirmed'
);

-- 14. Notifications
INSERT IGNORE INTO `notifications` (`id`, `user_id`, `title`, `body`, `category`, `deep_link_screen`, `is_read`)
VALUES
    ('n1111111-1111-1111-1111-111111111111', 'u1111111-1111-1111-1111-111111111111', 'Morning Medicine Alert', 'Time to take Metformin (500mg) and Amlodipine (5mg)', 'medicine_reminder', 'reminders', 1),
    ('n2222222-2222-2222-2222-222222222222', 'u1111111-1111-1111-1111-111111111111', 'Upcoming Video Consult', 'Dr. Sameer Verma consult scheduled for Nov 18, 10:00 AM', 'appointment', 'appointments', 0),
    ('n3333333-3333-3333-3333-333333333333', 'u2222222-2222-2222-2222-222222222222', 'Caregiver Confirmed', 'Anjali Rao confirmed visit for Nov 15, 9:00 AM - 5:00 PM', 'caregiver_update', 'caregivers', 0);

-- 15. Subscriptions
INSERT IGNORE INTO `subscriptions` (`id`, `user_id`, `plan_code`, `plan_name`, `price_inr`, `status`, `start_date`, `end_date`, `auto_renew`)
VALUES (
    'sub11111-1111-1111-1111-111111111111',
    'u2222222-2222-2222-2222-222222222222',
    'family_monthly',
    'Elderly Seva Family Guardian Plan',
    599.00,
    'active',
    '2026-11-01',
    '2026-12-01',
    1
);

-- 16. Payments
INSERT IGNORE INTO `payments` (`id`, `user_id`, `amount_inr`, `currency`, `purpose`, `reference_id`, `gateway_provider`, `gateway_order_id`, `gateway_payment_id`, `status`, `receipt_url`)
VALUES
    ('pay11111-1111-1111-1111-111111111111', 'u2222222-2222-2222-2222-222222222222', 599.00,  'INR', 'subscription', 'sub11111-1111-1111-1111-111111111111', 'razorpay', 'order_ES89421', 'pay_ES1001', 'captured', 'https://receipts.elderlyseva.in/sub_nov2026.pdf'),
    ('pay22222-2222-2222-2222-222222222222', 'u2222222-2222-2222-2222-222222222222', 2200.00, 'INR', 'booking',      'bkg11111-1111-1111-1111-111111111111', 'razorpay', 'order_ES89422', 'pay_ES1002', 'captured', 'https://receipts.elderlyseva.in/care_nov2026.pdf');

-- 17. AI Chat History (RAM AI Assistant)
INSERT IGNORE INTO `ai_chat_history` (`id`, `user_id`, `senior_id`, `session_id`, `role`, `assistant_name`, `message_text`, `intent_detected`, `is_private`)
VALUES
    ('ai111111-1111-1111-1111-111111111111', 'u1111111-1111-1111-1111-111111111111', 's1111111-1111-1111-1111-111111111111', 'sess_ram_001', 'user',      'RAM', 'नमस्ते राम, मुझे आज कौन सी दवाई लेनी है?', 'medicine_inquiry', 1),
    ('ai222222-2222-2222-2222-222222222222', 'u1111111-1111-1111-1111-111111111111', 's1111111-1111-1111-1111-111111111111', 'sess_ram_001', 'assistant', 'RAM', 'नमस्ते दादाजी! आपने सुबह की मेटफॉर्मिन और एम्लोडिपिन ले ली है। रात के खाने के बाद 8:30 बजे एटोरवास्टेटिन की 1 गोली लेनी है।', 'medicine_inquiry', 1);

SET FOREIGN_KEY_CHECKS = 1;
