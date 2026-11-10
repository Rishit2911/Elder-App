import uuid
from fastapi.testclient import TestClient


def test_senior_registration(client: TestClient):
    payload = {
        "phone_number": "+919876543210",
        "full_name": "Ramesh Sharma",
        "preferred_name": "दादाजी",
        "date_of_birth": "1952-08-15",
        "gender": "male",
        "address": "402, Shanti Niketan",
        "city": "Jaipur",
        "postal_code": "302006",
        "primary_language": "hi"
    }
    response = client.post("/api/v1/auth/register/senior", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert "OTP sent" in data["message"]


def test_auth_login(client: TestClient):
    payload = {
        "username": "+919876543210",
        "password": "ValidPassword123!",
        "device_uuid": "test-device-uuid-1",
        "platform": "android"
    }
    response = client.post("/api/v1/auth/login", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["user"]["role"] == "senior"


def test_dashboard_summary(client: TestClient):
    # Obtain token first
    login_res = client.post("/api/v1/auth/login", json={
        "username": "+919876543210",
        "password": "ValidPassword123!",
        "device_uuid": "test-device-uuid-1",
        "platform": "android"
    })
    token = login_res.json()["access_token"]
    senior_id = str(uuid.uuid4())

    response = client.get(
        f"/api/v1/healthcare/seniors/{senior_id}/dashboard-summary",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["greeting"] == "नमस्ते दादाजी"
    assert "Metformin" in data["next_medicine"]["name"]
    assert "blood_pressure" in data["recent_vitals"]


def test_emergency_sos(client: TestClient):
    login_res = client.post("/api/v1/auth/login", json={
        "username": "+919876543210",
        "password": "ValidPassword123!",
        "device_uuid": "test-device-uuid-1",
        "platform": "android"
    })
    token = login_res.json()["access_token"]

    payload = {
        "latitude": 26.9124,
        "longitude": 75.7873,
        "trigger_source": "in_app_button",
        "approximate_address": "Civil Lines, Jaipur",
        "battery_level_percent": 88
    }
    response = client.post(
        "/api/v1/emergency/sos",
        json=payload,
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "active"
    assert data["notified_contacts_count"] == 3


def test_assistant_chat(client: TestClient):
    login_res = client.post("/api/v1/auth/login", json={
        "username": "+919876543210",
        "password": "ValidPassword123!",
        "device_uuid": "test-device-uuid-1",
        "platform": "android"
    })
    token = login_res.json()["access_token"]

    payload = {"message": "मेरी दवाई कब है?", "language": "hi"}
    response = client.post(
        "/api/v1/assistant/chat",
        json=payload,
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "Metformin" in data["reply_text"]

