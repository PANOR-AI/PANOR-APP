from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database import get_db
from app.models.all_models import User, Patient, Doctor, AuditLog, AnalyticsEvent, EpidemiologyEvent
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user

router = APIRouter(prefix="/api/admin", tags=["admin"])


# ----------------- Existing Routes -----------------



@router.get("/users")
async def list_all_users(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Admin: List all users with role filters."""
    if current_user.role != "Administrator":
        return error_response(["Only administrators can view all users"], "Forbidden", 403)

    result = await db.execute(select(User).where(User.is_deleted == False))
    users = result.scalars().all()

    data = [{
        "id": u.id,
        "full_name": u.full_name,
        "email": u.email,
        "phone": u.phone,
        "role": u.role,
        "is_active": u.is_active,
        "created_at": u.created_at.isoformat(),
    } for u in users]

    return success_response(data, "All users retrieved successfully")


@router.patch("/users/{user_id}/deactivate")
async def deactivate_user(
    user_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Admin: Soft-deactivate a user account."""
    if current_user.role != "Administrator":
        return error_response(["Only administrators can deactivate users"], "Forbidden", 403)

    result = await db.execute(select(User).where(User.id == user_id))
    target = result.scalars().first()
    if not target:
        return error_response(["User not found"], "Not found", 404)

    target.is_active = False
    db.add(AuditLog(
        user_id=current_user.id,
        action="DEACTIVATE_USER",
        details=f"Admin deactivated user {target.email} (ID: {user_id})"
    ))
    await db.commit()

    return success_response({"user_id": user_id, "is_active": False}, "User deactivated successfully")


@router.get("/doctors")
async def list_doctors(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Admin: Full doctor list with profile details."""
    if current_user.role != "Administrator":
        return error_response(["Only administrators can view doctor management"], "Forbidden", 403)

    result = await db.execute(select(User).where(User.role == "Doctor"))
    doctor_users = result.scalars().all()

    data = []
    for u in doctor_users:
        doc_res = await db.execute(select(Doctor).where(Doctor.id == u.id))
        doc = doc_res.scalars().first()
        data.append({
            "id": u.id,
            "full_name": u.full_name,
            "email": u.email,
            "specialty": doc.specialty if doc else "N/A",
            "license_number": doc.license_number if doc else "N/A",
            "consultation_fee": doc.consultation_fee if doc else 0.0,
            "is_active": u.is_active,
        })

    return success_response(data, "Doctor list retrieved successfully")


@router.get("/patients")
async def list_patients(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Admin: Full patient list."""
    if current_user.role != "Administrator":
        return error_response(["Only administrators can view patient management"], "Forbidden", 403)

    result = await db.execute(select(User).where(User.role == "Patient").where(User.is_deleted == False))
    users = result.scalars().all()

    data = []
    for u in users:
        pat_res = await db.execute(select(Patient).where(Patient.id == u.id))
        pat = pat_res.scalars().first()
        data.append({
            "id": u.id,
            "full_name": u.full_name,
            "email": u.email,
            "phone": u.phone,
            "blood_group": pat.blood_group if pat else None,
            "gender": pat.gender if pat else None,
            "is_active": u.is_active,
        })

    return success_response(data, "Patient list retrieved successfully")


@router.get("/audit-logs")
async def get_audit_logs(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Admin: Retrieve the 50 most recent audit log entries."""
    if current_user.role != "Administrator":
        return error_response(["Only administrators can view audit logs"], "Forbidden", 403)

    result = await db.execute(
        select(AuditLog).order_by(AuditLog.created_at.desc()).limit(50)
    )
    logs = result.scalars().all()

    data = [{
        "id": l.id,
        "user_id": l.user_id,
        "action": l.action,
        "details": l.details,
        "created_at": l.created_at.isoformat(),
    } for l in logs]

    return success_response(data, "Audit logs retrieved successfully")


@router.get("/analytics")
async def get_analytics(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Admin: Platform-wide analytics summary."""
    if current_user.role != "Administrator":
        return error_response(["Only administrators can view analytics"], "Forbidden", 403)

    all_users = (await db.execute(select(User))).scalars().all()
    total_patients = len([u for u in all_users if u.role == "Patient"])
    total_doctors = len([u for u in all_users if u.role == "Doctor"])
    total_admins = len([u for u in all_users if u.role == "Administrator"])

    return success_response({
        "total_users": len(all_users),
        "total_patients": total_patients,
        "total_doctors": total_doctors,
        "total_admins": total_admins,
        "platform": "PANOR Agentic Clinical Intelligence Platform",
        "version": "1.0.0",
    }, "Analytics retrieved successfully")


@router.get("/epidemiology")
async def get_epidemiology_data(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Admin: Retrieve epidemiology outbreak trends and case events."""
    if current_user.role != "Administrator":
        return error_response(["Only administrators can view epidemiology data"], "Forbidden", 403)

    result = await db.execute(
        select(EpidemiologyEvent).order_by(EpidemiologyEvent.reported_at.desc())
    )
    events = result.scalars().all()

    data = []
    for event in events:
        data.append({
            "id": event.id,
            "disease_name": event.disease_name,
            "location": event.location,
            "latitude": event.latitude,
            "longitude": event.longitude,
            "cases": event.cases,
            "deaths": event.deaths,
            "reported_at": event.reported_at.isoformat(),
            "status": event.status
        })

    if not data:
        demo_events = [
            {"disease_name": "Influenza A", "location": "Sector 4, New Delhi", "latitude": 28.5355, "longitude": 77.2410, "cases": 45, "deaths": 0, "status": "Active"},
            {"disease_name": "Dengue Fever", "location": "Vasant Kunj, New Delhi", "latitude": 28.5244, "longitude": 77.1389, "cases": 12, "deaths": 1, "status": "Active"},
            {"disease_name": "Covid-19 (JN.1)", "location": "Dwarka, New Delhi", "latitude": 28.5921, "longitude": 77.0460, "cases": 28, "deaths": 0, "status": "Controlled"},
            {"disease_name": "Malaria", "location": "Noida, Sector 62", "latitude": 28.6273, "longitude": 77.3727, "cases": 8, "deaths": 0, "status": "Active"},
            {"disease_name": "Tuberculosis", "location": "Old Delhi", "latitude": 28.6562, "longitude": 77.2309, "cases": 15, "deaths": 2, "status": "Active"}
        ]
        
        for de in demo_events:
            new_event = EpidemiologyEvent(
                disease_name=de["disease_name"],
                location=de["location"],
                latitude=de["latitude"],
                longitude=de["longitude"],
                cases=de["cases"],
                deaths=de["deaths"],
                status=de["status"]
            )
            db.add(new_event)
        await db.commit()
        
        result = await db.execute(
            select(EpidemiologyEvent).order_by(EpidemiologyEvent.reported_at.desc())
        )
        events = result.scalars().all()
        data = [{
            "id": event.id,
            "disease_name": event.disease_name,
            "location": event.location,
            "latitude": event.latitude,
            "longitude": event.longitude,
            "cases": event.cases,
            "deaths": event.deaths,
            "reported_at": event.reported_at.isoformat(),
            "status": event.status
        } for event in events]

    return success_response(data, "Epidemiology data retrieved successfully")

