from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database import get_db
from app.models.all_models import User, Patient, Prescription, LabReport, Vitals, Medication
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user

router = APIRouter(prefix="/api/patients", tags=["patients"])


@router.get("/profile")
async def get_my_profile(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Returns the current patient's full profile including clinical data."""
    if current_user.role != "Patient":
        return error_response(["Only patients can access this endpoint"], "Forbidden", 403)

    result = await db.execute(select(Patient).where(Patient.id == current_user.id))
    profile = result.scalars().first()

    return success_response({
        "id": current_user.id,
        "email": current_user.email,
        "phone": current_user.phone,
        "full_name": current_user.full_name,
        "blood_group": profile.blood_group if profile else None,
        "date_of_birth": str(profile.date_of_birth) if profile and profile.date_of_birth else None,
        "gender": profile.gender if profile else None,
        "address": profile.address if profile else None,
        "emergency_contact": profile.emergency_contact if profile else None,
    }, "Profile retrieved successfully")


@router.get("/prescriptions")
async def get_my_prescriptions(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve the patient's full prescription history."""
    if current_user.role != "Patient":
        return error_response(["Only patients can view prescriptions"], "Forbidden", 403)

    result = await db.execute(
        select(Prescription)
        .where(Prescription.patient_id == current_user.id)
        .order_by(Prescription.created_at.desc())
    )
    prescriptions = result.scalars().all()

    data = []
    for p in prescriptions:
        doc_res = await db.execute(select(User).where(User.id == p.doctor_id))
        doc = doc_res.scalars().first()
        data.append({
            "id": p.id,
            "doctor_name": doc.full_name if doc else "Unknown",
            "diagnosis": p.diagnosis,
            "medications": p.medications,
            "created_at": p.created_at.isoformat(),
        })

    return success_response(data, "Prescriptions retrieved successfully")


@router.get("/lab-reports")
async def get_my_lab_reports(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve lab report history for the patient."""
    if current_user.role != "Patient":
        return error_response(["Only patients can view lab reports"], "Forbidden", 403)

    result = await db.execute(
        select(LabReport)
        .where(LabReport.patient_id == current_user.id)
        .order_by(LabReport.created_at.desc())
    )
    labs = result.scalars().all()

    data = [{
        "id": r.id,
        "test_name": r.test_name,
        "status": r.status,
        "priority": r.priority,
        "results": r.results,
        "created_at": r.created_at.isoformat(),
    } for r in labs]

    return success_response(data, "Lab reports retrieved successfully")


@router.get("/medications")
async def get_my_medications(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve active and historical medication schedules."""
    if current_user.role != "Patient":
        return error_response(["Only patients can view medications"], "Forbidden", 403)

    result = await db.execute(
        select(Medication)
        .where(Medication.patient_id == current_user.id)
        .where(Medication.is_active == True)
    )
    meds = result.scalars().all()

    data = [{
        "id": m.id,
        "name": m.name,
        "dosage": m.dosage,
        "frequency": m.frequency,
        "start_date": str(m.start_date),
        "end_date": str(m.end_date),
        "is_active": m.is_active,
    } for m in meds]

    return success_response(data, "Medications retrieved successfully")
