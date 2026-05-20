from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import datetime

from app.database import get_db
from app.models.all_models import User, Patient, Vitals, LabReport, Prescription, AuditLog
from app.schemas.all_schemas import VitalsCreate, LabReportCreate
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user

router = APIRouter(prefix="/api/health-records", tags=["health_records"])

@router.post("/vitals")
async def log_vitals(
    vitals_data: VitalsCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Append patient vitals directly to the longitudinal health timeline."""
    if current_user.role != "Patient":
        return error_response(["Only patients can submit their vitals"], "Action forbidden", 403)

    new_vitals = Vitals(
        patient_id=current_user.id,
        blood_pressure=vitals_data.blood_pressure,
        heart_rate=vitals_data.heart_rate,
        temperature=vitals_data.temperature,
        oxygen_level=vitals_data.oxygen_level
    )
    db.add(new_vitals)
    
    # Audit log entry
    audit = AuditLog(
        user_id=current_user.id,
        action="LOG_VITALS",
        details=f"Patient logged vitals: BP={vitals_data.blood_pressure}, HR={vitals_data.heart_rate}."
    )
    db.add(audit)
    
    await db.commit()
    await db.refresh(new_vitals)

    return success_response(
        {
            "id": new_vitals.id,
            "blood_pressure": new_vitals.blood_pressure,
            "heart_rate": new_vitals.heart_rate,
            "recorded_at": new_vitals.recorded_at.isoformat()
        },
        "Vitals recorded successfully in patient timeline"
    )


@router.get("/vitals")
async def get_vitals_history(
    patient_id: str = None,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve vitals history timeline."""
    target_id = patient_id
    
    if current_user.role == "Patient":
        target_id = current_user.id
    elif not target_id:
        return error_response(["patient_id query parameter is required for clinicians"], "Query error", 400)

    stmt = select(Vitals).where(Vitals.patient_id == target_id).order_by(Vitals.recorded_at.desc())
    res = await db.execute(stmt)
    vitals_list = res.scalars().all()

    result = []
    for v in vitals_list:
        result.append({
            "id": v.id,
            "blood_pressure": v.blood_pressure,
            "heart_rate": v.heart_rate,
            "temperature": v.temperature,
            "oxygen_level": v.oxygen_level,
            "recorded_at": v.recorded_at.isoformat()
        })
        
    return success_response(result, "Vitals history retrieved successfully")


@router.post("/lab-reports")
async def create_lab_report(
    lab_data: LabReportCreate,
    patient_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Creates a new laboratory report (priorities: STAT, ROUTINE)."""
    # Verify access
    if current_user.role not in ("Doctor", "LabTechnician", "Administrator"):
        return error_response(["Not authorized to issue lab reports"], "Action forbidden", 403)

    new_report = LabReport(
        patient_id=patient_id,
        doctor_id=current_user.id if current_user.role == "Doctor" else None,
        test_name=lab_data.test_name,
        results=lab_data.results,
        priority=lab_data.priority,
        status="Completed" if lab_data.results else "Pending"
    )
    db.add(new_report)
    
    # Audit log
    audit = AuditLog(
        user_id=current_user.id,
        action="CREATE_LAB_REPORT",
        details=f"Issued lab test '{lab_data.test_name}' with priority '{lab_data.priority}' for patient '{patient_id}'."
    )
    db.add(audit)
    
    await db.commit()
    await db.refresh(new_report)

    return success_response(
        {
            "id": new_report.id,
            "test_name": new_report.test_name,
            "priority": new_report.priority,
            "status": new_report.status
        },
        "Lab report registered successfully"
    )
