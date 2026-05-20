from pydantic import BaseModel
from typing import Optional, Dict, Any, List

class ConsultationStartRequest(BaseModel):
    patient_id: str
    text_input: Optional[str] = None

class ConsultationStatusResponse(BaseModel):
    workflow_id: str
    status: str
    progress_percent: Optional[int] = 0
    result: Optional[Dict[str, Any]] = None
    traces: Optional[Dict[str, Any]] = None
    agents_executed: Optional[List[str]] = None
    message: Optional[str] = None
