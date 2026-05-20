import uuid
import datetime as dt_module
from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, Date, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from app.database import Base

def generate_uuid():
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    phone = Column(String(50), unique=True, index=True, nullable=True)
    hashed_password = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False)  # Patient, Doctor, Administrator, LabTechnician
    full_name = Column(String(255), nullable=False)
    
    # OTP & PIN Signins
    otp_code = Column(String(10), nullable=True)
    otp_expiry = Column(DateTime, nullable=True)
    pin_hash = Column(String(255), nullable=True)
    
    # Security Token Rotation
    refresh_token = Column(String(512), nullable=True)
    
    # State fields
    is_active = Column(Boolean, default=True)
    is_deleted = Column(Boolean, default=False)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)
    updated_at = Column(DateTime, default=dt_module.datetime.utcnow, onupdate=dt_module.datetime.utcnow)

    # Relationships
    patient_profile = relationship("Patient", back_populates="user", uselist=False)
    doctor_profile = relationship("Doctor", back_populates="user", uselist=False)
    admin_profile = relationship("Administrator", back_populates="user", uselist=False)


class Patient(Base):
    __tablename__ = "patients"

    id = Column(String(36), ForeignKey("users.id"), primary_key=True)
    blood_group = Column(String(10), nullable=True)
    date_of_birth = Column(Date, nullable=True)
    gender = Column(String(20), nullable=True)
    address = Column(Text, nullable=True)
    emergency_contact = Column(String(100), nullable=True)

    # Relationships
    user = relationship("User", back_populates="patient_profile")
    appointments = relationship("Appointment", back_populates="patient")
    health_records = relationship("HealthRecord", back_populates="patient")
    prescriptions = relationship("Prescription", back_populates="patient")
    vitals = relationship("Vitals", back_populates="patient")
    lab_reports = relationship("LabReport", back_populates="patient")
    medications = relationship("Medication", back_populates="patient")
    ai_conversations = relationship("AIConversation", back_populates="patient")


class Doctor(Base):
    __tablename__ = "doctors"

    id = Column(String(36), ForeignKey("users.id"), primary_key=True)
    specialty = Column(String(100), nullable=False)
    license_number = Column(String(100), nullable=False)
    consultation_fee = Column(Float, default=0.0)
    availability = Column(JSON, nullable=True)
    image_url = Column(String(255), nullable=True)

    # Relationships
    user = relationship("User", back_populates="doctor_profile")
    appointments = relationship("Appointment", back_populates="doctor")
    health_records = relationship("HealthRecord", back_populates="doctor")
    prescriptions = relationship("Prescription", back_populates="doctor")
    lab_reports = relationship("LabReport", back_populates="doctor")


class Administrator(Base):
    __tablename__ = "administrators"

    id = Column(String(36), ForeignKey("users.id"), primary_key=True)
    department = Column(String(100), nullable=True)

    # Relationships
    user = relationship("User", back_populates="admin_profile")


class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(String(36), ForeignKey("doctors.id"), nullable=False)
    datetime = Column(DateTime, nullable=False)
    specialty = Column(String(100), nullable=False)
    status = Column(String(50), default="scheduled")  # scheduled, completed, cancelled
    type = Column(String(50), default="First Visit")  # First Visit, Follow-up, Consultation
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient = relationship("Patient", back_populates="appointments")
    doctor = relationship("Doctor", back_populates="appointments")
    prescriptions = relationship("Prescription", back_populates="appointment")


class HealthRecord(Base):
    __tablename__ = "health_records"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(String(36), ForeignKey("doctors.id"), nullable=True)
    record_type = Column(String(50), nullable=False)  # Prescription, LabReport, ImagingReport, Vitals, Document
    summary = Column(Text, nullable=False)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient = relationship("Patient", back_populates="health_records")
    doctor = relationship("Doctor", back_populates="health_records")


class Prescription(Base):
    __tablename__ = "prescriptions"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(String(36), ForeignKey("doctors.id"), nullable=False)
    appointment_id = Column(String(36), ForeignKey("appointments.id"), nullable=True)
    diagnosis = Column(Text, nullable=True)
    medications = Column(JSON, nullable=False)  # List of dicts (name, dosage, frequency)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient = relationship("Patient", back_populates="prescriptions")
    doctor = relationship("Doctor", back_populates="prescriptions")
    appointment = relationship("Appointment", back_populates="prescriptions")


class LabReport(Base):
    __tablename__ = "lab_reports"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(String(36), ForeignKey("doctors.id"), nullable=True)
    test_name = Column(String(100), nullable=False)  # ECG, CBC, Troponin, etc.
    results = Column(JSON, nullable=True)
    status = Column(String(50), default="Pending")  # Pending, Completed
    priority = Column(String(50), default="ROUTINE")  # STAT, ROUTINE
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient = relationship("Patient", back_populates="lab_reports")
    doctor = relationship("Doctor", back_populates="lab_reports")


class ImagingReport(Base):
    __tablename__ = "imaging_reports"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(String(36), ForeignKey("doctors.id"), nullable=True)
    study_type = Column(String(100), nullable=False)  # Chest X-Ray, Brain MRI, etc.
    findings = Column(Text, nullable=True)
    image_url = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)


class Vitals(Base):
    __tablename__ = "vitals"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    blood_pressure = Column(String(50), nullable=False)  # e.g., "120/80"
    heart_rate = Column(String(50), nullable=False)      # e.g., "72 bpm"
    temperature = Column(Float, nullable=True)
    oxygen_level = Column(Integer, nullable=True)
    recorded_at = Column(DateTime, default=dt_module.datetime.utcnow)

    # Relationships
    patient = relationship("Patient", back_populates="vitals")


class Document(Base):
    __tablename__ = "documents"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    doc_type = Column(String(50), nullable=False)  # LabResult, PrescriptionPDF, ImagingDICOM, VoiceNote
    file_url = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)


class Message(Base):
    __tablename__ = "messages"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    sender_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    receiver_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)


class Medication(Base):
    __tablename__ = "medications"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    name = Column(String(255), nullable=False)
    dosage = Column(String(100), nullable=False)
    frequency = Column(String(100), nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    is_active = Column(Boolean, default=True)

    # Relationships
    patient = relationship("Patient", back_populates="medications")


class AIConversation(Base):
    __tablename__ = "ai_conversations"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False)
    messages = Column(JSON, nullable=False)  # list of dicts: [{"role": "user", "content": "..."}]
    updated_at = Column(DateTime, default=dt_module.datetime.utcnow, onupdate=dt_module.datetime.utcnow)

    # Relationships
    patient = relationship("Patient", back_populates="ai_conversations")


class AnalyticsEvent(Base):
    __tablename__ = "analytics_events"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    event_type = Column(String(100), nullable=False)
    payload = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String(36), primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    action = Column(String(100), nullable=False)
    details = Column(Text, nullable=True)
    created_at = Column(DateTime, default=dt_module.datetime.utcnow)
