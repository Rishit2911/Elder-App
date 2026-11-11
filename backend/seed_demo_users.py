import asyncio
from datetime import datetime, timezone
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import select
from app.database.connection import AsyncSessionLocal, engine
from app.models.users import User, SeniorProfile, FamilyProfile, CaregiverProfile, UserConsent
from app.models.family import FamilyRelationship, AccessPermission
from app.models.biometrics import FaceProfile
from app.core.security import hash_password
from app.services.face_service import face_service
from tests.test_phase2_backend import create_test_face_image


async def seed():
    print("🌱 Connecting to database to seed demo users...")
    async with AsyncSessionLocal() as db:
        # 1. Senior Citizen: +919876543210
        senior_stmt = select(User).where(User.phone_number == "+919876543210")
        existing_senior = (await db.execute(senior_stmt)).scalars().first()
        if not existing_senior:
            senior_user = User(
                phone_number="+919876543210",
                email="kailash.sharma@example.com",
                hashed_password=hash_password("ValidPassword123!"),
                role="senior",
                is_active=True,
                is_verified=True
            )
            db.add(senior_user)
            await db.flush()

            senior_profile = SeniorProfile(
                user_id=senior_user.id,
                full_name="Kailash Chand Sharma",
                preferred_name="दादाजी",
                date_of_birth=datetime(1948, 3, 20).date(),
                gender="male",
                blood_group="B+",
                primary_language="hi",
                address="B-42, Vasant Kunj",
                city="New Delhi",
                postal_code="110070"
            )
            db.add(senior_profile)
            await db.flush()

            # Consent
            consent = UserConsent(
                user_id=senior_user.id,
                consent_type="biometric_face_auth",
                consent_version="1.0",
                is_granted=True
            )
            db.add(consent)

            # Face Profile
            face_bytes = create_test_face_image()
            ciphertext, iv, tag, q_score, l_score = face_service.process_and_encrypt_enrollment(face_bytes)
            face_prof = FaceProfile(
                user_id=senior_user.id,
                encrypted_embedding=ciphertext,
                encryption_iv=iv,
                encryption_tag=tag,
                model_version="arcface_r50_v1",
                quality_score=q_score,
                liveness_score=l_score,
                is_active=True
            )
            db.add(face_prof)
            print("✅ Senior Citizen +919876543210 (Kailash Chand Sharma) created & face enrolled.")
        else:
            senior_user = existing_senior
            senior_prof_stmt = select(SeniorProfile).where(SeniorProfile.user_id == senior_user.id)
            senior_profile = (await db.execute(senior_prof_stmt)).scalars().first()
            print("ℹ️ Senior Citizen +919876543210 already exists.")

        # 2. Family Member: +919812345678
        family_stmt = select(User).where(User.phone_number == "+919812345678")
        existing_family = (await db.execute(family_stmt)).scalars().first()
        if not existing_family:
            family_user = User(
                phone_number="+919812345678",
                email="rajesh.sharma@example.com",
                hashed_password=hash_password("StrongPassword123!"),
                role="family",
                is_active=True,
                is_verified=True
            )
            db.add(family_user)
            await db.flush()

            family_profile = FamilyProfile(
                user_id=family_user.id,
                full_name="Rajesh Sharma",
                relationship_description="Son"
            )
            db.add(family_profile)
            await db.flush()

            # Link with Senior
            if senior_profile:
                rel = FamilyRelationship(
                    senior_id=senior_profile.id,
                    family_user_id=family_user.id,
                    relation_type="son",
                    is_primary_caregiver_contact=True,
                    is_emergency_contact=True,
                    status="active"
                )
                db.add(rel)
                await db.flush()

                # Access permissions
                for module in ["health_records", "medicines", "live_location", "caregiver_bookings"]:
                    perm = AccessPermission(
                        relationship_id=rel.id,
                        permission_module=module,
                        access_level="full_management"
                    )
                    db.add(perm)

            print("✅ Family Member +919812345678 (Rajesh Sharma) created & linked to Senior.")
        else:
            print("ℹ️ Family Member +919812345678 already exists.")

        # 3. Caregiver: +919845678901
        caregiver_stmt = select(User).where(User.phone_number == "+919845678901")
        existing_caregiver = (await db.execute(caregiver_stmt)).scalars().first()
        if not existing_caregiver:
            caregiver_user = User(
                phone_number="+919845678901",
                email="anjali.rao@example.com",
                hashed_password=hash_password("CaregiverPass123!"),
                role="caregiver",
                is_active=True,
                is_verified=True
            )
            db.add(caregiver_user)
            await db.flush()

            caregiver_profile = CaregiverProfile(
                user_id=caregiver_user.id,
                full_name="Anjali Rao",
                gender="female",
                bio="Certified geriatric nurse with 8 years of intensive elderly care experience.",
                experience_years=8,
                hourly_rate=300.00,
                daily_rate=2200.00,
                verification_status="verified",
                police_clearance_verified=True,
                medical_training_verified=True,
                rating_average=4.9,
                total_reviews=42,
                is_available_for_hire=True,
                service_city="Delhi NCR"
            )
            db.add(caregiver_profile)
            print("✅ Caregiver +919845678901 (Anjali Rao) created.")
        else:
            print("ℹ️ Caregiver +919845678901 already exists.")

        await db.commit()
    print("🎉 All demo accounts successfully committed to PostgreSQL database seniorcare_db!")


if __name__ == "__main__":
    asyncio.run(seed())

