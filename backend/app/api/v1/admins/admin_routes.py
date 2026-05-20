from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database import get_db
from app.models.all_models import User, Patient, Doctor, AuditLog, AnalyticsEvent
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user

router = APIRouter(prefix="/api/admin", tags=["admin"])


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
