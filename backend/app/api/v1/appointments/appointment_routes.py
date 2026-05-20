from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import datetime

from app.database import get_db
from app.models.all_models import User, Patient, Doctor, Appointment, AuditLog
from app.schemas.all_schemas import AppointmentCreate
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user

router = APIRouter(prefix="/api/appointments", tags=["appointments"])

@router.post("")
async def create_appointment(
    apt_data: AppointmentCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Book a new consultation appointment."""
    if current_user.role != "Patient":
        return error_response(["Only patients can book appointments"], "Action forbidden", 403)
        
    # Check if doctor exists
    doc_res = await db.execute(select(Doctor).where(Doctor.id == apt_data.doctor_id))
    doctor = doc_res.scalars().first()
    if not doctor:
        return error_response(["Doctor not found"], "Booking failed", 404)

    new_apt = Appointment(
        patient_id=current_user.id,
        doctor_id=apt_data.doctor_id,
        datetime=apt_data.datetime,
        specialty=apt_data.specialty,
        type=apt_data.type,
        notes=apt_data.notes,
        status="scheduled"
    )
    db.add(new_apt)
    
    # Audit log
    audit = AuditLog(
        user_id=current_user.id,
        action="BOOK_APPOINTMENT",
        details=f"Patient {current_user.full_name} booked a {apt_data.specialty} appointment for {apt_data.datetime}."
    )
    db.add(audit)
    
    await db.commit()
    await db.refresh(new_apt)

    return success_response(
        {"appointment_id": new_apt.id, "status": new_apt.status},
        "Appointment booked successfully"
    )


@router.get("")
async def get_appointments(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve appointment history based on user roles."""
    if current_user.role == "Patient":
        stmt = select(Appointment).where(Appointment.patient_id == current_user.id)
    elif current_user.role == "Doctor":
        stmt = select(Appointment).where(Appointment.doctor_id == current_user.id)
    else:
        stmt = select(Appointment)
        
    res = await db.execute(stmt)
    apts = res.scalars().all()
    
    result_list = []
    for apt in apts:
        # Load related names
        pat_q = await db.execute(select(User).where(User.id == apt.patient_id))
        doc_q = await db.execute(select(User).where(User.id == apt.doctor_id))
        
        pat_user = pat_q.scalars().first()
        doc_user = doc_q.scalars().first()
        
        result_list.append({
            "id": apt.id,
            "patient_id": apt.patient_id,
            "patient_name": pat_user.full_name if pat_user else "Unknown Patient",
            "doctor_id": apt.doctor_id,
            "doctor_name": doc_user.full_name if doc_user else "Unknown Doctor",
            "datetime": apt.datetime.isoformat(),
            "specialty": apt.specialty,
            "status": apt.status,
            "type": apt.type,
            "notes": apt.notes
        })
        
    return success_response(result_list, "Appointments retrieved successfully")
