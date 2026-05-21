"""
PANOR — Complete Pydantic Schemas (Request / Response)
All 4 roles: Patient | Doctor | LabTechnician | Administrator
"""
from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, List, Any, Dict
from datetime import datetime, date
import re

# ─────────────────────────────────────────────────────────────────────────────
# AUTH SCHEMAS
# ─────────────────────────────────────────────────────────────────────────────
class Token(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str = "bearer"
    role: Optional[str] = None

class TokenPayload(BaseModel):
    sub: Optional[str] = None
    role: Optional[str] = None
    type: Optional[str] = None

class OTPRequest(BaseModel):
    phone: str
    role: str

class OTPVerify(BaseModel):
    phone: str
    otp: str

class PINVerify(BaseModel):
    email: str
    pin: str

class PINSetup(BaseModel):
    pin: str = Field(..., min_length=4, max_length=8)

# ─────────────────────────────────────────────────────────────────────────────
# USER
# ─────────────────────────────────────────────────────────────────────────────
class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    # Patient | Doctor | LabTechnician | Administrator
    role: str
    phone: Optional[str] = None

class UserCreate(UserBase):
    password: str

    @field_validator("role")
    @classmethod
    def validate_role(cls, v: str) -> str:
        allowed = {"Patient", "Doctor", "LabTechnician", "Administrator"}
        if v not in allowed:
            raise ValueError(f"role must be one of {allowed}")
        return v

class UserResponse(UserBase):
    id: str
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# ─────────────────────────────────────────────────────────────────────────────
# PATIENT
# ─────────────────────────────────────────────────────────────────────────────
class PatientProfileUpdate(BaseModel):
    blood_group:       Optional[str] = None
    date_of_birth:     Optional[date] = None
    gender:            Optional[str] = None
    address:           Optional[str] = None
    city:              Optional[str] = None
    province:          Optional[str] = None
    cnic:              Optional[str] = None
    emergency_contact: Optional[str] = None
    emergency_name:    Optional[str] = None

class PatientResponse(BaseModel):
    id:                str
    patient_id:        Optional[str] = None
    email:             str
    full_name:         str
    phone:             Optional[str] = None
    blood_group:       Optional[str] = None
    date_of_birth:     Optional[date] = None
    gender:            Optional[str] = None
    address:           Optional[str] = None
    city:              Optional[str] = None
    cnic:              Optional[str] = None
    emergency_contact: Optional[str] = None
    emergency_name:    Optional[str] = None
    welfare_score:     Optional[int] = None
    welfare_tier:      Optional[str] = None

# ─────────────────────────────────────────────────────────────────────────────
# DOCTOR
# ─────────────────────────────────────────────────────────────────────────────
class DoctorProfileUpdate(BaseModel):
    specialty:        Optional[str] = None
    qualification:    Optional[str] = None
    hospital:         Optional[str] = None
    city:             Optional[str] = None
    consultation_fee: Optional[float] = None
    experience_years: Optional[int] = None
    bio:              Optional[str] = None
    availability:     Optional[Dict[str, Any]] = None

class DoctorResponse(BaseModel):
    id:               str
    email:            str
    full_name:        str
    phone:            Optional[str] = None
    specialty:        str
    license_number:   str
    qualification:    Optional[str] = None
    hospital:         Optional[str] = None
    consultation_fee: float
    experience_years: Optional[int] = None
    rating:           Optional[float] = None
    image_url:        Optional[str] = None
    availability:     Optional[Dict[str, Any]] = None

# ─────────────────────────────────────────────────────────────────────────────
# LAB TECHNICIAN
# ─────────────────────────────────────────────────────────────────────────────
class LabTechnicianProfileUpdate(BaseModel):
    facility_name:  Optional[str] = None
    facility_city:  Optional[str] = None
    qualification:  Optional[str] = None
    specialization: Optional[str] = None
    shift:          Optional[str] = None

class LabTechnicianResponse(BaseModel):
    id:             str
    email:          str
    full_name:      str
    phone:          Optional[str] = None
    employee_id:    Optional[str] = None
    facility_name:  Optional[str] = None
    facility_city:  Optional[str] = None
    qualification:  Optional[str] = None
    specialization: Optional[str] = None
    shift:          Optional[str] = None
    is_verified:    bool

# ─────────────────────────────────────────────────────────────────────────────
# APPOINTMENT
# ─────────────────────────────────────────────────────────────────────────────
class AppointmentCreate(BaseModel):
    doctor_id:        str
    datetime:         datetime
    specialty:        str
    type:             str = "First Visit"
    notes:            Optional[str] = None
    chief_complaint:  Optional[str] = None
    duration_minutes: Optional[int] = 30

class AppointmentUpdate(BaseModel):
    status:  Optional[str] = None
    notes:   Optional[str] = None
    type:    Optional[str] = None

class AppointmentResponse(BaseModel):
    id:           str
    patient_id:   str
    patient_name: str
    doctor_id:    str
    doctor_name:  str
    specialty:    str
    datetime:     datetime
    status:       str
    type:         str
    notes:        Optional[str] = None
    image_url:    Optional[str] = None
    created_at:   datetime

# ─────────────────────────────────────────────────────────────────────────────
# VITALS
# ─────────────────────────────────────────────────────────────────────────────
class VitalsCreate(BaseModel):
    blood_pressure: Optional[str] = None
    heart_rate:     Optional[str] = None
    temperature:    Optional[float] = None
    oxygen_level:   Optional[int] = None
    weight_kg:      Optional[float] = None
    height_cm:      Optional[float] = None
    glucose:        Optional[float] = None

class VitalsResponse(BaseModel):
    id:             str
    patient_id:     str
    blood_pressure: Optional[str] = None
    heart_rate:     Optional[str] = None
    temperature:    Optional[float] = None
    oxygen_level:   Optional[int] = None
    weight_kg:      Optional[float] = None
    height_cm:      Optional[float] = None
    bmi:            Optional[float] = None
    glucose:        Optional[float] = None
    recorded_at:    datetime

# ─────────────────────────────────────────────────────────────────────────────
# MEDICATION
# ─────────────────────────────────────────────────────────────────────────────
class MedicationCreate(BaseModel):
    name:       str
    dosage:     str
    frequency:  str
    route:      Optional[str] = "Oral"
    start_date: date
    end_date:   Optional[date] = None
    notes:      Optional[str] = None

class MedicationResponse(BaseModel):
    id:         str
    name:       str
    dosage:     str
    frequency:  str
    route:      Optional[str] = None
    start_date: date
    end_date:   Optional[date] = None
    is_active:  bool
    notes:      Optional[str] = None

# ─────────────────────────────────────────────────────────────────────────────
# LAB REPORT
# ─────────────────────────────────────────────────────────────────────────────
class LabReportCreate(BaseModel):
    test_name:       str
    priority:        str = "ROUTINE"  # STAT | URGENT | ROUTINE
    clinical_intent: Optional[str] = None
    deadline:        Optional[str] = None

class LabResultSubmit(BaseModel):
    """Submitted by the lab technician to record results."""
    results:        Dict[str, Any]
    result_summary: Optional[str] = None
    is_flagged:     bool = False
    is_critical:    bool = False
    report_url:     Optional[str] = None

class LabReportResponse(BaseModel):
    id:              str
    test_name:       str
    priority:        str
    status:          str
    clinical_intent: Optional[str] = None
    results:         Optional[Dict[str, Any]] = None
    result_summary:  Optional[str] = None
    is_flagged:      bool
    is_critical:     bool
    deadline:        Optional[str] = None
    ordered_at:      datetime
    completed_at:    Optional[datetime] = None
    report_url:      Optional[str] = None

# ─────────────────────────────────────────────────────────────────────────────
# DOCUMENT (PDF uploads, OCR)
# ─────────────────────────────────────────────────────────────────────────────
class DocumentResponse(BaseModel):
    id:             str
    doc_type:       str
    file_name:      Optional[str] = None
    file_url:       str
    ai_summary:     Optional[str] = None
    source_hospital:Optional[str] = None
    created_at:     datetime

# ─────────────────────────────────────────────────────────────────────────────
# HEALTH RECORD
# ─────────────────────────────────────────────────────────────────────────────
class HealthRecordCreate(BaseModel):
    record_type:  str
    title:        Optional[str] = None
    summary:      str
    raw_data:     Optional[Dict[str, Any]] = None
    source:       Optional[str] = "PANOR"

class HealthRecordResponse(BaseModel):
    id:          str
    record_type: str
    title:       Optional[str] = None
    summary:     str
    source:      Optional[str] = None
    is_verified: bool
    created_at:  datetime

# ─────────────────────────────────────────────────────────────────────────────
# PRESCRIPTION
# ─────────────────────────────────────────────────────────────────────────────
class PrescriptionCreate(BaseModel):
    patient_id:      str
    appointment_id:  Optional[str] = None
    diagnosis:       Optional[str] = None
    # [{name, dosage, frequency, duration, instructions}]
    medications:     List[Dict[str, Any]]
    differential_dx: Optional[List[str]] = None
    icd_codes:       Optional[List[str]] = None
    follow_up_days:  Optional[int] = None
    notes:           Optional[str] = None

class PrescriptionResponse(BaseModel):
    id:             str
    patient_id:     str
    doctor_name:    str
    diagnosis:      Optional[str] = None
    medications:    List[Dict[str, Any]]
    follow_up_days: Optional[int] = None
    created_at:     datetime

# ─────────────────────────────────────────────────────────────────────────────
# SOAP NOTE
# ─────────────────────────────────────────────────────────────────────────────
class SOAPNoteResponse(BaseModel):
    id:             str
    appointment_id: str
    subjective:     Optional[str] = None
    objective:      Optional[str] = None
    assessment:     Optional[str] = None
    plan:           Optional[str] = None
    ai_confidence:  float
    is_finalized:   bool
    created_at:     datetime

# ─────────────────────────────────────────────────────────────────────────────
# AI ASSISTANT
# ─────────────────────────────────────────────────────────────────────────────
class ChatMessage(BaseModel):
    role:    str  # user | assistant | system
    content: str

class AIChatRequest(BaseModel):
    message:    str
    session_id: Optional[str] = None

class AIChatResponse(BaseModel):
    session_id: str
    response:   str
    history:    List[ChatMessage]

class ConsultationRequest(BaseModel):
    symptoms:   str
    session_id: Optional[str] = None

# ─────────────────────────────────────────────────────────────────────────────
# NOTIFICATION
# ─────────────────────────────────────────────────────────────────────────────
class NotificationResponse(BaseModel):
    id:                str
    title:             str
    message:           str
    notification_type: str
    is_read:           bool
    created_at:        datetime

# ─────────────────────────────────────────────────────────────────────────────
# ADMIN
# ─────────────────────────────────────────────────────────────────────────────
class WelfareScoreUpdate(BaseModel):
    patient_id:    str
    welfare_score: int = Field(..., ge=0, le=100)
    welfare_tier:  str  # Platinum | Gold | Silver | Basic

class PricingUpdate(BaseModel):
    resource_type: str  # "lab_test" | "consultation"
    resource_name: str
    base_price:    float
    welfare_discount_pct: Optional[float] = None
