"""
Append-Only Timeline API Routes.
Enforces PANOR's core principle: no PUT, no DELETE — only GET and POST (append).
Every write generates an immutable audit trace.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import desc
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
from datetime import datetime
import uuid

from app.database import get_db
from app.models.timeline import TimelineEntry
from app.models.user import User
from app.security import get_current_active_user

router = APIRouter(prefix="/api/timeline", tags=["timeline"])


class TimelineAppendRequest(BaseModel):
    entry_type: str  # consultation, lab_result, prescription, emergency, intake, follow_up
    title: str
    content_json: Dict[str, Any]
    agent_source: Optional[str] = None
    confidence_score: Optional[str] = None
    risk_level: Optional[str] = None


class TimelineEntryResponse(BaseModel):
    id: int
    entry_type: str
    title: str
    content_json: Dict[str, Any]
    agent_source: Optional[str] = None
    trace_id: Optional[str] = None
    confidence_score: Optional[str] = None
    risk_level: Optional[str] = None
    created_at: datetime
    created_by: Optional[str] = None
    is_immutable: bool = True

    class Config:
        from_attributes = True


@router.get("/{patient_id}", response_model=List[TimelineEntryResponse])
async def get_patient_timeline(
    patient_id: int,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve the full append-only medical timeline for a patient.
    Returns entries in reverse chronological order (newest first).
    """
    result = await db.execute(
        select(TimelineEntry)
        .where(TimelineEntry.patient_id == patient_id)
        .order_by(desc(TimelineEntry.created_at))
    )
    entries = result.scalars().all()
    return entries


@router.post("/{patient_id}/append", response_model=TimelineEntryResponse)
async def append_to_timeline(
    patient_id: int,
    request: TimelineAppendRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Append a new entry to the patient's immutable medical timeline.
    NO PUT/DELETE operations exist — this is the ONLY write path.
    Each entry receives a unique Antigravity trace ID for audit.
    """
    # Generate unique trace ID
    trace_id = f"PANOR-{datetime.utcnow().strftime('%Y%m%d')}-{uuid.uuid4().hex[:8].upper()}"

    entry = TimelineEntry(
        patient_id=patient_id,
        entry_type=request.entry_type,
        title=request.title,
        content_json=request.content_json,
        agent_source=request.agent_source,
        trace_id=trace_id,
        confidence_score=request.confidence_score,
        risk_level=request.risk_level,
        created_by=current_user.email,
        is_immutable=True,
    )
    db.add(entry)
    await db.commit()
    await db.refresh(entry)
    return entry
