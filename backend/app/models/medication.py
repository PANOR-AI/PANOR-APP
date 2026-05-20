"""
Active Medication Model.
Supports Agent 03 (Drug Safety Guardian) cross-prescriber interaction checks.
Tracks all current and historical prescriptions per patient.
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from datetime import datetime
from app.database import Base


class Medication(Base):
    __tablename__ = "medications"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    drug_name = Column(String, nullable=False)
    dosage = Column(String, nullable=False)  # e.g., "500mg"
    frequency = Column(String, nullable=False)  # e.g., "Twice daily"
    drug_class = Column(String, nullable=True)  # e.g., "Biguanide", "NSAID", "Antiplatelet"
    purpose = Column(String, nullable=True)  # e.g., "Blood sugar control"
    prescribed_by = Column(String, nullable=True)  # Doctor name
    is_active = Column(Boolean, default=True)
    started_at = Column(DateTime, default=datetime.utcnow)
    ended_at = Column(DateTime, nullable=True)
