from fastapi import APIRouter, Depends, HTTPException
from app.database import get_db
from app.models.user import User
from app.models.medication import Medication
from app.models.timeline import TimelineEntry
from app.security import get_current_active_user
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import desc

router = APIRouter(prefix="/api/patient", tags=["patient"])

@router.get("/dashboard")
async def get_patient_dashboard(current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    if current_user.role != "Patient":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # Fetch active medications
    meds_result = await db.execute(
        select(Medication).where(
            Medication.patient_id == current_user.id,
            Medication.is_active == True
        )
    )
    medications = meds_result.scalars().all()
    
    # Fetch recent timeline entries (last 5)
    timeline_result = await db.execute(
        select(TimelineEntry)
        .where(TimelineEntry.patient_id == current_user.id)
        .order_by(desc(TimelineEntry.created_at))
        .limit(5)
    )
    timeline_entries = timeline_result.scalars().all()
    
    # Build enriched response
    profile = current_user.profile_data or {}
    
    return {
        "identity": {
            "p_id": current_user.p_id or "PAK-HEALTH-UNREGISTERED",
            "p_id_masked": _mask_pid(current_user.p_id) if current_user.p_id else "UNREGISTERED",
            "cnic_verified": bool(current_user.cnic_hash),
            "full_name": current_user.full_name,
        },
        "health_summary": {
            "blood_pressure": profile.get("vitals", {}).get("bp", "130/85"),
            "heart_rate": profile.get("vitals", {}).get("hr", "78 bpm"),
            "spo2": profile.get("vitals", {}).get("spo2", "97%"),
            "temperature": profile.get("vitals", {}).get("temp", "99.1 °F"),
            "blood_group": profile.get("blood_group", "A+"),
            "age": profile.get("age", 52),
            "gender": profile.get("gender", "Male"),
            "chronic_conditions": profile.get("chronic_conditions", []),
        },
        "medications": [
            {
                "drug_name": med.drug_name,
                "dosage": med.dosage,
                "frequency": med.frequency,
                "drug_class": med.drug_class,
                "purpose": med.purpose,
                "prescribed_by": med.prescribed_by,
            }
            for med in medications
        ],
        "timeline_preview": [
            {
                "id": entry.id,
                "entry_type": entry.entry_type,
                "title": entry.title,
                "risk_level": entry.risk_level,
                "trace_id": entry.trace_id,
                "created_at": entry.created_at.isoformat() if entry.created_at else None,
                "is_immutable": entry.is_immutable,
            }
            for entry in timeline_entries
        ],
        "emergency_alert": _check_emergency_alert(profile),
        "appointments": [
            {
                "doctor_name": "Dr. Fatima Hassan",
                "specialty": "Cardiologist",
                "datetime": "22 May 2026, 10:00 AM",
                "clinic": "PANOR Cardiac Centre, Lahore",
                "consultation_type": "Follow-Up",
                "image_url": "https://i.pravatar.cc/150?img=47"
            }
        ]
    }


def _mask_pid(p_id: str) -> str:
    """Mask P_ID for display: PAK-HEALTH-DEMO-0001 → PAK-HEALTH-****-0001"""
    if not p_id or len(p_id) < 8:
        return "****"
    parts = p_id.split("-")
    if len(parts) >= 4:
        parts[-2] = "****"
        return "-".join(parts)
    return p_id[:4] + "****" + p_id[-4:]


def _check_emergency_alert(profile: dict) -> dict:
    """Check if any conditions warrant an emergency alert display."""
    conditions = profile.get("chronic_conditions", [])
    # Demo scenario: T2DM patient with recent chest pain is always flagged
    if "Type 2 Diabetes Mellitus" in conditions or "Hypertension" in conditions:
        return {
            "active": True,
            "level": "YELLOW",
            "message": "Chronic condition monitoring active — report any chest discomfort immediately",
            "agent_source": "Agent_02_Clinical_Reasoning",
        }
    return {"active": False, "level": "GREEN", "message": None, "agent_source": None}
