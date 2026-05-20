import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def get_auth_headers(email: str = "patient@panor.com") -> dict:
    """Helper to retrieve JWT headers for test execution."""
    form_data = {"username": email, "password": "password"}
    resp = client.post("/api/auth/login", data=form_data)
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

def test_patient_dashboard_payload():
    """Asserts patient dashboard returns vital cards and appointments list."""
    headers = get_auth_headers("patient@panor.com")
    response = client.get("/api/patient/dashboard", headers=headers)
    assert response.status_code == 200
    
    data = response.json()
    assert "health_summary" in data
    assert "blood_pressure" in data["health_summary"]
    assert "heart_rate" in data["health_summary"]
    assert "appointments" in data
    assert isinstance(data["appointments"], list)

def test_doctor_dashboard_payload():
    """Asserts doctor dashboard returns correct count metrics and patients queue."""
    headers = get_auth_headers("doctor@panor.com")
    response = client.get("/api/doctor/dashboard", headers=headers)
    assert response.status_code == 200
    
    data = response.json()
    assert "metrics" in data
    assert "patients_today" in data["metrics"]
    assert "appointments" in data
    assert isinstance(data["appointments"], list)

def test_admin_dashboard_payload():
    """Asserts admin dashboard returns total patient base and platform activities."""
    headers = get_auth_headers("admin@panor.com")
    response = client.get("/api/admin/dashboard", headers=headers)
    assert response.status_code == 200
    
    data = response.json()
    assert "metrics" in data
    assert "total_patients" in data["metrics"]
    assert "active_doctors" in data["metrics"]
    assert "recent_activities" in data
    assert isinstance(data["recent_activities"], list)
