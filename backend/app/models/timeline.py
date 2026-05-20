"""
Append-Only Medical Timeline Model.
Core PANOR principle: Medical history is NEVER overwritten — only appended.
Each entry is cryptographically traceable via Antigravity trace IDs.
"""
from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, JSON, ForeignKey
from datetime import datetime
from app.database import Base


class TimelineEntry(Base):
    __tablename__ = "timeline_entries"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    entry_type = Column(String, nullable=False)  # consultation, lab_result, prescription, emergency, intake, follow_up
    title = Column(String, nullable=False)
    content_json = Column(JSON, nullable=False)  # Structured clinical content
    agent_source = Column(String, nullable=True)  # Which AI agent generated/verified this entry
    trace_id = Column(String, nullable=True, unique=True)  # Antigravity trace ID for audit
    confidence_score = Column(String, nullable=True)  # Agent confidence (0.0 - 1.0)
    risk_level = Column(String, nullable=True)  # RED, ORANGE, YELLOW, GREEN
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    created_by = Column(String, nullable=True)  # doctor email or system
    is_immutable = Column(Boolean, default=True)  # Always True — append-only guarantee
