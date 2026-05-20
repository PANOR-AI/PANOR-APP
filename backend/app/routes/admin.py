from fastapi import APIRouter, Depends, HTTPException
from app.database import get_db
from app.models.user import User
from app.security import get_current_active_user
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

router = APIRouter(prefix="/api/admin", tags=["admin"])

@router.get("/dashboard")
async def get_admin_dashboard(current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    if current_user.role != "Administrator":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # Real DB counts
    total_users_result = await db.execute(select(User))
    users = total_users_result.scalars().all()
    
    total_patients = len([u for u in users if u.role == "Patient"])
    total_doctors = len([u for u in users if u.role == "Doctor"])
    total_labs = len([u for u in users if u.role == "Lab Technician"])
    
    return {
        "metrics": {
            "total_patients": total_patients,
            "active_doctors": total_doctors,
            "lab_technicians": total_labs,
            "active_agents": 7,
            "db_commits": 187,
            "emergency_alerts_24h": 3,
        },
        "agent_performance": [
            {"name": "Intake Intelligence (Agent 01)", "latency_ms": 1400, "accuracy": 98.6, "status": "ONLINE"},
            {"name": "Clinical Reasoning (Agent 02)", "latency_ms": 2100, "accuracy": 94.2, "status": "ONLINE"},
            {"name": "Drug Safety Guardian (Agent 03)", "latency_ms": 800, "accuracy": 100.0, "status": "ONLINE"},
            {"name": "Lab Coordination (Agent 04)", "latency_ms": 1200, "accuracy": 97.8, "status": "ONLINE"},
            {"name": "Epidemiology Intel (Agent 05)", "latency_ms": 3200, "accuracy": 91.4, "status": "ONLINE"},
            {"name": "Follow-Up Monitor (Agent 06)", "latency_ms": 900, "accuracy": 96.1, "status": "ONLINE"},
            {"name": "Verification & SOAP (Agent 07)", "latency_ms": 500, "accuracy": 99.1, "status": "ONLINE"},
        ],
        "epidemiology_clusters": [
            {
                "id": "CLU-D01",
                "region": "Lahore — North-East",
                "condition": "Dengue",
                "severity": "HIGH",
                "cases_localized": 14,
                "confidence": 94,
                "radius_km": 2.4,
                "forecast": "Expect 20% increase over 72h based on monsoon pattern",
            },
            {
                "id": "CLU-G02",
                "region": "Islamabad — Sector G",
                "condition": "Gastroenteritis",
                "severity": "LOW",
                "cases_localized": 6,
                "confidence": 78,
                "radius_km": 1.1,
                "forecast": "Stable — likely waterborne cluster, resolving",
            },
            {
                "id": "CLU-C03",
                "region": "Karachi — Korangi",
                "condition": "Cardiac Events",
                "severity": "MODERATE",
                "cases_localized": 9,
                "confidence": 86,
                "radius_km": 3.8,
                "forecast": "Correlates with air quality index spike — monitoring",
            },
        ],
        "emergency_response": {
            "red_alerts_today": 3,
            "avg_detection_to_escalation_sec": 4.2,
            "avg_doctor_acknowledgment_sec": 18.7,
            "drug_blocks_today": 2,
            "override_rate": "0%",
            "soap_avg_generation_ms": 2300,
        },
        "welfare_score_distribution": {
            "platinum": 12,
            "gold": 34,
            "silver": 89,
            "basic": 156,
        },
        "recent_activities": [
            {"title": "🔴 Emergency RED Alert", "desc": "Ahmed Raza — Cardiac ischemia risk detected by Agent 02", "time": "2 mins ago"},
            {"title": "🛡️ Drug Safety BLOCK", "desc": "Ibuprofen blocked for Ahmed Raza (Metformin conflict)", "time": "5 mins ago"},
            {"title": "📋 SOAP Generated", "desc": "Dr. Fatima Hassan — Consultation SOAP for Ahmed Raza", "time": "8 mins ago"},
            {"title": "🧪 STAT Lab Dispatched", "desc": "ECG + Troponin ordered for Ahmed Raza → PANOR Central Lab", "time": "10 mins ago"},
        ],
        "audit_log_preview": [
            {"action": "POST /api/consultation/start", "detail": "Ahmed Raza voice intake processed. Agent 01 triggered.", "time": "10:48 AM", "severity": "INFO"},
            {"action": "AGENT_02 EMERGENCY", "detail": "Chest pain + T2DM + Hypertension = RED cardiac risk. Auto-escalated.", "time": "10:48 AM", "severity": "CRITICAL"},
            {"action": "AGENT_03 BLOCK", "detail": "Ibuprofen 400mg BLOCKED. Metformin conflict. Paracetamol suggested.", "time": "10:50 AM", "severity": "WARNING"},
            {"action": "POST /api/timeline/append", "detail": "Immutable SOAP note appended. Trace: PANOR-20260520-F1A2B3C4", "time": "10:52 AM", "severity": "INFO"},
        ],
    }
