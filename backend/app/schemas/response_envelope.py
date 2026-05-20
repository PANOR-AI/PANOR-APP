from pydantic import BaseModel, Field
from typing import Any, List, Optional, Dict

class ResponseEnvelope(BaseModel):
    success: bool = True
    message: str = "Action completed successfully"
    data: Optional[Any] = None
    errors: List[str] = Field(default_factory=list)
    meta: Dict[str, Any] = Field(default_factory=dict)

def success_response(data: Any = None, message: str = "Action completed successfully", meta: Dict[str, Any] = None) -> dict:
    """Helper to construct success responses."""
    return {
        "success": True,
        "message": message,
        "data": data,
        "errors": [],
        "meta": meta or {}
    }

def error_response(errors: List[str], message: str = "An error occurred", status_code: int = 400) -> dict:
    """Helper to construct error responses."""
    return {
        "success": False,
        "message": message,
        "data": None,
        "errors": errors,
        "meta": {}
    }
