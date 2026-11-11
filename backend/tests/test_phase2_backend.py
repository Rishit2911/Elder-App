import hashlib
import io
import random
import uuid
import cv2
import numpy as np
import pytest
from fastapi.testclient import TestClient

from app.core.security import (
    create_access_token, decode_access_token,
    decrypt_face_embedding, encrypt_face_embedding,
    hash_password, verify_password
)
from app.services.face_service import face_service


# Helper function to generate a test portrait image
def create_test_face_image(variation: int = 0) -> bytes:
    img = np.full((320, 320, 3), (230, 230, 230), dtype=np.uint8)
    cv2.ellipse(img, (160, 160), (70, 90), 0, 0, 360, (140, 165, 215), -1)
    cv2.circle(img, (135, 135), 10, (40, 40, 40), -1)
    cv2.circle(img, (185, 135), 10, (40, 40, 40), -1)
    cv2.ellipse(img, (160, 200), (25, 10), 0, 0, 180, (60, 60, 180), -1)

    if variation != 0:
        img = np.clip(img.astype(np.int16) + variation, 0, 255).astype(np.uint8)

    _, buf = cv2.imencode(".jpg", img)
    return buf.tobytes()


def create_different_face_image() -> bytes:
    img = np.full((320, 320, 3), (230, 230, 230), dtype=np.uint8)
    cv2.circle(img, (160, 160), 50, (110, 140, 190), -1)
    cv2.circle(img, (130, 150), 6, (20, 20, 20), -1)
    cv2.circle(img, (190, 150), 6, (20, 20, 20), -1)
    _, buf = cv2.imencode(".jpg", img)
    return buf.tobytes()


# ==============================================================================
# 1. Cryptography, Passwords & Biometric Units
# ==============================================================================

def test_argon2id_password_hashing():
    raw = "MySuperSecretPassword#2026"
    hashed = hash_password(raw)
    assert hashed != raw
    assert hashed.startswith("$argon2id$")
    assert verify_password(raw, hashed) is True
    assert verify_password("WrongPassword123", hashed) is False


def test_jwt_access_token_lifecycle():
    user_id = str(uuid.uuid4())
    token = create_access_token(subject=user_id, role="family")
    payload = decode_access_token(token)
    assert payload is not None
    assert payload["sub"] == user_id
    assert payload["role"] == "family"
    assert payload["type"] == "access"

    tampered = token[:-4] + "fake"
    assert decode_access_token(tampered) is None


def test_aes_256_gcm_embedding_encryption():
    raw_vector = np.random.randn(512).astype(np.float32).tobytes()
    ciphertext, iv, tag = encrypt_face_embedding(raw_vector)
    assert len(iv) == 12
    assert len(tag) == 16
    assert ciphertext != raw_vector

    decrypted = decrypt_face_embedding(ciphertext, iv, tag)
    assert decrypted == raw_vector


def test_face_biometrics_feature_extraction_and_matching():
    face1_bytes = create_test_face_image(variation=0)
    face2_bytes = create_test_face_image(variation=5)
    diff_face_bytes = create_different_face_image()

    img1 = face_service.validate_and_decode_image(face1_bytes)
    img2 = face_service.validate_and_decode_image(face2_bytes)
    img3 = face_service.validate_and_decode_image(diff_face_bytes)

    crop1, q1 = face_service.detect_face(img1)
    crop2, q2 = face_service.detect_face(img2)
    crop3, q3 = face_service.detect_face(img3)

    assert q1 > 0.3
    liveness = face_service.verify_liveness(crop1)
    assert 0.35 <= liveness <= 1.0

    emb1 = face_service.extract_embedding(crop1)
    emb2 = face_service.extract_embedding(crop2)
    emb3 = face_service.extract_embedding(crop3)

    assert len(emb1) == 512 * 4

    sim_same = face_service.compute_similarity(emb1, emb2)
    sim_diff = face_service.compute_similarity(emb1, emb3)

    assert sim_same >= 0.85, f"Expected same identity similarity >= 0.85, got {sim_same}"
    assert sim_diff < 0.60, f"Expected different identity similarity < 0.60, got {sim_diff}"


# ==============================================================================
# 2. Registration & Input Validation Endpoints
# ==============================================================================

def test_universal_registration(client: TestClient):
    unique_phone = f"+9198{random.randint(10000000, 99999999)}"
    payload = {
        "fullName": "Aarav Sharma",
        "email": f"aarav_{uuid.uuid4().hex[:6]}@example.com",
        "phoneNumber": unique_phone,
        "password": "SecurePassword123!",
        "role": "family"
    }
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    res = response.json()
    assert res["success"] is True
    assert res["data"]["phoneNumber"] == unique_phone
    assert res["data"]["role"] == "family"


def test_senior_registration_endpoint(client: TestClient):
    unique_phone = f"+9197{random.randint(10000000, 99999999)}"
    payload = {
        "fullName": "Kailash Chand Sharma",
        "preferredName": "दादाजी",
        "phoneNumber": unique_phone,
        "email": f"kailash_{uuid.uuid4().hex[:6]}@example.com",
        "password": "Password1234!",
        "dateOfBirth": "1948-03-20",
        "gender": "male",
        "bloodGroup": "O+",
        "address": "B-42 Anand Vihar",
        "city": "Jaipur",
        "postalCode": "302015",
        "primaryLanguage": "hi"
    }
    response = client.post("/api/v1/auth/register/senior", json=payload)
    assert response.status_code == 201
    res = response.json()
    assert res["success"] is True
    assert res["data"]["role"] == "senior"
    assert "seniorProfileId" in res["data"]


def test_family_registration_endpoint(client: TestClient):
    unique_phone = f"+9196{random.randint(10000000, 99999999)}"
    payload = {
        "fullName": "Meera Sharma",
        "email": f"meera_{uuid.uuid4().hex[:6]}@example.com",
        "phoneNumber": unique_phone,
        "password": "Password1234!",
        "relationshipType": "daughter"
    }
    response = client.post("/api/v1/auth/register/family", json=payload)
    assert response.status_code == 201
    res = response.json()
    assert res["success"] is True
    assert res["data"]["role"] == "family"


def test_duplicate_phone_rejection(client: TestClient):
    unique_phone = f"+9195{random.randint(10000000, 99999999)}"
    payload = {
        "fullName": "Duplicate Test",
        "phoneNumber": unique_phone,
        "password": "Password123!",
        "role": "family"
    }
    res1 = client.post("/api/v1/auth/register", json=payload)
    assert res1.status_code == 201

    res2 = client.post("/api/v1/auth/register", json=payload)
    assert res2.status_code == 409
    assert "already registered" in res2.json()["detail"]


def test_invalid_input_validation(client: TestClient):
    payload = {
        "fullName": "A",
        "phoneNumber": "123",
        "password": "123",
        "role": "invalid_role"
    }
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 422


# ==============================================================================
# 3. Authentication, Token Rotation & Logout
# ==============================================================================

def test_login_and_token_rotation(client: TestClient):
    unique_phone = f"+9194{random.randint(10000000, 99999999)}"
    password = "MyStrongPassword123#"
    reg = client.post("/api/v1/auth/register", json={
        "fullName": "Auth Test User",
        "phoneNumber": unique_phone,
        "password": password,
        "role": "family"
    })
    assert reg.status_code == 201

    # Bad password
    bad_login = client.post("/api/v1/auth/login", json={
        "emailOrPhone": unique_phone,
        "password": "WrongPassword!"
    })
    assert bad_login.status_code == 401

    # Successful login
    login_res = client.post("/api/v1/auth/login", json={
        "emailOrPhone": unique_phone,
        "password": password
    })
    assert login_res.status_code == 200
    res_data = login_res.json()["data"]
    access_token = res_data["access_token"]
    refresh_token = res_data["refresh_token"]

    # Verify access token works on /auth/me
    me_res = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {access_token}"})
    assert me_res.status_code == 200
    assert me_res.json()["data"]["phoneNumber"] == unique_phone

    # Rotate refresh token
    refresh_res = client.post("/api/v1/auth/refresh", json={
        "refreshToken": refresh_token
    })
    assert refresh_res.status_code == 200
    new_refresh = refresh_res.json()["data"]["refresh_token"]
    new_access = refresh_res.json()["data"]["access_token"]
    assert new_refresh != refresh_token

    # Single-use rotation: old token is revoked
    reused_res = client.post("/api/v1/auth/refresh", json={
        "refreshToken": refresh_token
    })
    assert reused_res.status_code == 401

    # Logout
    logout_res = client.post(
        "/api/v1/auth/logout",
        json={"refreshToken": new_refresh},
        headers={"Authorization": f"Bearer {new_access}"}
    )
    assert logout_res.status_code == 200


# ==============================================================================
# 4. User Profile Management
# ==============================================================================

def test_user_profile_management(client: TestClient):
    unique_phone = f"+9193{random.randint(10000000, 99999999)}"
    reg = client.post("/api/v1/auth/register", json={
        "fullName": "Profile User",
        "phoneNumber": unique_phone,
        "password": "Password123!",
        "role": "family"
    })
    assert reg.status_code == 201

    login = client.post("/api/v1/auth/login", json={
        "emailOrPhone": unique_phone,
        "password": "Password123!"
    })
    assert login.status_code == 200
    token = login.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    get_res = client.get("/api/v1/users/me", headers=headers)
    assert get_res.status_code == 200
    assert get_res.json()["data"]["fullName"] == "Profile User"

    patch_res = client.patch("/api/v1/users/me", json={
        "fullName": "Updated Profile Name",
        "alternatePhone": "+919999988888"
    }, headers=headers)
    assert patch_res.status_code == 200
    assert patch_res.json()["data"]["fullName"] == "Updated Profile Name"


# ==============================================================================
# 5. Family-Senior Linking Workflow
# ==============================================================================

def test_family_senior_linking_workflow(client: TestClient):
    senior_phone = f"+9192{random.randint(10000000, 99999999)}"
    family_phone = f"+9191{random.randint(10000000, 99999999)}"

    # Register Senior
    senior_reg = client.post("/api/v1/auth/register/senior", json={
        "fullName": "Linked Dadaji",
        "phoneNumber": senior_phone,
        "password": "Password123!"
    })
    assert senior_reg.status_code == 201

    # Register Family Member
    family_reg = client.post("/api/v1/auth/register/family", json={
        "fullName": "Linked Son",
        "phoneNumber": family_phone,
        "password": "Password123!",
        "relationshipType": "son"
    })
    assert family_reg.status_code == 201

    # Login as Family
    family_login = client.post("/api/v1/auth/login", json={
        "emailOrPhone": family_phone,
        "password": "Password123!"
    })
    assert family_login.status_code == 200
    family_token = family_login.json()["data"]["access_token"]

    # Family creates invitation request targeting senior
    req_res = client.post(
        "/api/v1/family/link/request",
        json={"targetPhone": senior_phone, "relationship": "son"},
        headers={"Authorization": f"Bearer {family_token}"}
    )
    assert req_res.status_code == 201
    invitation_id = req_res.json()["data"]["invitationId"]
    invitation_code = req_res.json()["data"]["invitationCode"]
    assert invitation_code.startswith("SC-")

    # Login as Senior to approve
    senior_login = client.post("/api/v1/auth/login", json={
        "emailOrPhone": senior_phone,
        "password": "Password123!"
    })
    assert senior_login.status_code == 200
    senior_token = senior_login.json()["data"]["access_token"]

    # Senior approves connection
    approve_res = client.post(
        "/api/v1/family/link/approve",
        json={
            "invitationId": invitation_id,
            "approved": True,
            "canManageMedications": True,
            "canViewRecords": True,
            "canBookServices": True
        },
        headers={"Authorization": f"Bearer {senior_token}"}
    )
    assert approve_res.status_code == 200
    relationship_id = approve_res.json()["data"]["relationshipId"]

    # List links as Senior
    links_res = client.get("/api/v1/family/links", headers={"Authorization": f"Bearer {senior_token}"})
    assert links_res.status_code == 200
    links = links_res.json()["data"]
    assert len(links) >= 1
    assert any(l["id"] == relationship_id for l in links)

    # Revoke link
    revoke_res = client.post(
        f"/api/v1/family/links/{relationship_id}/revoke",
        headers={"Authorization": f"Bearer {senior_token}"}
    )
    assert revoke_res.status_code == 200


# ==============================================================================
# 5. Caregiver / Caretaker Dedicated Registration & Login
# ==============================================================================

def test_caregiver_registration_and_login(client: TestClient):
    unique_phone = f"+9196{random.randint(10000000, 99999999)}"
    password = "CaregiverStrong123!"

    # 1. Register caregiver
    reg_res = client.post(
        "/api/v1/auth/register/caregiver",
        json={
            "fullName": "Sunita Verma",
            "phoneNumber": unique_phone,
            "email": f"sunita_{uuid.uuid4().hex[:6]}@example.com",
            "password": password,
            "gender": "female",
            "hourlyRate": 300.0,
            "serviceCity": "Delhi NCR",
            "experienceYears": 4,
            "bio": "Certified geriatric healthcare assistant"
        }
    )
    assert reg_res.status_code == 201
    reg_data = reg_res.json()
    assert reg_data["success"] is True
    assert reg_data["data"]["role"] == "caregiver"
    assert "caregiverProfileId" in reg_data["data"]

    # 2. Caregiver Login with expected role
    login_res = client.post(
        "/api/v1/auth/login/caregiver",
        json={
            "emailOrPhone": unique_phone,
            "password": password,
            "role": "caregiver"
        }
    )
    assert login_res.status_code == 200
    login_data = login_res.json()["data"]
    assert login_data["user"]["role"] == "caregiver"
    assert "access_token" in login_data
    assert "refresh_token" in login_data

    # 3. Role enforcement: Logging in as senior must be rejected
    mismatch_login = client.post(
        "/api/v1/auth/login",
        json={
            "emailOrPhone": unique_phone,
            "password": password,
            "role": "senior"
        }
    )
    assert mismatch_login.status_code == 403


# ==============================================================================
# 6. Biometric Face API Endpoints & Verification
# ==============================================================================

def test_biometric_face_api_endpoints(client: TestClient):
    senior_phone = f"+9193{random.randint(10000000, 99999999)}"
    password = "ValidFacePassword123!"
    reg = client.post("/api/v1/auth/register/senior", json={
        "fullName": "Face Test Senior",
        "phoneNumber": senior_phone,
        "password": password,
        "age": 75,
        "gender": "male"
    })
    assert reg.status_code == 201

    login_res = client.post("/api/v1/auth/login", json={
        "emailOrPhone": senior_phone,
        "password": password
    })
    assert login_res.status_code == 200
    senior_token = login_res.json()["data"]["access_token"]

    # 1. Enroll face image
    face_bytes = create_test_face_image(variation=0)
    enroll_res = client.post(
        "/api/v1/auth/face/enroll",
        files={"face_image": ("face.jpg", face_bytes, "image/jpeg")},
        headers={"Authorization": f"Bearer {senior_token}"}
    )
    assert enroll_res.status_code == 201
    assert enroll_res.json()["success"] is True
    assert "faceProfileId" in enroll_res.json()["data"]

    # 2. Verify face with matching sample
    match_bytes = create_test_face_image(variation=2)
    verify_res = client.post(
        "/api/v1/auth/face/verify",
        data={"identifier": senior_phone, "device_uuid": "device-face-test"},
        files={"face_image": ("face_match.jpg", match_bytes, "image/jpeg")}
    )
    assert verify_res.status_code == 200
    assert verify_res.json()["success"] is True
    assert "access_token" in verify_res.json()["data"]

    # 3. Reject different face
    diff_bytes = create_different_face_image()
    reject_res = client.post(
        "/api/v1/auth/face/verify",
        data={"identifier": senior_phone, "device_uuid": "device-face-test"},
        files={"face_image": ("diff.jpg", diff_bytes, "image/jpeg")}
    )
    assert reject_res.status_code == 401


# ==============================================================================
# 7. User Consent & IDOR Security Controls
# ==============================================================================

def test_consent_and_idor_protection(client: TestClient):
    # Senior A
    phone_a = f"+9192{random.randint(10000000, 99999999)}"
    pass_a = "Password123!"
    reg_a = client.post("/api/v1/auth/register", json={
        "fullName": "Senior A",
        "phoneNumber": phone_a,
        "password": pass_a,
        "role": "senior"
    })
    user_a_id = reg_a.json()["data"]["id"]
    login_a = client.post("/api/v1/auth/login", json={"emailOrPhone": phone_a, "password": pass_a})
    token_a = login_a.json()["data"]["access_token"]

    # Record consent
    consent_res = client.post(
        "/api/v1/auth/consent",
        json={"consentType": "biometric_face_auth", "consentVersion": "1.0", "isGranted": True},
        headers={"Authorization": f"Bearer {token_a}"}
    )
    assert consent_res.status_code == 201
    assert consent_res.json()["success"] is True

    # User B (unrelated family member)
    phone_b = f"+9191{random.randint(10000000, 99999999)}"
    pass_b = "Password123!"
    reg_b = client.post("/api/v1/auth/register", json={
        "fullName": "Unrelated Family B",
        "phoneNumber": phone_b,
        "password": pass_b,
        "role": "family"
    })
    login_b = client.post("/api/v1/auth/login", json={"emailOrPhone": phone_b, "password": pass_b})
    token_b = login_b.json()["data"]["access_token"]

    # B attempts IDOR to read Senior A's profile -> should be forbidden (403)
    idor_res = client.get(
        f"/api/v1/users/{user_a_id}",
        headers={"Authorization": f"Bearer {token_b}"}
    )
    assert idor_res.status_code == 403

