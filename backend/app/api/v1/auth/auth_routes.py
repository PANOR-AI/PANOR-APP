from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import datetime, timedelta
import random
import secrets
import string

from app.database import get_db
from app.models.all_models import User, Patient, Doctor
from app.schemas.all_schemas import UserCreate, UserResponse, Token
from app.schemas.response_envelope import success_response, error_response
from app.security import (
    verify_password, get_password_hash, create_access_token,
    create_refresh_token, get_current_active_user, get_current_user
)

router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/register")
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    """Registers a new user (Patient, Doctor, Administrator, LabTechnician)."""
    # Check duplicate email
    result = await db.execute(select(User).where(User.email == user_data.email))
    if result.scalars().first():
        return error_response(["Email already registered"], "Registration failed", 400)
    
    # Check duplicate phone if provided
    if user_data.phone:
        phone_res = await db.execute(select(User).where(User.phone == user_data.phone))
        if phone_res.scalars().first():
            return error_response(["Phone number already registered"], "Registration failed", 400)

    hashed_pwd = get_password_hash(user_data.password)
    new_user = User(
        email=user_data.email,
        phone=user_data.phone,
        hashed_password=hashed_pwd,
        full_name=user_data.full_name,
        role=user_data.role
    )
    db.add(new_user)
    await db.flush()  # Generate user id

    # Seed core profiles based on roles
    if new_user.role == "Patient":
        patient_profile = Patient(id=new_user.id)
        db.add(patient_profile)
    elif new_user.role == "Doctor":
        doctor_profile = Doctor(
            id=new_user.id,
            specialty="General Medicine",
            license_number=f"LIC-{random.randint(10000, 99999)}"
        )
        db.add(doctor_profile)

    await db.commit()
    await db.refresh(new_user)

    user_resp = {
        "id": new_user.id,
        "email": new_user.email,
        "phone": new_user.phone,
        "full_name": new_user.full_name,
        "role": new_user.role,
        "is_active": new_user.is_active
    }
    return success_response(user_resp, "User registered successfully")


@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)):
    """Multipart Form login matching standard OAuth2 and Flutter's AuthService.login."""
    result = await db.execute(select(User).where(User.email == form_data.username))
    user = result.scalars().first()
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(data={"sub": user.email, "role": user.role})
    refresh_token = create_refresh_token(data={"sub": user.email})
    
    # Save refresh token in database for rotation tracking
    user.refresh_token = refresh_token
    await db.commit()
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "role": user.role
    }


@router.get("/me")
async def get_me(current_user: User = Depends(get_current_active_user)):
    """Retrieve logged-in user profile details."""
    user_resp = {
        "id": current_user.id,
        "email": current_user.email,
        "phone": current_user.phone,
        "full_name": current_user.full_name,
        "role": current_user.role,
        "is_active": current_user.is_active
    }
    return success_response(user_resp, "Profile retrieved successfully")


@router.post("/verify-otp")
async def verify_otp(phone: str, otp: str, db: AsyncSession = Depends(get_db)):
    """OTP validation flow."""
    result = await db.execute(select(User).where(User.phone == phone))
    user = result.scalars().first()
    
    if not user or user.otp_code != otp or (user.otp_expiry and user.otp_expiry < datetime.utcnow()):
        return error_response(["Invalid or expired OTP"], "Verification failed", 401)
        
    access_token = create_access_token(data={"sub": user.email, "role": user.role})
    return success_response({"access_token": access_token, "token_type": "bearer"}, "OTP verified successfully")


@router.post("/verify-pin")
async def verify_pin(email: str, pin: str, db: AsyncSession = Depends(get_db)):
    """PIN authentication verification flow."""
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalars().first()
    
    if not user or not user.pin_hash or not verify_password(pin, user.pin_hash):
        return error_response(["Invalid PIN"], "Verification failed", 401)
        
    access_token = create_access_token(data={"sub": user.email, "role": user.role})
    return success_response({"access_token": access_token, "token_type": "bearer"}, "PIN verified successfully")


@router.post("/logout")
async def logout(current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    """Invalidate user's refresh token (logout)."""
    current_user.refresh_token = None
    await db.commit()
    return success_response(None, "Logged out successfully")


@router.post("/refresh")
async def refresh(token: str, db: AsyncSession = Depends(get_db)):
    """Generate new access token from valid refresh token."""
    from app.security import oauth2_scheme
    from jose import JWTError, jwt
    from app.core.config import settings
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid refresh token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        token_type: str = payload.get("type")
        if email is None or token_type != "refresh":
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    # Fetch user and verify refresh token
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalars().first()
    
    if not user or user.refresh_token != token or user.is_deleted or not user.is_active:
        raise credentials_exception
    
    # Generate new access token
    access_token = create_access_token(data={"sub": user.email, "role": user.role})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "role": user.role
    }


@router.post("/request-otp")
async def request_otp(phone: str, db: AsyncSession = Depends(get_db)):
    """Request OTP for phone number (generates real 6-digit OTP with 10-minute expiry)."""
    result = await db.execute(select(User).where(User.phone == phone))
    user = result.scalars().first()
    
    if not user:
        return error_response(["Phone number not registered"], "OTP request failed", 404)
    
    # Generate 6-digit OTP
    otp_code = ''.join(random.choices(string.digits, k=6))
    otp_expiry = datetime.utcnow() + timedelta(minutes=10)
    
    user.otp_code = otp_code
    user.otp_expiry = otp_expiry
    await db.commit()
    
    # In production, send OTP via SMS/Twilio
    # For now, return for testing only
    return success_response({
        "phone": phone,
        "message": "OTP sent successfully",
        "otp_for_testing": otp_code  # REMOVE in production
    }, "OTP requested successfully")


class ForgotPasswordRequest(BaseModel):
    email: str

class ResetPasswordRequest(BaseModel):
    email: str
    otp: str
    new_password: str

@router.post("/forgot-password")
async def forgot_password(req: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    """Initiate password reset flow - generates 6-digit OTP and stores it."""
    result = await db.execute(select(User).where(User.email == req.email))
    user = result.scalars().first()
    
    if not user:
        # For security, return success even if user not found
        return success_response(None, "OTP sent successfully")
    
    # Generate 6-digit OTP code (valid for 10 minutes)
    otp_code = ''.join(random.choices(string.digits, k=6))
    otp_expiry = datetime.utcnow() + timedelta(minutes=10)
    
    user.otp_code = otp_code
    user.otp_expiry = otp_expiry
    await db.commit()
    
    return success_response({
        "email": req.email,
        "otp_for_testing": otp_code  # For testing/automated validation
    }, "OTP sent successfully")


@router.post("/reset-password")
async def reset_password(req: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    """Reset password with valid OTP."""
    result = await db.execute(select(User).where(User.email == req.email))
    user = result.scalars().first()
    
    if not user:
        return error_response(["User not found"], "Password reset failed", 404)
    
    # Validate OTP and expiry
    if user.otp_code != req.otp or (user.otp_expiry and user.otp_expiry < datetime.utcnow()):
        return error_response(["Invalid or expired OTP"], "Password reset failed", 401)
    
    # Update password
    user.hashed_password = get_password_hash(req.new_password)
    user.otp_code = None
    user.otp_expiry = None
    await db.commit()
    
    return success_response(None, "Password updated successfully")


@router.post("/set-pin")
async def set_pin(pin: str, current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    """Set or update user PIN."""
    if not pin or len(pin) < 4 or len(pin) > 6:
        return error_response(["PIN must be 4-6 digits"], "PIN setup failed", 400)
    
    current_user.pin_hash = get_password_hash(pin)
    await db.commit()
    return success_response(None, "PIN set successfully")
