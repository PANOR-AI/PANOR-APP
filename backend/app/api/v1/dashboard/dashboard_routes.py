from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func
from datetime import datetime, timedelta

from app.database import get_db
from app.models.all_models import (
    User, Patient, Doctor, Appointment, Vitals, AuditLog,
    Medication, LabReport, Notification, AnalyticsEvent
)
from app.security import get_current_active_user

router = APIRouter(prefix="/api", tags=["dashboard"])

@router.get("/patient/dashboard")
async def get_patient_dashboard(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Aggregate dashboard payload for Patient portal."""
    if current_user.role != "Patient":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    # 1. Fetch latest vitals from Vitals table
    vitals_q = await db.execute(
        select(Vitals)
        .where(Vitals.patient_id == current_user.id)
        .order_by(Vitals.recorded_at.desc())
        .limit(1)
    )
    latest_vitals = vitals_q.scalars().first()
    
    blood_pressure = "120/80 mmHg"
    heart_rate = "72 bpm"
    temperature = "98.6 °F"
    oxygen_level = "98%"

    if latest_vitals:
        blood_pressure = latest_vitals.blood_pressure or blood_pressure
        heart_rate = latest_vitals.heart_rate or heart_rate
        if latest_vitals.temperature:
            temperature = f"{latest_vitals.temperature} °F"
        if latest_vitals.oxygen_level:
            oxygen_level = f"{latest_vitals.oxygen_level}%"
    elif current_user.profile_data and isinstance(current_user.profile_data, dict):
        # Fallback to user.profile_data["vitals"] if Vitals table is empty
        profile_vitals = current_user.profile_data.get("vitals")
        if profile_vitals and isinstance(profile_vitals, dict):
            blood_pressure = profile_vitals.get("bp", blood_pressure)
            heart_rate = profile_vitals.get("hr", heart_rate)
            temperature = profile_vitals.get("temp", temperature)
            oxygen_level = profile_vitals.get("spo2", oxygen_level)

    health_summary = {
        "blood_pressure": blood_pressure,
        "heart_rate": heart_rate,
        "temperature": temperature,
        "oxygen_level": oxygen_level
    }

    # 2. Fetch upcoming appointments
    apt_q = await db.execute(
        select(Appointment)
        .where(Appointment.patient_id == current_user.id)
        .where(Appointment.status == "scheduled")
        .order_by(Appointment.datetime.asc())
    )
    db_apts = apt_q.scalars().all()
    
    upcoming_appointments = []
    for apt in db_apts:
        # Load doctor user info
        doc_user_q = await db.execute(select(User).where(User.id == apt.doctor_id))
        doc_user = doc_user_q.scalars().first()
        doc_name = doc_user.full_name if doc_user else "Doctor"
        
        # Load doctor profile image
        doc_prof_q = await db.execute(select(Doctor).where(Doctor.id == apt.doctor_id))
        doc_prof = doc_prof_q.scalars().first()
        image_url = doc_prof.image_url if doc_prof and doc_prof.image_url else "https://i.pravatar.cc/150?img=33"
        
        upcoming_appointments.append({
            "id": apt.id,
            "doctor_name": doc_name,
            "specialty": apt.specialty,
            "datetime": apt.datetime.strftime("%d %b %Y, %I:%M %p"),
            "status": apt.status,
            "type": apt.type,
            "image_url": image_url
        })

    # 3. Fetch active medications
    med_q = await db.execute(
        select(Medication)
        .where(Medication.patient_id == current_user.id)
        .where(Medication.is_active == True)
        .order_by(Medication.name.asc())
    )
    db_meds = med_q.scalars().all()
    active_medications = [{
        "id": med.id,
        "name": med.name,
        "dosage": med.dosage,
        "frequency": med.frequency,
        "start_date": med.start_date.strftime("%Y-%m-%d") if med.start_date else None,
        "end_date": med.end_date.strftime("%Y-%m-%d") if med.end_date else None
    } for med in db_meds]

    # 4. Fetch recent lab reports
    lab_q = await db.execute(
        select(LabReport)
        .where(LabReport.patient_id == current_user.id)
        .order_by(LabReport.created_at.desc())
        .limit(5)
    )
    db_labs = lab_q.scalars().all()
    recent_lab_reports = [{
        "id": lab.id,
        "test_name": lab.test_name,
        "status": lab.status,
        "priority": lab.priority,
        "created_at": lab.created_at.strftime("%d %b %Y, %I:%M %p")
    } for lab in db_labs]

    # 5. Fetch unread notification count
    notif_q = await db.execute(
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .where(Notification.is_read == False)
    )
    notifications_count = len(notif_q.scalars().all())

    # Return standard envelope matching contract
    return {
        "success": True,
        "message": "Dashboard data retrieved",
        "data": {
            "health_summary": health_summary,
            "upcoming_appointments": upcoming_appointments,
            "active_medications": active_medications,
            "recent_lab_reports": recent_lab_reports,
            "notifications_count": notifications_count
        }
    }


@router.get("/doctor/dashboard")
async def get_doctor_dashboard(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Aggregate dashboard payload for Doctor portal."""
    if current_user.role != "Doctor":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)

    # 1. Count today's patients (unique patient IDs having appointments today)
    today_pat_q = await db.execute(
        select(Appointment.patient_id)
        .where(Appointment.doctor_id == current_user.id)
        .where(Appointment.datetime >= today_start)
        .where(Appointment.datetime < today_end)
        .distinct()
    )
    today_patients = len(today_pat_q.scalars().all())

    # 2. Count today's appointments
    today_apt_q = await db.execute(
        select(Appointment)
        .where(Appointment.doctor_id == current_user.id)
        .where(Appointment.datetime >= today_start)
        .where(Appointment.datetime < today_end)
    )
    today_appointments = len(today_apt_q.scalars().all())

    # 3. Count pending consultations (status is scheduled)
    pending_q = await db.execute(
        select(Appointment)
        .where(Appointment.doctor_id == current_user.id)
        .where(Appointment.status == "scheduled")
    )
    pending_consultations = len(pending_q.scalars().all())

    # 4. Fetch recent patients (distinct patient IDs ordered by latest appointment date)
    recent_pats_q = await db.execute(
        select(Appointment.patient_id)
        .where(Appointment.doctor_id == current_user.id)
        .order_by(Appointment.datetime.desc())
        .distinct()
    )
    recent_pat_ids = recent_pats_q.scalars().all()[:5]
    
    recent_patients = []
    for pid in recent_pat_ids:
        u_q = await db.execute(select(User).where(User.id == pid))
        u = u_q.scalars().first()
        if u:
            p_q = await db.execute(select(Patient).where(Patient.id == pid))
            p = p_q.scalars().first()
            recent_patients.append({
                "id": pid,
                "full_name": u.full_name,
                "email": u.email,
                "phone": u.phone,
                "gender": p.gender if p else "N/A",
                "blood_group": p.blood_group if p else "N/A"
            })

    # 5. Fetch doctor schedule for today
    sched_q = await db.execute(
        select(Appointment)
        .where(Appointment.doctor_id == current_user.id)
        .where(Appointment.datetime >= today_start)
        .where(Appointment.datetime < today_end)
        .order_by(Appointment.datetime.asc())
    )
    sched_apts = sched_q.scalars().all()
    
    schedule = []
    for apt in sched_apts:
        pat_u_q = await db.execute(select(User).where(User.id == apt.patient_id))
        pat_u = pat_u_q.scalars().first()
        schedule.append({
            "id": apt.id,
            "patient_name": pat_u.full_name if pat_u else "Patient",
            "time": apt.datetime.strftime("%I:%M %p"),
            "type": apt.type,
            "status": apt.status,
            "notes": apt.notes
        })

    # 6. Aggregate doctor analytics
    # Weekly consultations
    weekly_consultations = []
    for i in range(6, -1, -1):
        day_date = today_start.date() - timedelta(days=i)
        day_start = datetime.combine(day_date, datetime.min.time())
        day_end = datetime.combine(day_date, datetime.max.time())
        
        day_apt_q = await db.execute(
            select(Appointment)
            .where(Appointment.doctor_id == current_user.id)
            .where(Appointment.datetime >= day_start)
            .where(Appointment.datetime <= day_end)
        )
        count = len(day_apt_q.scalars().all())
        weekly_consultations.append({
            "day": day_date.strftime("%a"),
            "count": count
        })

    # Top conditions based on previous appointments/prescriptions diagnosis
    from collections import Counter
    from app.models.all_models import Prescription
    pres_q = await db.execute(
        select(Prescription.diagnosis)
        .where(Prescription.doctor_id == current_user.id)
    )
    diagnoses = pres_q.scalars().all()
    diag_counts = Counter([d for d in diagnoses if d])
    
    top_conditions = [
        {"condition": k, "count": v}
        for k, v in diag_counts.most_common(5)
    ]

    analytics = {
        "weekly_consultations": weekly_consultations,
        "top_conditions": top_conditions
    }

    return {
        "success": True,
        "message": "Dashboard data retrieved",
        "data": {
            "today_patients": today_patients,
            "today_appointments": today_appointments,
            "pending_consultations": pending_consultations,
            "recent_patients": recent_patients,
            "schedule": schedule,
            "analytics": analytics
        }
    }


@router.get("/admin/dashboard")
async def get_admin_dashboard(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Aggregate dashboard payload for Admin portal."""
    if current_user.role != "Administrator":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    # 1. Total users, patients, doctors, administrators
    users_q = await db.execute(select(User).where(User.is_deleted == False))
    all_users = users_q.scalars().all()
    total_users = len(all_users)
    patients = len([u for u in all_users if u.role == "Patient"])
    doctors = len([u for u in all_users if u.role == "Doctor"])
    administrators = len([u for u in all_users if u.role == "Administrator"])

    # 2. Active sessions: count non-null refresh tokens
    active_sessions = len([u for u in all_users if u.refresh_token is not None])
    if active_sessions == 0:
        active_sessions = len([u for u in all_users if u.is_active])

    # 3. Appointments today
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)
    apt_today_q = await db.execute(
        select(Appointment)
        .where(Appointment.datetime >= today_start)
        .where(Appointment.datetime < today_end)
    )
    appointments_today = len(apt_today_q.scalars().all())

    # 4. Recent AnalyticsEvents as system activity
    ae_q = await db.execute(
        select(AnalyticsEvent)
        .order_by(AnalyticsEvent.created_at.desc())
        .limit(10)
    )
    events = ae_q.scalars().all()
    system_activity = [{
        "id": e.id,
        "event_type": e.event_type,
        "payload": e.payload,
        "created_at": e.created_at.strftime("%d %b %Y, %I:%M %p")
    } for e in events]

    # 5. Recent AuditLogs as audit summary
    al_q = await db.execute(
        select(AuditLog)
        .order_by(AuditLog.created_at.desc())
        .limit(10)
    )
    logs = al_q.scalars().all()
    audit_summary = []
    for log in logs:
        user_q = await db.execute(select(User).where(User.id == log.user_id))
        user_obj = user_q.scalars().first()
        audit_summary.append({
            "id": log.id,
            "user_name": user_obj.full_name if user_obj else "System",
            "action": log.action,
            "details": log.details,
            "created_at": log.created_at.strftime("%d %b %Y, %I:%M %p")
        })

    return {
        "success": True,
        "message": "Dashboard data retrieved",
        "data": {
            "total_users": total_users,
            "patients": patients,
            "doctors": doctors,
            "administrators": administrators,
            "active_sessions": active_sessions,
            "appointments_today": appointments_today,
            "system_activity": system_activity,
            "audit_summary": audit_summary
        }
    }
