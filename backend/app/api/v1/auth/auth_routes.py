"""
PANOR — Auth Routes
Handles registration, login, OTP, PIN, refresh for all 4 roles.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import datetime, timedelta
import random
import string

from app.database import get_db
from app.models.all_models import User, Patient, Doctor, LabTechnician, Administrator, AuditLog
from app.schemas.all_schemas import UserCreate, UserResponse, Token, OTPVerify, PINVerify, PINSetup
from app.schemas.response_envelope import success_response, error_response
from app.security import (
    verify_password, get_password_hash, create_access_token,
    create_refresh_token, get_current_active_user
)

router = APIRouter(prefix="/api/auth", tags=["auth"])


def _generate_patient_id() -> str:
    """Generate a national P_ID in format PAK-HEALTH-YYYY-XXXX."""
    year = datetime.utcnow().year
    suffix = "".join(random.choices(string.digits, k=4))
    return f"PAK-HEALTH-{year}-{suffix}"


def _generate_employee_id() -> str:
    """Generate a lab employee ID."""
    suffix = "".join(random.choices(string.digits, k=4))
    return f"PANOR-LAB-{suffix}"


@router.post("/register", summary="Register a new user (any role)")
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    """
    Registers Patient | Doctor | LabTechnician | Administrator.
    Auto-creates the corresponding role-specific profile with defaults.
    """
    # ── Duplicate checks ──────────────────────────────────────────
    email_q = await db.execute(select(User).where(User.email == user_data.email))
    if email_q.scalars().first():
        return error_response(["Email already registered"], "Registration failed", 400)

    if user_data.phone:
        phone_q = await db.execute(select(User).where(User.phone == user_data.phone))
        if phone_q.scalars().first():
            return error_response(["Phone already registered"], "Registration failed", 400)

    # ── Create User ───────────────────────────────────────────────
    new_user = User(
        email=user_data.email,
        phone=user_data.phone,
        hashed_password=get_password_hash(user_data.password),
        full_name=user_data.full_name,
        role=user_data.role,
    )
    db.add(new_user)
    await db.flush()  # get id before sub-profile insert

    # ── Create Role Profile ───────────────────────────────────────
    if new_user.role == "Patient":
        pid = _generate_patient_id()
        db.add(Patient(id=new_user.id, patient_id=pid))

    elif new_user.role == "Doctor":
        db.add(Doctor(
            id=new_user.id,
            specialty="General Medicine",
            license_number=f"PMC-{random.randint(10000, 99999)}",
        ))

    elif new_user.role == "LabTechnician":
        db.add(LabTechnician(
            id=new_user.id,
            employee_id=_generate_employee_id(),
        ))

    elif new_user.role == "Administrator":
        db.add(Administrator(id=new_user.id))

    await db.commit()
    await db.refresh(new_user)

    return success_response({
        "id": new_user.id,
        "email": new_user.email,
        "full_name": new_user.full_name,
        "role": new_user.role,
        "is_active": new_user.is_active,
    }, "User registered successfully")


@router.post("/login", response_model=Token, summary="Email + password login")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db)
):
    """Standard OAuth2 password flow — used by Flutter AuthService."""
    result = await db.execute(select(User).where(User.email == form_data.username))
    user = result.scalars().first()

    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is disabled")

    access_token  = create_access_token(data={"sub": user.email, "role": user.role})
    refresh_token = create_refresh_token(data={"sub": user.email})

    user.refresh_token = refresh_token
    db.add(AuditLog(
        user_id=user.id, action="USER_LOGIN",
        resource_type="User", resource_id=user.id,
        details=f"Login via email/password. Role: {user.role}",
        severity="INFO",
    ))
    await db.commit()

    return {
        "access_token":  access_token,
        "refresh_token": refresh_token,
        "token_type":    "bearer",
        "role":          user.role,
    }


@router.get("/me", summary="Get current user profile")
async def get_me(current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    """Return logged-in user data + role-specific profile fields."""
    base = {
        "id":         current_user.id,
        "email":      current_user.email,
        "phone":      current_user.phone,
        "full_name":  current_user.full_name,
        "role":       current_user.role,
        "is_active":  current_user.is_active,
        "avatar_url": current_user.avatar_url,
    }

    if current_user.role == "Patient":
        p_q = await db.execute(select(Patient).where(Patient.id == current_user.id))
        p = p_q.scalars().first()
        if p:
            base.update({
                "patient_id":       p.patient_id,
                "blood_group":      p.blood_group,
                "gender":           p.gender,
                "date_of_birth":    str(p.date_of_birth) if p.date_of_birth else None,
                "address":          p.address,
                "city":             p.city,
                "cnic":             p.cnic,
                "emergency_contact":p.emergency_contact,
                "emergency_name":   p.emergency_name,
                "welfare_score":    p.welfare_score,
                "welfare_tier":     p.welfare_tier,
            })

    elif current_user.role == "Doctor":
        d_q = await db.execute(select(Doctor).where(Doctor.id == current_user.id))
        d = d_q.scalars().first()
        if d:
            base.update({
                "specialty":        d.specialty,
                "license_number":   d.license_number,
                "consultation_fee": d.consultation_fee,
                "hospital":         d.hospital,
                "city":             d.city,
                "rating":           d.rating,
            })

    elif current_user.role == "LabTechnician":
        l_q = await db.execute(select(LabTechnician).where(LabTechnician.id == current_user.id))
        l = l_q.scalars().first()
        if l:
            base.update({
                "employee_id":   l.employee_id,
                "facility_name": l.facility_name,
                "facility_city": l.facility_city,
                "shift":         l.shift,
                "is_verified":   l.is_verified,
            })

    elif current_user.role == "Administrator":
        a_q = await db.execute(select(Administrator).where(Administrator.id == current_user.id))
        a = a_q.scalars().first()
        if a:
            base.update({
                "department":   a.department,
                "access_level": a.access_level,
            })

    return success_response(base, "Profile retrieved successfully")


@router.post("/verify-otp", summary="Verify phone OTP")
async def verify_otp(payload: OTPVerify, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.phone == payload.phone))
    user = result.scalars().first()

    if not user:
        return error_response(["Phone number not found"], "Verification failed", 404)

    if user.otp_code != payload.otp:
        return error_response(["Invalid OTP"], "Verification failed", 401)

    if user.otp_expiry and user.otp_expiry < datetime.utcnow():
        return error_response(["OTP has expired"], "Verification failed", 401)

    user.otp_code = None
    user.otp_expiry = None
    access_token = create_access_token(data={"sub": user.email, "role": user.role})
    refresh_token = create_refresh_token(data={"sub": user.email})
    user.refresh_token = refresh_token
    await db.commit()

    return success_response({
        "access_token":  access_token,
        "refresh_token": refresh_token,
        "token_type":    "bearer",
        "role":          user.role,
    }, "OTP verified successfully")


@router.post("/verify-pin", summary="Verify PIN login")
async def verify_pin(payload: PINVerify, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == payload.email))
    user = result.scalars().first()

    if not user or not user.pin_hash or not verify_password(payload.pin, user.pin_hash):
        return error_response(["Invalid credentials"], "Verification failed", 401)

    access_token  = create_access_token(data={"sub": user.email, "role": user.role})
    refresh_token = create_refresh_token(data={"sub": user.email})
    user.refresh_token = refresh_token
    await db.commit()

    return success_response({
        "access_token":  access_token,
        "refresh_token": refresh_token,
        "token_type":    "bearer",
        "role":          user.role,
    }, "PIN verified successfully")


@router.post("/setup-pin", summary="Set a numeric PIN for quick login")
async def setup_pin(
    payload: PINSetup,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    current_user.pin_hash = get_password_hash(payload.pin)
    await db.commit()
    return success_response({}, "PIN configured successfully")


@router.post("/logout", summary="Invalidate refresh token")
async def logout(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    current_user.refresh_token = None
    db.add(AuditLog(
        user_id=current_user.id, action="USER_LOGOUT",
        resource_type="User", resource_id=current_user.id,
        severity="INFO",
    ))
    await db.commit()
    return success_response({}, "Logged out successfully")
