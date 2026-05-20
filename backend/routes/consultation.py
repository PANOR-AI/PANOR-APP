"""
Consultation API Routes
RESTful endpoints for starting and monitoring consultations
"""

from fastapi import APIRouter, UploadFile, Form, HTTPException, BackgroundTasks
from typing import Optional
import logging

from services.antigravity_client import ConsultationOrchestrator
from schemas.consultation_dto import ConsultationStartRequest, ConsultationStatusResponse

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/consultation", tags=["consultation"])


@router.post("/start")
async def start_consultation(
    patient_id: str = Form(...),
    voice_input: Optional[UploadFile] = None,
    pdf_input: Optional[UploadFile] = None,
    text_input: Optional[str] = None,
    image_input: Optional[UploadFile] = None,
    video_input: Optional[UploadFile] = None
):
    """
    Start a new PANOR consultation.
    
    Accepts multimodal input:
    - voice_input: Audio file (voice, any language)
    - pdf_input: Medical report PDF
    - text_input: Typed symptoms (any language)
    - image_input: Photo of prescription/skin condition
    - video_input: Video recording
    
    Returns:
        {
            'workflow_id': str,
            'patient_id': str,
            'status': 'EXECUTING',
            'poll_url': str
        }
    """
    
    try:
        orchestrator = ConsultationOrchestrator(
            antigravity_client=get_antigravity_client()
        )
        
        result = await orchestrator.start_consultation(
            patient_id=patient_id,
            voice=voice_input,
            text=text_input,
            pdf=pdf_input,
            image=image_input,
            video=video_input
        )
        
        return {
            'workflow_id': result['workflow_id'],
            'patient_id': patient_id,
            'status': result['status'],
            'poll_url': f"/api/consultation/{result['workflow_id']}/status",
            'message': 'Consultation started. Use poll_url to check progress.'
        }
    
    except Exception as e:
        logger.error(f"Failed to start consultation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{workflow_id}/status")
async def get_consultation_status(workflow_id: str):
    """
    Check consultation execution progress and retrieve results.
    
    Returns:
        {
            'workflow_id': str,
            'status': 'EXECUTING' | 'COMPLETED' | 'FAILED',
            'progress_percent': int (0-100),
            'result': {...},  # Only if COMPLETED
            'traces': {...}   # Only if COMPLETED (for judge inspection)
        }
    """
    
    try:
        client = get_antigravity_client()
        
        status = await client._get_workflow_status(workflow_id)
        
        if status['state'] == 'COMPLETED':
            traces = await client._get_workflow_traces(workflow_id)
            
            return {
                'workflow_id': workflow_id,
                'status': 'COMPLETED',
                'result': status['output'],
                'traces': traces,
                'agents_executed': list(traces.get('agents', {}).keys()),
                'message': 'Consultation complete. Full traces available for judge inspection.'
            }
        
        elif status['state'] == 'FAILED':
            return {
                'workflow_id': workflow_id,
                'status': 'FAILED',
                'error': 'Workflow execution failed',
                'message': 'Consultation could not be completed.'
            }
        
        else:
            return {
                'workflow_id': workflow_id,
                'status': 'EXECUTING',
                'progress_percent': status.get('progress_percent', 0),
                'message': 'Consultation in progress...'
            }
    
    except Exception as e:
        logger.error(f"Failed to get consultation status: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{workflow_id}/traces")
async def get_consultation_traces(workflow_id: str):
    """
    Retrieve full Antigravity execution traces for judge inspection.
    
    Shows:
    - Workplan for each agent
    - Task plan for each agent
    - Tool calls and parameters
    - Reasoning chains
    - Agent outputs
    - Timestamps
    - Error logs
    
    Returns:
        {
            'workplan_id': str,
            'agents': {
                'agent_01_intake': {...},
                'agent_02_clinical_reasoning': {...},
                ...
                'agent_07_verification': {...}
            }
        }
    """
    
    try:
        client = get_antigravity_client()
        traces = await client._get_workflow_traces(workflow_id)
        
        return {
            'workflow_id': workflow_id,
            'traces': traces,
            'message': 'Full execution traces. Each agent shows workplan, task plan, tool calls, reasoning, and output.'
        }
    
    except Exception as e:
        logger.error(f"Failed to get traces: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


def get_antigravity_client():
    """Factory function to get Antigravity client."""
    from services.antigravity_client import AntigravityOrchestrator
    
    return AntigravityOrchestrator(
        project_id="panor-hackathon-2026",
        region="us-central1"
    )
