import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_registration_flow():
    """Tests successful patient user registration."""
    import random
    rand_id = random.randint(10000, 99999)
    email = f"test_patient_{rand_id}@panor.com"
    phone = f"+92300{rand_id:06d}"
    payload = {
        "email": email,
        "password": "securepassword123",
        "full_name": "Test Patient",
        "role": "Patient",
        "phone": phone
    }
    # Register patient
    response = client.post("/api/auth/register", json=payload)
    assert response.status_code == 200
    json_data = response.json()
    assert json_data["success"] is True
    assert json_data["data"]["email"] == email

def test_login_oauth2_multipart():
    """Tests Multipart form standard OAuth2 login."""
    # Login with seeded user credentials
    form_data = {
        "username": "patient@panor.com",
        "password": "password"
    }
    response = client.post("/api/auth/login", data=form_data)
    assert response.status_code == 200
    json_data = response.json()
    assert "access_token" in json_data
    assert json_data["token_type"] == "bearer"

def test_me_endpoint_requires_auth():
    """Verifies profile querying blocks unauthenticated clients."""
    response = client.get("/api/auth/me")
    assert response.status_code == 401
