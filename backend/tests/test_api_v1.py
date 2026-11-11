import random
import uuid
from fastapi.testclient import TestClient


def test_senior_registration(client: TestClient):
    unique_phone = f"+91987{random.randint(1000000, 9999999)}"
    payload = {
        "phone_number": unique_phone,
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
    assert data["success"] is True
    assert data["data"]["role"] == "senior"


def test_auth_login(client: TestClient):
    unique_phone = f"+91986{random.randint(1000000, 9999999)}"
    client.post("/api/v1/auth/register", json={
        "fullName": "Login Test Senior",
        "phoneNumber": unique_phone,
        "password": "ValidPassword123!",
        "role": "senior"
    })

    payload = {
        "emailOrPhone": unique_phone,
        "password": "ValidPassword123!"
    }
    response = client.post("/api/v1/auth/login", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "access_token" in data["data"]
    assert data["data"]["user"]["role"] == "senior"


def test_dashboard_summary(client: TestClient):
    unique_phone = f"+91985{random.randint(1000000, 9999999)}"
    client.post("/api/v1/auth/register", json={
        "fullName": "Dashboard Senior",
        "phoneNumber": unique_phone,
        "password": "ValidPassword123!",
        "role": "senior"
    })
    login_res = client.post("/api/v1/auth/login", json={
        "emailOrPhone": unique_phone,
        "password": "ValidPassword123!"
    })
    assert login_res.status_code == 200
    token = login_res.json()["data"]["access_token"]
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
    unique_phone = f"+91984{random.randint(1000000, 9999999)}"
    client.post("/api/v1/auth/register", json={
        "fullName": "SOS Senior",
        "phoneNumber": unique_phone,
        "password": "ValidPassword123!",
        "role": "senior"
    })
    login_res = client.post("/api/v1/auth/login", json={
        "emailOrPhone": unique_phone,
        "password": "ValidPassword123!"
    })
    assert login_res.status_code == 200
    token = login_res.json()["data"]["access_token"]

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
    unique_phone = f"+91983{random.randint(1000000, 9999999)}"
    client.post("/api/v1/auth/register", json={
        "fullName": "Assistant Senior",
        "phoneNumber": unique_phone,
        "password": "ValidPassword123!",
        "role": "senior"
    })
    login_res = client.post("/api/v1/auth/login", json={
        "emailOrPhone": unique_phone,
        "password": "ValidPassword123!"
    })
    assert login_res.status_code == 200
    token = login_res.json()["data"]["access_token"]

    payload = {"message": "मेरी दवाई कब है?", "language": "hi"}
    response = client.post(
        "/api/v1/assistant/chat",
        json=payload,
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "response_text" in data
    assert data["detected_intent"] == "medicine_schedule_query"
