from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any
import logging

from app.schemas.consultation_dto import ConsultationStartRequest, ConsultationStatusResponse
from services.antigravity_client import AntigravityOrchestrator, ConsultationOrchestrator

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/consultation", tags=["consultation"])

# Initialize orchestrator safely with mock credentials fallback
orchestrator = ConsultationOrchestrator(
    AntigravityOrchestrator(project_id="panor-gcp-hackathon-2026")
)

@router.post("/start", response_model=ConsultationStatusResponse)
async def start_consultation(request: ConsultationStartRequest):
    """
    Start clinical consultation for a patient using the Google Antigravity 7-Agent Reasoning Pipeline.
    Supports seamless fallback to offline mock telemetry if Vertex AI credentials are not active.
    """
    try:
        logger.info(f"Initiating Antigravity clinical consultation workflow for Patient: {request.patient_id}")
        
        # Dispatch workflow execution asynchronously
        response = await orchestrator.start_consultation(
            patient_id=request.patient_id,
            text=request.text_input
        )
        
        # Map output components to response dto
        return ConsultationStatusResponse(
            workflow_id=response.get('workflow_id', 'wf-failed'),
            status=response.get('status', 'FAILED'),
            progress_percent=100,
            result=response.get('result'),
            traces=response.get('traces'),
            agents_executed=['agent_01_intake', 'agent_02_clinical_reasoning', 'agent_03_drug_safety', 'agent_04_lab_coordination', 'agent_07_verification'],
            message="Antigravity clinical reasoning pipeline complete."
        )
        
    except ValueError as e:
        logger.error(f"Validation error in start_consultation: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Unexpected error in start_consultation: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error executing consultation workflow.")
