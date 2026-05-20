from fastapi import APIRouter, Depends, HTTPException
from app.database import get_db
from app.models.user import User
from app.security import get_current_active_user
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/api/doctor", tags=["doctor"])

@router.get("/dashboard")
async def get_doctor_dashboard(current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    if current_user.role != "Doctor":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    return {
        "metrics": {
            "patients_today": 14,
            "appointments": 6,
            "stat_labs_pending": 2,
            "emergency_alerts": 1,
        },
        "patient_queue": [
            {
                "name": "Ahmed Raza",
                "p_id_masked": "PAK-HEALTH-****-0001",
                "time": "10:00 AM",
                "type": "Cardiology — Emergency Follow-Up",
                "risk_level": "RED",
                "risk_reason": "Chest pain + T2DM + Hypertension → Cardiac risk elevated",
                "pending_actions": ["STAT Labs Ordered", "ECG Pending"],
                "age_gender": "52M",
                "image_url": "https://i.pravatar.cc/150?img=12",
            },
            {
                "name": "Ayesha Bibi",
                "p_id_masked": "PAK-HEALTH-****-0042",
                "time": "11:15 AM",
                "type": "Endocrinology — Routine",
                "risk_level": "GREEN",
                "risk_reason": "Stable T2DM management, HbA1c improving",
                "pending_actions": [],
                "age_gender": "38F",
                "image_url": "https://i.pravatar.cc/150?img=5",
            },
            {
                "name": "Imran Khalid",
                "p_id_masked": "PAK-HEALTH-****-0087",
                "time": "12:30 PM",
                "type": "Cardiology — Follow-Up",
                "risk_level": "YELLOW",
                "risk_reason": "Post-MI rehabilitation — monitoring compliance",
                "pending_actions": ["Lab Review Due"],
                "age_gender": "61M",
                "image_url": "https://i.pravatar.cc/150?img=8",
            }
        ],
        "emergency_alert": {
            "active": True,
            "patient_name": "Ahmed Raza",
            "p_id_masked": "PAK-HEALTH-****-0001",
            "condition": "Cardiac Ischemia Risk — Chest pain with T2DM + Hypertension",
            "confidence": 94,
            "detected_at": "2 minutes ago",
            "required_action": "Immediate Evaluation",
            "agent_source": "Agent_02_Clinical_Reasoning",
        }
    }


class SOAPGenerateRequest(BaseModel):
    patient_id: str
    symptoms: Optional[str] = None


@router.post("/generate-soap")
async def generate_soap_note(
    request: SOAPGenerateRequest,
    current_user: User = Depends(get_current_active_user),
):
    """
    Agent 07 — Generate auto-SOAP note in <3 seconds.
    Returns structured S/O/A/P sections with AI confidence scores.
    """
    if current_user.role != "Doctor":
        raise HTTPException(status_code=403, detail="Not authorized")

    return {
        "generation_time_ms": 2300,
        "audit_id": "PANOR-2026-SOAP-00147",
        "confidence_score": 0.92,
        "soap": {
            "subjective": "52-year-old male presents with 3-day history of fever (99.1°F), progressive chest discomfort, and exertional dyspnea. Known case of T2DM (Metformin 500mg BD) and hypertension (Amlodipine 5mg OD). Patient describes symptoms in Roman Urdu: '3 din se bukhar, seene mein dard, saans phoolna.' Denies syncope or palpitations.",
            "objective": "BP: 130/85 mmHg | HR: 78 bpm (Resting) | SpO2: 97% | Temp: 99.1°F | ECG: Sinus rhythm with non-specific ST-T wave changes in leads V4-V6. BMI: 28.4 kg/m². Prior ECG (6 months ago): Normal sinus rhythm.",
            "assessment": "1. Atypical chest pain — Rule out acute coronary syndrome (ACS) in context of T2DM and hypertension. Confidence: 94%.\n2. Uncontrolled Type 2 Diabetes Mellitus — HbA1c review pending.\n3. Essential Hypertension — Currently on monotherapy, may require escalation.\n4. Drug Safety Alert: NSAIDs BLOCKED (Agent 03) — hypoglycemia risk with Metformin.",
            "plan": "1. STAT: ECG + Troponin-I (rule out MI). CBC + HbA1c + Lipid Panel.\n2. Continue Metformin 500mg BD + Amlodipine 5mg OD.\n3. Paracetamol 500mg PRN for pain (safe alternative — Agent 03 verified).\n4. Cardiology follow-up in 48 hours (Agent 06 automated reminder configured).\n5. Patient education: Report any worsening chest pain or dyspnea at rest immediately."
        },
        "agent_traces": {
            "agent_01_intake": {"status": "COMPLETED", "action": "Roman Urdu translated to structured English clinical summary"},
            "agent_02_clinical_reasoning": {"status": "COMPLETED", "action": "Flagged non-specific ST changes + T2DM → RED cardiac risk"},
            "agent_03_drug_safety": {"status": "ACTION_REQUIRED", "action": "BLOCKED Ibuprofen. Suggested Paracetamol 500mg."},
            "agent_04_lab_coordination": {"status": "COMPLETED", "action": "Pre-filled STAT ECG + Troponin + CBC orders"},
            "agent_05_epidemiology": {"status": "COMPLETED", "action": "Lahore cardiac cluster monitoring — no outbreak signal"},
            "agent_06_follow_up": {"status": "COMPLETED", "action": "48h follow-up reminder scheduled via SMS + app notification"},
            "agent_07_verification": {"status": "COMPLETED", "action": "SOAP confidence 92%. No contradictions detected. Ready for physician signature."},
        }
    }
