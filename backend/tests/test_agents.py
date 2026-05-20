import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock
from app.services.ai.antigravity_client import AntigravityOrchestrator

@pytest.mark.asyncio
async def test_antigravity_orchestrator_sequential_flow():
    """
    Verifies that the stateful 7-agent orchestrator executes sequentially
    and propagates state correctly. We mock the AI calls to isolate orchestration logic.
    """
    # Create Mock Database Session
    mock_db = MagicMock()
    mock_db.commit = AsyncMock()
    mock_db.refresh = AsyncMock()
    mock_db.add = MagicMock()
    
    orchestrator = AntigravityOrchestrator(mock_db)
    
    # Mock AI Service agent calls
    orchestrator.ai = AsyncMock()
    
    # Define Mock returns for each agent matching their respective schemas
    orchestrator.ai.run_agent.side_effect = [
        # 1. Intake Agent
        {
            "agent": "Intake Agent",
            "input": {},
            "output": {"symptoms": ["chest pain", "fever"], "severity": "HIGH", "duration": "2 days", "urgency_score": 9, "reasoning": ["cardiac concern"]},
            "execution_time": 100
        },
        # 2. Clinical Reasoning Agent
        {
            "agent": "Clinical Reasoning Agent",
            "input": {},
            "output": {"differential_diagnosis": ["Acute Coronary Syndrome"], "primary_hypothesis": "Acute Coronary Syndrome", "confidence": 0.95, "reasoning": ["classic pain"]},
            "execution_time": 120
        },
        # 3. Drug Safety Guardian
        {
            "agent": "Drug Safety Guardian",
            "input": {},
            "output": {"is_safe": True, "contraindications": [], "warnings": [], "reasoning": ["no contraindications"]},
            "execution_time": 90
        },
        # 4. Lab Coordination Agent
        {
            "agent": "Laboratory Coordination Agent",
            "input": {},
            "output": {"recommended_tests": ["ECG", "Troponin"], "priority": "STAT", "reasoning": ["chest pain STAT"]},
            "execution_time": 80
        },
        # 5. Epidemiology Agent
        {
            "agent": "Epidemiology Agent",
            "input": {},
            "output": {"outbreak_risk": "LOW", "cluster_detected": False, "reasoning": ["no cluster"]},
            "execution_time": 75
        },
        # 6. Follow-up Agent
        {
            "agent": "Follow-Up Agent",
            "input": {},
            "output": {"follow_up_timeframe": "24 hours", "monitoring_flags": ["worsening shortness of breath"], "reasoning": ["rapid evaluation"]},
            "execution_time": 70
        },
        # 7. Verification Agent
        {
            "agent": "Verification Agent",
            "input": {},
            "output": {
                "hallucination_detected": False,
                "final_soap_note": {
                    "subjective": "Chest pain for 2 days.",
                    "objective": "High severity.",
                    "assessment": "ACS",
                    "plan": "Urgent ECG"
                },
                "confidence": 0.98,
                "reasoning": ["verified"]
            },
            "execution_time": 150
        }
    ]
    
    # Run Orchestrator
    result = await orchestrator.execute_consultation_workflow(
        input_text="Severe chest pain and high fever",
        patient_id="patient-123",
        doctor_id="doctor-456"
    )
    
    # Assertions
    assert "conversation_id" in result
    assert result["final_state"]["diagnosis"] == "Acute Coronary Syndrome"
    assert "ECG" in result["final_state"]["recommended_labs"]
    assert len(result["traces"]) == 7
    assert result["traces"][0]["agent"] == "Intake Agent"
    assert result["traces"][6]["agent"] == "Verification Agent"
    assert mock_db.commit.called
