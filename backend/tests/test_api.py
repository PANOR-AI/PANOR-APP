import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def get_auth_headers(email: str = "patient@panor.com") -> dict:
    form_data = {"username": email, "password": "password"}
    resp = client.post("/api/auth/login", data=form_data)
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

def test_vitals_logging_envelope():
    """Asserts that vital logging endpoint returns the standardized API response envelope."""
    headers = get_auth_headers("patient@panor.com")
    payload = {
        "blood_pressure": "118/79",
        "heart_rate": "68 bpm",
        "temperature": 98.4,
        "oxygen_level": 99
    }
    response = client.post("/api/health-records/vitals", json=payload, headers=headers)
    assert response.status_code == 200
    
    envelope = response.json()
    assert envelope["success"] is True
    assert envelope["message"] == "Vitals recorded successfully in patient timeline"
    assert envelope["data"]["blood_pressure"] == "118/79"
    assert envelope["errors"] == []

def test_ai_chat_assistant_flow(monkeypatch):
    """Validates patient conversational co-pilot history persistence."""
    # Mock AI chat response to prevent real external Gemini API call
    from unittest.mock import AsyncMock
    from app.services.ai.gemini import GeminiAIService
    monkeypatch.setattr(GeminiAIService, "chat", AsyncMock(return_value="This is a mocked assistant response."))

    headers = get_auth_headers("patient@panor.com")
    payload = {
        "message": "Hello, I am having light fever today.",
        "session_id": "test-chat-session-001"
    }
    response = client.post("/api/ai-assistant/chat", json=payload, headers=headers)
    assert response.status_code == 200
    
    envelope = response.json()
    assert envelope["success"] is True
    assert "response" in envelope["data"]
    assert envelope["data"]["response"] == "This is a mocked assistant response."
    assert len(envelope["data"]["history"]) > 0
