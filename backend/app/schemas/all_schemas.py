from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Any, Dict
from datetime import datetime, date
from app.models.all_models import RoleEnum

# ----------------- Token Schemas -----------------
class Token(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str = "bearer"
    role: Optional[str] = None

class TokenPayload(BaseModel):
    sub: Optional[str] = None
    role: Optional[str] = None
    type: Optional[str] = None

# ----------------- User Schemas -----------------
class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    role: RoleEnum
    phone: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: str
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# ----------------- Patient Schemas -----------------
class PatientProfileUpdate(BaseModel):
    blood_group: Optional[str] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    address: Optional[str] = None
    emergency_contact: Optional[str] = None

class PatientResponse(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str] = None
    blood_group: Optional[str] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    address: Optional[str] = None
    emergency_contact: Optional[str] = None

# ----------------- Doctor Schemas -----------------
class DoctorResponse(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str] = None
    specialty: str
    license_number: str
    consultation_fee: float
    availability: Optional[Dict[str, Any]] = None
    image_url: Optional[str] = None

# ----------------- Appointment Schemas -----------------
class AppointmentCreate(BaseModel):
    doctor_id: str
    datetime: datetime
    specialty: str
    type: str = "First Visit"
    notes: Optional[str] = None

class AppointmentResponse(BaseModel):
    id: str
    patient_id: str
    patient_name: str
    doctor_id: str
    doctor_name: str
    datetime: datetime
    specialty: str
    status: str
    type: str
    notes: Optional[str] = None
    image_url: Optional[str] = None
    created_at: datetime

# ----------------- Vitals Schemas -----------------
class VitalsCreate(BaseModel):
    blood_pressure: str
    heart_rate: str
    temperature: Optional[float] = None
    oxygen_level: Optional[int] = None

class VitalsResponse(BaseModel):
    id: str
    patient_id: str
    blood_pressure: str
    heart_rate: str
    temperature: Optional[float] = None
    oxygen_level: Optional[int] = None
    recorded_at: datetime

# ----------------- Medication Schemas -----------------
class MedicationCreate(BaseModel):
    name: str
    dosage: str
    frequency: str
    start_date: date
    end_date: date

class MedicationResponse(BaseModel):
    id: str
    name: str
    dosage: str
    frequency: str
    start_date: date
    end_date: date
    is_active: bool

# ----------------- AI/Antigravity Schemas -----------------
class ChatMessage(BaseModel):
    role: str  # user, assistant
    content: str

class AIChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None

class AIChatResponse(BaseModel):
    session_id: str
    response: str
    history: List[ChatMessage]

# ----------------- Lab & Clinical Schemas -----------------
class LabReportCreate(BaseModel):
    test_name: str
    results: Optional[Dict[str, Any]] = None
    priority: str = "ROUTINE"

class LabReportResponse(BaseModel):
    id: str
    test_name: str
    results: Optional[Dict[str, Any]] = None
    status: str
    priority: str
    created_at: datetime

    class Config:
        from_attributes = True

# ----------------- Consultation Schemas -----------------
class ConsultationCreate(BaseModel):
    patient_id: str
    appointment_id: Optional[str] = None
    soap_note: Dict[str, Any]
    ai_trace: Optional[Dict[str, Any]] = None
    confidence_score: Optional[float] = 1.0

class ConsultationResponse(BaseModel):
    id: str
    patient_id: str
    doctor_id: str
    appointment_id: Optional[str] = None
    soap_note: Dict[str, Any]
    ai_trace: Optional[Dict[str, Any]] = None
    confidence_score: float
    created_at: datetime

    class Config:
        from_attributes = True

# ----------------- Epidemiology Schemas -----------------
class EpidemiologyEventCreate(BaseModel):
    disease_name: str
    location: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    cases: int = 1
    deaths: int = 0
    status: str = "Active"

class EpidemiologyEventResponse(BaseModel):
    id: str
    disease_name: str
    location: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    cases: int
    deaths: int
    reported_at: datetime
    status: str

    class Config:
        from_attributes = True

