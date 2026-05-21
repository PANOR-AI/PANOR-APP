"""
PANOR — Lab API Routes
Covers the full Lab Technician workflow:
  - Pending test requests (STAT / URGENT / ROUTINE)
  - Result submission + auto-escalation
  - Completed tests history
  - Lab dashboard stats
  - Doctor: order lab tests for a patient
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import datetime, timedelta
from typing import Optional

from app.database import get_db
from app.models.all_models import (
    User, Patient, Doctor, LabTechnician, LabReport,
    Notification, AuditLog, AnalyticsEvent
)
from app.schemas.all_schemas import LabReportCreate, LabResultSubmit
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user

router = APIRouter(prefix="/api/lab", tags=["lab"])


# ─────────────────────────────────────────────────────────────────────────────
# LAB TECHNICIAN — Dashboard Stats
# ─────────────────────────────────────────────────────────────────────────────
@router.get("/dashboard", summary="Lab technician dashboard stats")
async def get_lab_dashboard(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role != "LabTechnician":
        return error_response(["Only lab technicians can access this endpoint"], "Forbidden", 403)

    # Pending stats by priority
    pending_q = await db.execute(
        select(LabReport).where(LabReport.status == "Pending")
    )
    pending = pending_q.scalars().all()

    stat_count    = len([r for r in pending if r.priority == "STAT"])
    urgent_count  = len([r for r in pending if r.priority == "URGENT"])
    routine_count = len([r for r in pending if r.priority == "ROUTINE"])

    # Today's completed
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end   = today_start + timedelta(days=1)
    completed_today_q = await db.execute(
        select(LabReport).where(
            LabReport.status == "Completed",
            LabReport.completed_at >= today_start,
            LabReport.completed_at < today_end,
        )
    )
    completed_today = len(completed_today_q.scalars().all())

    # Flagged critical today
    critical_q = await db.execute(
        select(LabReport).where(
            LabReport.is_critical == True,
            LabReport.completed_at >= today_start,
        )
    )
    critical_today = len(critical_q.scalars().all())

    # Lab profile
    lab_q = await db.execute(
        select(LabTechnician).where(LabTechnician.id == current_user.id)
    )
    lab_profile = lab_q.scalars().first()

    return success_response({
        "stat_pending":    stat_count,
        "urgent_pending":  urgent_count,
        "routine_pending": routine_count,
        "total_pending":   len(pending),
        "completed_today": completed_today,
        "critical_today":  critical_today,
        "profile": {
            "full_name":     current_user.full_name,
            "employee_id":   lab_profile.employee_id if lab_profile else None,
            "facility_name": lab_profile.facility_name if lab_profile else "PANOR Central Lab",
            "shift":         lab_profile.shift if lab_profile else "Morning",
            "is_verified":   lab_profile.is_verified if lab_profile else False,
        }
    }, "Lab dashboard data retrieved")


# ─────────────────────────────────────────────────────────────────────────────
# LAB TECHNICIAN — Pending Tests
# ─────────────────────────────────────────────────────────────────────────────
@router.get("/pending", summary="Get all pending lab test requests")
async def get_pending_tests(
    priority: Optional[str] = None,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role not in ("LabTechnician", "Doctor", "Administrator"):
        return error_response(["Insufficient permissions"], "Forbidden", 403)

    query = select(LabReport).where(LabReport.status.in_(["Pending", "In Progress"]))
    if priority:
        query = query.where(LabReport.priority == priority.upper())

    # Sort: STAT first, then URGENT, then ROUTINE; oldest first
    result = await db.execute(query.order_by(LabReport.ordered_at.asc()))
    reports = result.scalars().all()

    data = []
    for r in reports:
        # Patient name
        p_q = await db.execute(select(User).where(User.id == r.patient_id))
        p_user = p_q.scalars().first()
        # Patient P_ID
        pat_q = await db.execute(select(Patient).where(Patient.id == r.patient_id))
        patient = pat_q.scalars().first()
        # Doctor name
        d_user = None
        if r.doctor_id:
            d_q = await db.execute(select(User).where(User.id == r.doctor_id))
            d_user = d_q.scalars().first()

        data.append({
            "id":              r.id,
            "test_name":       r.test_name,
            "priority":        r.priority,
            "status":          r.status,
            "patient_name":    p_user.full_name if p_user else "Unknown",
            "patient_pid":     patient.patient_id if patient else "N/A",
            "doctor_name":     d_user.full_name if d_user else "N/A",
            "clinical_intent": r.clinical_intent,
            "deadline":        r.deadline,
            "ordered_at":      r.ordered_at.strftime("%d %b %Y, %I:%M %p"),
        })

    # Sort by priority weight
    priority_order = {"STAT": 0, "URGENT": 1, "ROUTINE": 2}
    data.sort(key=lambda x: priority_order.get(x["priority"], 99))

    return success_response(data, "Pending tests retrieved")


# ─────────────────────────────────────────────────────────────────────────────
# LAB TECHNICIAN — Submit Results
# ─────────────────────────────────────────────────────────────────────────────
@router.post("/{report_id}/submit-results", summary="Submit lab test results")
async def submit_results(
    report_id: str,
    payload: LabResultSubmit,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role != "LabTechnician":
        return error_response(["Only lab technicians can submit results"], "Forbidden", 403)

    r_q = await db.execute(select(LabReport).where(LabReport.id == report_id))
    report = r_q.scalars().first()
    if not report:
        raise HTTPException(status_code=404, detail="Lab report not found")

    # Update the report
    report.results        = payload.results
    report.result_summary = payload.result_summary
    report.is_flagged     = payload.is_flagged
    report.is_critical    = payload.is_critical
    report.report_url     = payload.report_url
    report.status         = "Completed"
    report.completed_at   = datetime.utcnow()
    report.technician_id  = current_user.id

    # Notify the ordering doctor
    if report.doctor_id:
        flag_text = " 🚨 CRITICAL VALUES DETECTED!" if payload.is_critical else (
            " ⚠️ Abnormal values flagged." if payload.is_flagged else ""
        )
        db.add(Notification(
            user_id=report.doctor_id,
            title=f"Lab Result Ready: {report.test_name}",
            message=f"Results for {report.test_name} are ready.{flag_text} "
                    f"Summary: {payload.result_summary or 'See report.'}",
            notification_type="emergency" if payload.is_critical else
                               "warning" if payload.is_flagged else "lab",
        ))

    # Notify the patient
    db.add(Notification(
        user_id=report.patient_id,
        title=f"Your lab results are ready: {report.test_name}",
        message=f"Your {report.test_name} results have been uploaded to your health record.",
        notification_type="lab",
    ))

    db.add(AuditLog(
        user_id=current_user.id,
        action="LAB_RESULT_SUBMITTED",
        resource_type="LabReport",
        resource_id=report.id,
        details=f"Results submitted for {report.test_name}. "
                f"Flagged={payload.is_flagged}, Critical={payload.is_critical}",
        severity="CRITICAL" if payload.is_critical else "INFO",
    ))

    await db.commit()
    return success_response({"report_id": report.id, "status": "Completed"}, "Results submitted successfully")


# ─────────────────────────────────────────────────────────────────────────────
# LAB TECHNICIAN — Completed History
# ─────────────────────────────────────────────────────────────────────────────
@router.get("/completed", summary="Get completed lab tests history")
async def get_completed_tests(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role not in ("LabTechnician", "Doctor", "Administrator"):
        return error_response(["Insufficient permissions"], "Forbidden", 403)

    result = await db.execute(
        select(LabReport)
        .where(LabReport.status == "Completed")
        .order_by(LabReport.completed_at.desc())
        .limit(50)
    )
    reports = result.scalars().all()

    data = []
    for r in reports:
        p_q = await db.execute(select(User).where(User.id == r.patient_id))
        p_user = p_q.scalars().first()

        data.append({
            "id":             r.id,
            "test_name":      r.test_name,
            "priority":       r.priority,
            "status":         r.status,
            "patient_name":   p_user.full_name if p_user else "Unknown",
            "result_summary": r.result_summary,
            "is_flagged":     r.is_flagged,
            "is_critical":    r.is_critical,
            "completed_at":   r.completed_at.strftime("%d %b %Y") if r.completed_at else None,
            "report_url":     r.report_url,
        })

    return success_response(data, "Completed tests retrieved")


# ─────────────────────────────────────────────────────────────────────────────
# DOCTOR — Order a Lab Test for a Patient
# ─────────────────────────────────────────────────────────────────────────────
@router.post("/order", summary="Doctor orders a lab test for a patient")
async def order_lab_test(
    payload: LabReportCreate,
    patient_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role != "Doctor":
        return error_response(["Only doctors can order lab tests"], "Forbidden", 403)

    # Verify patient exists
    p_q = await db.execute(select(Patient).where(Patient.id == patient_id))
    if not p_q.scalars().first():
        raise HTTPException(status_code=404, detail="Patient not found")

    # Calculate deadline based on priority
    deadline_map = {"STAT": "30 min", "URGENT": "2 hours", "ROUTINE": "24 hours"}
    deadline = deadline_map.get(payload.priority.upper(), "24 hours")

    report = LabReport(
        patient_id=patient_id,
        doctor_id=current_user.id,
        test_name=payload.test_name,
        priority=payload.priority.upper(),
        clinical_intent=payload.clinical_intent,
        deadline=deadline,
        status="Pending",
    )
    db.add(report)

    # Notify patient
    db.add(Notification(
        user_id=patient_id,
        title=f"Lab Test Ordered: {payload.test_name}",
        message=f"Your doctor has ordered a {payload.priority} priority {payload.test_name} test. "
                f"Expected completion: {deadline}.",
        notification_type="lab",
    ))

    db.add(AuditLog(
        user_id=current_user.id,
        action="LAB_TEST_ORDERED",
        resource_type="LabReport",
        details=f"Ordered {payload.test_name} [{payload.priority}] for patient {patient_id}.",
        severity="INFO",
    ))

    await db.commit()
    return success_response({"report_id": report.id, "deadline": deadline}, "Lab test ordered successfully")


# ─────────────────────────────────────────────────────────────────────────────
# PATIENT — View my lab reports
# ─────────────────────────────────────────────────────────────────────────────
@router.get("/my-reports", summary="Patient views their own lab reports")
async def get_my_lab_reports(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role != "Patient":
        return error_response(["Only patients can view their own reports"], "Forbidden", 403)

    result = await db.execute(
        select(LabReport)
        .where(LabReport.patient_id == current_user.id)
        .order_by(LabReport.ordered_at.desc())
    )
    reports = result.scalars().all()

    data = [{
        "id":             r.id,
        "test_name":      r.test_name,
        "priority":       r.priority,
        "status":         r.status,
        "result_summary": r.result_summary,
        "is_flagged":     r.is_flagged,
        "is_critical":    r.is_critical,
        "ordered_at":     r.ordered_at.strftime("%d %b %Y, %I:%M %p"),
        "completed_at":   r.completed_at.strftime("%d %b %Y") if r.completed_at else None,
        "report_url":     r.report_url,
    } for r in reports]

    return success_response(data, "Lab reports retrieved")


# ─────────────────────────────────────────────────────────────────────────────
# SINGLE REPORT DETAIL
# ─────────────────────────────────────────────────────────────────────────────
@router.get("/{report_id}", summary="Get full details of a single lab report")
async def get_lab_report_detail(
    report_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    r_q = await db.execute(select(LabReport).where(LabReport.id == report_id))
    report = r_q.scalars().first()

    if not report:
        raise HTTPException(status_code=404, detail="Lab report not found")

    # Access control: patient can only see their own, doctor/lab/admin see all
    if current_user.role == "Patient" and report.patient_id != current_user.id:
        return error_response(["Access denied"], "Forbidden", 403)

    p_q = await db.execute(select(User).where(User.id == report.patient_id))
    p_user = p_q.scalars().first()
    pat_q = await db.execute(select(Patient).where(Patient.id == report.patient_id))
    patient = pat_q.scalars().first()

    d_user = None
    if report.doctor_id:
        d_q = await db.execute(select(User).where(User.id == report.doctor_id))
        d_user = d_q.scalars().first()

    return success_response({
        "id":              report.id,
        "test_name":       report.test_name,
        "priority":        report.priority,
        "status":          report.status,
        "clinical_intent": report.clinical_intent,
        "patient_name":    p_user.full_name if p_user else "N/A",
        "patient_pid":     patient.patient_id if patient else "N/A",
        "doctor_name":     d_user.full_name if d_user else "N/A",
        "results":         report.results,
        "result_summary":  report.result_summary,
        "is_flagged":      report.is_flagged,
        "is_critical":     report.is_critical,
        "deadline":        report.deadline,
        "ordered_at":      report.ordered_at.strftime("%d %b %Y, %I:%M %p"),
        "completed_at":    report.completed_at.strftime("%d %b %Y, %I:%M %p") if report.completed_at else None,
        "report_url":      report.report_url,
    }, "Lab report detail retrieved")
