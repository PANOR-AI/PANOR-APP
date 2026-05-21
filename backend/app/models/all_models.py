"""
PANOR — All SQLAlchemy Database Models
Production-grade schema covering all 4 roles:
  Patient | Doctor | LabTechnician | Administrator
"""
import uuid
import datetime as dt_module
from sqlalchemy import (
    Column, String, Integer, Float, Boolean, DateTime,
    Date, ForeignKey, Text, JSON, Enum as SAEnum
)
from sqlalchemy.orm import relationship
from app.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


# ─────────────────────────────────────────────────────────────────────────────
# USER (base identity table for all roles)
# ─────────────────────────────────────────────────────────────────────────────
class User(Base):
    __tablename__ = "users"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    email            = Column(String(255), unique=True, index=True, nullable=False)
    phone            = Column(String(50),  unique=True, index=True, nullable=True)
    hashed_password  = Column(String(255), nullable=False)
    full_name        = Column(String(255), nullable=False)
    # Role: Patient | Doctor | LabTechnician | Administrator
    role             = Column(String(50),  nullable=False)
    avatar_url       = Column(String(512), nullable=True)

    # OTP & PIN auth
    otp_code         = Column(String(10),  nullable=True)
    otp_expiry       = Column(DateTime,    nullable=True)
    pin_hash         = Column(String(255), nullable=True)

    # JWT rotation
    refresh_token    = Column(String(1024), nullable=True)

    # Soft-delete / state
    is_active        = Column(Boolean, default=True)
    is_deleted       = Column(Boolean, default=False)
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)
    updated_at       = Column(DateTime, default=dt_module.datetime.utcnow,
                              onupdate=dt_module.datetime.utcnow)

    # Relationships
    patient_profile  = relationship("Patient",        back_populates="user", uselist=False)
    doctor_profile   = relationship("Doctor",         back_populates="user", uselist=False)
    lab_profile      = relationship("LabTechnician",  back_populates="user", uselist=False)
    admin_profile    = relationship("Administrator",  back_populates="user", uselist=False)
    notifications    = relationship("Notification",   foreign_keys="Notification.user_id")
    audit_logs       = relationship("AuditLog",       foreign_keys="AuditLog.user_id")


# ─────────────────────────────────────────────────────────────────────────────
# PATIENT PROFILE
# ─────────────────────────────────────────────────────────────────────────────
class Patient(Base):
    __tablename__ = "patients"

    id               = Column(String(36), ForeignKey("users.id"), primary_key=True)
    # National P_ID — assigned on registration
    patient_id       = Column(String(50), unique=True, nullable=True, index=True)
    blood_group      = Column(String(10),  nullable=True)
    date_of_birth    = Column(Date,        nullable=True)
    gender           = Column(String(20),  nullable=True)
    address          = Column(Text,        nullable=True)
    city             = Column(String(100), nullable=True)
    province         = Column(String(100), nullable=True)
    cnic             = Column(String(20),  unique=True, nullable=True, index=True)
    emergency_contact= Column(String(100), nullable=True)
    emergency_name   = Column(String(100), nullable=True)
    # AI-computed welfare score (0–100)
    welfare_score    = Column(Integer, default=0)
    welfare_tier     = Column(String(20), default="Basic")  # Platinum/Gold/Silver/Basic

    # Relationships
    user             = relationship("User",          back_populates="patient_profile")
    appointments     = relationship("Appointment",   back_populates="patient")
    health_records   = relationship("HealthRecord",  back_populates="patient")
    prescriptions    = relationship("Prescription",  back_populates="patient")
    vitals           = relationship("Vitals",        back_populates="patient")
    lab_reports      = relationship("LabReport",     back_populates="patient")
    medications      = relationship("Medication",    back_populates="patient")
    ai_conversations = relationship("AIConversation",back_populates="patient")
    documents        = relationship("Document",      back_populates="patient")


# ─────────────────────────────────────────────────────────────────────────────
# DOCTOR PROFILE
# ─────────────────────────────────────────────────────────────────────────────
class Doctor(Base):
    __tablename__ = "doctors"

    id               = Column(String(36), ForeignKey("users.id"), primary_key=True)
    specialty        = Column(String(100), nullable=False, default="General Medicine")
    license_number   = Column(String(100), nullable=False)
    qualification    = Column(String(255), nullable=True)
    hospital         = Column(String(255), nullable=True)
    city             = Column(String(100), nullable=True)
    consultation_fee = Column(Float, default=0.0)
    experience_years = Column(Integer, default=0)
    bio              = Column(Text, nullable=True)
    availability     = Column(JSON, nullable=True)  # {Mon: ["09:00","10:00"], ...}
    image_url        = Column(String(512), nullable=True)
    rating           = Column(Float, default=0.0)
    total_reviews    = Column(Integer, default=0)

    # Relationships
    user             = relationship("User",         back_populates="doctor_profile")
    appointments     = relationship("Appointment",  back_populates="doctor")
    health_records   = relationship("HealthRecord", back_populates="doctor")
    prescriptions    = relationship("Prescription", back_populates="doctor")
    lab_reports      = relationship("LabReport",    back_populates="doctor")


# ─────────────────────────────────────────────────────────────────────────────
# LAB TECHNICIAN PROFILE
# ─────────────────────────────────────────────────────────────────────────────
class LabTechnician(Base):
    __tablename__ = "lab_technicians"

    id               = Column(String(36), ForeignKey("users.id"), primary_key=True)
    employee_id      = Column(String(50),  unique=True, nullable=True, index=True)
    facility_name    = Column(String(255), nullable=True)
    facility_city    = Column(String(100), nullable=True)
    qualification    = Column(String(255), nullable=True)
    specialization   = Column(String(100), nullable=True)
    shift            = Column(String(100), nullable=True)
    is_verified      = Column(Boolean, default=False)

    # Relationships
    user             = relationship("User", back_populates="lab_profile")
    processed_reports= relationship("LabReport", back_populates="technician",
                                    foreign_keys="LabReport.technician_id")


# ─────────────────────────────────────────────────────────────────────────────
# ADMINISTRATOR PROFILE
# ─────────────────────────────────────────────────────────────────────────────
class Administrator(Base):
    __tablename__ = "administrators"

    id               = Column(String(36), ForeignKey("users.id"), primary_key=True)
    department       = Column(String(100), nullable=True)
    access_level     = Column(Integer, default=1)  # 1=Viewer, 2=Manager, 3=SuperAdmin

    # Relationships
    user             = relationship("User", back_populates="admin_profile")


# ─────────────────────────────────────────────────────────────────────────────
# APPOINTMENT
# ─────────────────────────────────────────────────────────────────────────────
class Appointment(Base):
    __tablename__ = "appointments"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    doctor_id        = Column(String(36), ForeignKey("doctors.id"),  nullable=False, index=True)
    datetime         = Column(DateTime,   nullable=False)
    specialty        = Column(String(100),nullable=False)
    # scheduled | in_progress | completed | cancelled | no_show
    status           = Column(String(50), default="scheduled")
    # First Visit | Follow-up | Emergency | Teleconsultation
    type             = Column(String(50), default="First Visit")
    notes            = Column(Text, nullable=True)
    chief_complaint  = Column(Text, nullable=True)
    duration_minutes = Column(Integer, default=30)
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient          = relationship("Patient",      back_populates="appointments")
    doctor           = relationship("Doctor",       back_populates="appointments")
    prescriptions    = relationship("Prescription", back_populates="appointment")
    soap_note        = relationship("SOAPNote",     back_populates="appointment", uselist=False)


# ─────────────────────────────────────────────────────────────────────────────
# HEALTH RECORD (generic timeline entry)
# ─────────────────────────────────────────────────────────────────────────────
class HealthRecord(Base):
    __tablename__ = "health_records"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    doctor_id        = Column(String(36), ForeignKey("doctors.id"),  nullable=True)
    record_type      = Column(String(50), nullable=False)
    # Prescription | LabReport | ImagingReport | Vitals | Document | Discharge | Vaccination
    title            = Column(String(255), nullable=True)
    summary          = Column(Text, nullable=False)
    raw_data         = Column(JSON, nullable=True)
    file_url         = Column(String(512), nullable=True)
    source           = Column(String(100), nullable=True)  # "PANOR" | "Uploaded" | "OCR"
    is_verified      = Column(Boolean, default=False)
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient          = relationship("Patient", back_populates="health_records")
    doctor           = relationship("Doctor",  back_populates="health_records")


# ─────────────────────────────────────────────────────────────────────────────
# PRESCRIPTION
# ─────────────────────────────────────────────────────────────────────────────
class Prescription(Base):
    __tablename__ = "prescriptions"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    doctor_id        = Column(String(36), ForeignKey("doctors.id"),  nullable=False)
    appointment_id   = Column(String(36), ForeignKey("appointments.id"), nullable=True)
    diagnosis        = Column(Text, nullable=True)
    # [{name, dosage, frequency, duration, instructions}]
    medications      = Column(JSON, nullable=False, default=list)
    # Differential diagnosis from AI
    differential_dx  = Column(JSON, nullable=True)
    icd_codes        = Column(JSON, nullable=True)  # ["I21.0", ...]
    follow_up_days   = Column(Integer, nullable=True)
    notes            = Column(Text, nullable=True)
    is_ai_generated  = Column(Boolean, default=False)
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient          = relationship("Patient",     back_populates="prescriptions")
    doctor           = relationship("Doctor",      back_populates="prescriptions")
    appointment      = relationship("Appointment", back_populates="prescriptions")


# ─────────────────────────────────────────────────────────────────────────────
# LAB REPORT
# ─────────────────────────────────────────────────────────────────────────────
class LabReport(Base):
    __tablename__ = "lab_reports"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    doctor_id        = Column(String(36), ForeignKey("doctors.id"),  nullable=True)
    technician_id    = Column(String(36), ForeignKey("lab_technicians.id"), nullable=True)
    test_name        = Column(String(100), nullable=False)
    # STAT | URGENT | ROUTINE
    priority         = Column(String(20), default="ROUTINE")
    # Pending | In Progress | Completed | Cancelled
    status           = Column(String(50), default="Pending")
    # AI-generated clinical intent context
    clinical_intent  = Column(Text, nullable=True)
    # Raw numeric/text results
    results          = Column(JSON, nullable=True)
    result_summary   = Column(Text, nullable=True)
    # Has any value exceeded normal range?
    is_flagged       = Column(Boolean, default=False)
    is_critical      = Column(Boolean, default=False)
    # Deadline ISO string
    deadline         = Column(String(50), nullable=True)
    ordered_at       = Column(DateTime, default=dt_module.datetime.utcnow)
    completed_at     = Column(DateTime, nullable=True)
    # Report PDF or image URL
    report_url       = Column(String(512), nullable=True)

    # Relationships
    patient          = relationship("Patient",        back_populates="lab_reports")
    doctor           = relationship("Doctor",         back_populates="lab_reports")
    technician       = relationship("LabTechnician",  back_populates="processed_reports",
                                    foreign_keys=[technician_id])


# ─────────────────────────────────────────────────────────────────────────────
# VITALS
# ─────────────────────────────────────────────────────────────────────────────
class Vitals(Base):
    __tablename__ = "vitals"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    blood_pressure   = Column(String(50), nullable=True)   # "120/80"
    heart_rate       = Column(String(50), nullable=True)   # "72"
    temperature      = Column(Float, nullable=True)        # Fahrenheit
    oxygen_level     = Column(Integer, nullable=True)      # SpO2 %
    weight_kg        = Column(Float, nullable=True)
    height_cm        = Column(Float, nullable=True)
    bmi              = Column(Float, nullable=True)
    glucose          = Column(Float, nullable=True)        # mg/dL
    source           = Column(String(50), default="Manual") # Manual | AI | Device
    recorded_at      = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient          = relationship("Patient", back_populates="vitals")


# ─────────────────────────────────────────────────────────────────────────────
# MEDICATION (active medication schedule)
# ─────────────────────────────────────────────────────────────────────────────
class Medication(Base):
    __tablename__ = "medications"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    name             = Column(String(255), nullable=False)
    generic_name     = Column(String(255), nullable=True)
    dosage           = Column(String(100), nullable=False)
    frequency        = Column(String(100), nullable=False)
    route            = Column(String(50),  nullable=True)  # Oral | IV | IM | Topical
    start_date       = Column(Date, nullable=False)
    end_date         = Column(Date, nullable=True)
    is_active        = Column(Boolean, default=True)
    prescribed_by    = Column(String(36), ForeignKey("users.id"), nullable=True)
    notes            = Column(Text, nullable=True)

    # Relationships
    patient          = relationship("Patient", back_populates="medications")


# ─────────────────────────────────────────────────────────────────────────────
# DOCUMENT (uploaded PDFs, images, OCR records)
# ─────────────────────────────────────────────────────────────────────────────
class Document(Base):
    __tablename__ = "documents"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    # LabResult | PrescriptionPDF | ImagingDICOM | VoiceNote | MedicalHistory | Vaccination
    doc_type         = Column(String(50),  nullable=False)
    file_name        = Column(String(255), nullable=True)
    file_url         = Column(String(512), nullable=False)
    ocr_text         = Column(Text, nullable=True)      # OCR-extracted text
    ai_summary       = Column(Text, nullable=True)      # AI-generated summary
    source_hospital  = Column(String(255), nullable=True)
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient          = relationship("Patient", back_populates="documents")


# ─────────────────────────────────────────────────────────────────────────────
# SOAP NOTE (AI-generated clinical note)
# ─────────────────────────────────────────────────────────────────────────────
class SOAPNote(Base):
    __tablename__ = "soap_notes"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    appointment_id   = Column(String(36), ForeignKey("appointments.id"), nullable=False)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False)
    doctor_id        = Column(String(36), ForeignKey("doctors.id"), nullable=True)
    # SOAP sections
    subjective       = Column(Text, nullable=True)
    objective        = Column(Text, nullable=True)
    assessment       = Column(Text, nullable=True)
    plan             = Column(Text, nullable=True)
    ai_confidence    = Column(Float, default=0.0)
    is_finalized     = Column(Boolean, default=False)
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    appointment      = relationship("Appointment", back_populates="soap_note")


# ─────────────────────────────────────────────────────────────────────────────
# AI CONVERSATION SESSION
# ─────────────────────────────────────────────────────────────────────────────
class AIConversation(Base):
    __tablename__ = "ai_conversations"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id       = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    session_type     = Column(String(50), default="chat")   # chat | consultation | triage
    # [{role: user|assistant|system, content: "..."}]
    messages         = Column(JSON, nullable=False, default=list)
    metadata         = Column(JSON, nullable=True)  # {agents_trace, severity, ...}
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)
    updated_at       = Column(DateTime, default=dt_module.datetime.utcnow,
                              onupdate=dt_module.datetime.utcnow)

    # Relationships
    patient          = relationship("Patient", back_populates="ai_conversations")


# ─────────────────────────────────────────────────────────────────────────────
# NOTIFICATION
# ─────────────────────────────────────────────────────────────────────────────
class Notification(Base):
    __tablename__ = "notifications"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id          = Column(String(36), ForeignKey("users.id"), nullable=False, index=True)
    title            = Column(String(255), nullable=False)
    message          = Column(Text, nullable=False)
    # info | warning | success | emergency | lab | appointment | prescription | system
    notification_type= Column(String(50), default="info")
    is_read          = Column(Boolean, default=False)
    action_url       = Column(String(255), nullable=True)
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)


# ─────────────────────────────────────────────────────────────────────────────
# ANALYTICS EVENT
# ─────────────────────────────────────────────────────────────────────────────
class AnalyticsEvent(Base):
    __tablename__ = "analytics_events"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    event_type       = Column(String(100), nullable=False, index=True)
    user_id          = Column(String(36), ForeignKey("users.id"), nullable=True)
    payload          = Column(JSON, nullable=False, default=dict)
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)


# ─────────────────────────────────────────────────────────────────────────────
# AUDIT LOG (immutable activity trail)
# ─────────────────────────────────────────────────────────────────────────────
class AuditLog(Base):
    __tablename__ = "audit_logs"

    id               = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id          = Column(String(36), ForeignKey("users.id"), nullable=True, index=True)
    action           = Column(String(100), nullable=False, index=True)
    resource_type    = Column(String(50), nullable=True)   # User | Patient | LabReport | ...
    resource_id      = Column(String(36), nullable=True)
    details          = Column(Text, nullable=True)
    ip_address       = Column(String(45), nullable=True)
    # INFO | WARNING | CRITICAL
    severity         = Column(String(20), default="INFO")
    created_at       = Column(DateTime, default=dt_module.datetime.utcnow)
