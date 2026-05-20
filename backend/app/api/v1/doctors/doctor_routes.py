from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database import get_db
from app.models.all_models import User, Doctor, Patient, Appointment, Prescription, LabReport
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user

router = APIRouter(prefix="/api/doctors", tags=["doctors"])


@router.get("/profile")
async def get_doctor_profile(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Return the authenticated doctor's full clinical profile."""
    if current_user.role != "Doctor":
        return error_response(["Only doctors can access this endpoint"], "Forbidden", 403)

    result = await db.execute(select(Doctor).where(Doctor.id == current_user.id))
    profile = result.scalars().first()

    return success_response({
        "id": current_user.id,
        "email": current_user.email,
        "full_name": current_user.full_name,
        "specialty": profile.specialty if profile else "General Medicine",
        "license_number": profile.license_number if profile else None,
        "consultation_fee": profile.consultation_fee if profile else 0.0,
        "availability": profile.availability if profile else {},
        "image_url": profile.image_url if profile else None,
    }, "Doctor profile retrieved successfully")


@router.get("/patients")
async def get_doctor_patients(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Return the full list of patients who have had appointments with this doctor."""
    if current_user.role != "Doctor":
        return error_response(["Only doctors can view their patient list"], "Forbidden", 403)

    # Get distinct patient IDs via appointments
    apt_result = await db.execute(
        select(Appointment.patient_id)
        .where(Appointment.doctor_id == current_user.id)
        .distinct()
    )
    patient_ids = [row[0] for row in apt_result.all()]

    data = []
    for pid in patient_ids:
        user_res = await db.execute(select(User).where(User.id == pid))
        pat_user = user_res.scalars().first()
        pat_res = await db.execute(select(Patient).where(Patient.id == pid))
        pat_profile = pat_res.scalars().first()
        if pat_user:
            data.append({
                "id": pat_user.id,
                "full_name": pat_user.full_name,
                "email": pat_user.email,
                "phone": pat_user.phone,
                "blood_group": pat_profile.blood_group if pat_profile else None,
                "gender": pat_profile.gender if pat_profile else None,
            })

    return success_response(data, "Patient list retrieved successfully")


@router.get("/patients/{patient_id}")
async def get_patient_detail(
    patient_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Full patient record for a doctor's consultation view."""
    if current_user.role != "Doctor":
        return error_response(["Only doctors can view patient records"], "Forbidden", 403)

    user_res = await db.execute(select(User).where(User.id == patient_id))
    pat_user = user_res.scalars().first()
    if not pat_user:
        return error_response(["Patient not found"], "Not found", 404)

    pat_res = await db.execute(select(Patient).where(Patient.id == patient_id))
    pat_profile = pat_res.scalars().first()

    # Latest prescription
    rx_res = await db.execute(
        select(Prescription)
        .where(Prescription.patient_id == patient_id)
        .order_by(Prescription.created_at.desc())
        .limit(3)
    )
    prescriptions = rx_res.scalars().all()

    # Latest labs
    lab_res = await db.execute(
        select(LabReport)
        .where(LabReport.patient_id == patient_id)
        .order_by(LabReport.created_at.desc())
        .limit(5)
    )
    labs = lab_res.scalars().all()

    return success_response({
        "id": pat_user.id,
        "full_name": pat_user.full_name,
        "email": pat_user.email,
        "phone": pat_user.phone,
        "blood_group": pat_profile.blood_group if pat_profile else None,
        "gender": pat_profile.gender if pat_profile else None,
        "address": pat_profile.address if pat_profile else None,
        "emergency_contact": pat_profile.emergency_contact if pat_profile else None,
        "recent_prescriptions": [
            {"id": r.id, "diagnosis": r.diagnosis, "medications": r.medications,
             "created_at": r.created_at.isoformat()} for r in prescriptions
        ],
        "recent_labs": [
            {"id": l.id, "test_name": l.test_name, "status": l.status,
             "priority": l.priority, "created_at": l.created_at.isoformat()} for l in labs
        ],
    }, "Patient detail retrieved successfully")


@router.get("/list")
async def list_all_doctors(
    db: AsyncSession = Depends(get_db)
):
    """Public endpoint – list all active doctors (used by patient appointment booking)."""
    result = await db.execute(select(User).where(User.role == "Doctor").where(User.is_active == True))
    doctor_users = result.scalars().all()

    data = []
    for u in doctor_users:
        doc_res = await db.execute(select(Doctor).where(Doctor.id == u.id))
        doc = doc_res.scalars().first()
        data.append({
            "id": u.id,
            "full_name": u.full_name,
            "email": u.email,
            "specialty": doc.specialty if doc else "General Medicine",
            "consultation_fee": doc.consultation_fee if doc else 0.0,
            "image_url": doc.image_url if doc else "https://i.pravatar.cc/150?img=33",
        })

    return success_response(data, "Doctor list retrieved successfully")
