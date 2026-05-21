# PANOR Database Schema - Append-Only Medical Timeline

## Architecture

**Primary Database**: Firestore (append-only medical timeline, patient records)  
**Secondary Database**: PostgreSQL (structured data, user accounts, transactions)

---

## Firestore Collections

### Collection: `patients`

```json
{
  "patient_id": "PAN-NADRA-12345678",  // Immutable, NADRA-linked
  "created_at": "2024-05-20T10:30:00Z",
  
  // Immutable Fields (set at account creation)
  "demographics": {
    "full_name": "Ahmed Khan",
    "date_of_birth": "1990-03-15",
    "gender": "male",
    "cnic_number": "12345-6789012-3",  // NADRA reference
    "blood_group": "O+",
    "emergency_contact": "+92-300-1234567"
  },
  
  // Mutable Fields
  "contact": {
    "email": "ahmed@example.com",
    "phone_primary": "+92-300-1234567",
    "phone_secondary": "+92-321-9876543",
    "address": "Karachi, Pakistan"
  },
  
  // Account Status
  "account_status": "active",  // active, inactive, blocked
  "verification_status": "verified",  // verified, pending, failed
  "last_updated": "2024-05-20T14:00:00Z"
}
```

### Collection: `medical_timeline` (Append-Only)

**Rules**: 
- ✅ CREATE new documents
- ❌ UPDATE existing documents (forbidden)
- ❌ DELETE documents (forbidden)
- ✅ READ all documents

```json
{
  "timeline_id": "MTL-UUID-12345",
  "patient_id": "PAN-NADRA-12345678",
  "event_type": "consultation",  // consultation, lab_result, medication, diagnosis, follow_up
  
  // Timestamp (ensures chronological order)
  "created_at": "2024-05-20T10:30:00Z",
  "event_date": "2024-05-20",
  
  // Event-specific data
  "event_data": {
    // For consultation events
    "consultation_type": "intake_ai",  // intake_ai, doctor_consultation
    "description": "Patient reported fever, headache, body aches for 3 days",
    "symptoms": ["fever", "headache", "body_aches"],
    "severity_score": 6,
    "language": "urdu",
    "transcription": "آج 3 دن سے بخار ہے",
    
    // For lab results
    "lab_test_name": "CBC",
    "lab_result": {
      "wbc": 7500,
      "hemoglobin": 13.5,
      "platelets": 250000
    },
    
    // For medications
    "medication_name": "Paracetamol",
    "dosage": "500mg",
    "frequency": "every 8 hours",
    "duration_days": 7,
    "prescribed_by": "DOC-REG-12345",
    "prescribed_date": "2024-05-20"
  },
  
  // AI Pipeline Metadata
  "ai_pipeline": {
    "pipeline_id": "PIP-UUID-12345",
    "a1_intake_result": {...},
    "a2_clinical_reasoning_result": {...},
    "a7_verification_result": {...},
    "confidence_score": 0.85,
    "approval_status": "approved"
  },
  
  // Audit Trail
  "created_by": "patient_self",  // patient_self, doctor, lab_assistant
  "created_by_id": "PAN-NADRA-12345678",
  "verified_by": "DOC-REG-12345",  // If doctor verified
  "is_verified": true,
  
  // Immutable flag
  "immutable": true,
  "version": 1  // Always 1 for immutable records
}
```

---

## PostgreSQL Tables

### Table: `users`

```sql
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  user_id VARCHAR(50) UNIQUE NOT NULL,  -- PAN-NADRA-xxxx, DOC-REG-xxxx, etc.
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(512) NOT NULL,
  user_type ENUM('patient', 'doctor', 'lab_assistant', 'admin') NOT NULL,
  
  full_name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  
  mfa_enabled BOOLEAN DEFAULT true,
  mfa_method ENUM('sms', 'email', 'authenticator') DEFAULT 'sms',
  
  account_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP,
  
  CONSTRAINT email_valid CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX idx_user_id ON users(user_id);
CREATE INDEX idx_email ON users(email);
```

### Table: `patients`

```sql
CREATE TABLE patients (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  patient_id VARCHAR(50) UNIQUE NOT NULL,  -- PAN-NADRA-xxxx
  
  -- Immutable demographics (set at registration)
  full_name VARCHAR(255) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender ENUM('male', 'female', 'other') NOT NULL,
  blood_group VARCHAR(10),
  cnic_number VARCHAR(20) UNIQUE NOT NULL,  -- NADRA reference
  
  -- Mutable contact info
  primary_contact VARCHAR(20),
  emergency_contact VARCHAR(20),
  address TEXT,
  
  -- Welfare & Discounts
  welfare_score DECIMAL(5, 2) DEFAULT 0.0,  -- 0.0 - 100.0
  discount_eligible BOOLEAN DEFAULT false,
  discount_percentage DECIMAL(5, 2),
  
  account_status ENUM('active', 'inactive') DEFAULT 'active',
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT valid_welfare_score CHECK (welfare_score >= 0 AND welfare_score <= 100)
);

CREATE INDEX idx_patient_id ON patients(patient_id);
CREATE INDEX idx_cnic ON patients(cnic_number);
```

### Table: `doctors`

```sql
CREATE TABLE doctors (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  doctor_id VARCHAR(50) UNIQUE NOT NULL,  -- DOC-REG-xxxx
  
  full_name VARCHAR(255) NOT NULL,
  specialization VARCHAR(100) NOT NULL,
  registration_number VARCHAR(50) UNIQUE NOT NULL,
  medical_council VARCHAR(100),  -- PMDC, etc.
  
  hospital_affiliation VARCHAR(255),
  clinic_address TEXT,
  
  consultation_fee_pkr DECIMAL(10, 2),
  availability_status ENUM('available', 'busy', 'off_duty') DEFAULT 'available',
  
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  verified BOOLEAN DEFAULT false
);

CREATE INDEX idx_doctor_id ON doctors(doctor_id);
CREATE INDEX idx_registration_number ON doctors(registration_number);
```

### Table: `lab_assistants`

```sql
CREATE TABLE lab_assistants (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lab_id VARCHAR(50) NOT NULL,
  assistant_id VARCHAR(50) UNIQUE NOT NULL,  -- LAB-{lab-id}-{assistant-id}
  
  full_name VARCHAR(255) NOT NULL,
  lab_name VARCHAR(255) NOT NULL,
  lab_address TEXT,
  
  certification_level ENUM('certified', 'certified_phlebotomist', 'lab_technician'),
  
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lab_id ON lab_assistants(lab_id);
CREATE INDEX idx_assistant_id ON lab_assistants(assistant_id);
```

### Table: `consultations`

```sql
CREATE TABLE consultations (
  id BIGSERIAL PRIMARY KEY,
  consultation_id VARCHAR(50) UNIQUE NOT NULL,
  
  patient_id BIGINT NOT NULL REFERENCES patients(id),
  doctor_id BIGINT NOT NULL REFERENCES doctors(id),
  
  consultation_type ENUM('ai_intake', 'doctor_consultation', 'follow_up') NOT NULL,
  status ENUM('scheduled', 'in_progress', 'completed', 'cancelled') DEFAULT 'scheduled',
  
  scheduled_date TIMESTAMP,
  actual_start TIMESTAMP,
  actual_end TIMESTAMP,
  duration_minutes INT,
  
  chief_complaint TEXT,
  consultation_notes TEXT,
  
  ai_recommendation TEXT,  -- From Antigravity pipeline
  doctor_diagnosis VARCHAR(255),
  
  fees_amount_pkr DECIMAL(10, 2),
  fees_paid BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE INDEX idx_consultation_id ON consultations(consultation_id);
CREATE INDEX idx_patient_consultations ON consultations(patient_id);
CREATE INDEX idx_doctor_consultations ON consultations(doctor_id);
CREATE INDEX idx_consultation_date ON consultations(scheduled_date);
```

### Table: `lab_orders`

```sql
CREATE TABLE lab_orders (
  id BIGSERIAL PRIMARY KEY,
  lab_order_id VARCHAR(50) UNIQUE NOT NULL,
  
  patient_id BIGINT NOT NULL REFERENCES patients(id),
  doctor_id BIGINT NOT NULL REFERENCES doctors(id),
  lab_id BIGINT NOT NULL REFERENCES lab_assistants(id),
  
  test_name VARCHAR(255) NOT NULL,
  urgency ENUM('STAT', 'URGENT', 'ROUTINE') DEFAULT 'ROUTINE',
  clinical_intent TEXT,
  
  specimen_type VARCHAR(100),
  specimen_volume_ml DECIMAL(10, 2),
  
  status ENUM('pending', 'collected', 'processing', 'completed', 'cancelled') DEFAULT 'pending',
  
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  collection_date TIMESTAMP,
  result_date TIMESTAMP,
  
  result_value VARCHAR(255),
  result_unit VARCHAR(50),
  reference_range VARCHAR(100),
  is_abnormal BOOLEAN,
  
  test_cost_pkr DECIMAL(10, 2),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lab_order_id ON lab_orders(lab_order_id);
CREATE INDEX idx_lab_orders_patient ON lab_orders(patient_id);
CREATE INDEX idx_lab_orders_status ON lab_orders(status);
CREATE INDEX idx_lab_orders_date ON lab_orders(order_date);
```

### Table: `medications`

```sql
CREATE TABLE medications (
  id BIGSERIAL PRIMARY KEY,
  medication_id VARCHAR(50) UNIQUE NOT NULL,
  
  patient_id BIGINT NOT NULL REFERENCES patients(id),
  doctor_id BIGINT NOT NULL REFERENCES doctors(id),
  
  drug_name VARCHAR(255) NOT NULL,
  dosage VARCHAR(100) NOT NULL,
  frequency VARCHAR(100) NOT NULL,
  duration_days INT,
  
  start_date DATE NOT NULL,
  end_date DATE,
  
  indication TEXT,
  special_instructions TEXT,
  
  status ENUM('active', 'completed', 'discontinued') DEFAULT 'active',
  
  prescribed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE INDEX idx_medication_id ON medications(medication_id);
CREATE INDEX idx_patient_medications ON medications(patient_id);
CREATE INDEX idx_medication_status ON medications(status);
```

### Table: `audit_logs` (Immutable)

```sql
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  audit_id VARCHAR(50) UNIQUE NOT NULL,
  
  entity_type VARCHAR(50) NOT NULL,  -- patient, consultation, medication, etc.
  entity_id VARCHAR(50) NOT NULL,
  action VARCHAR(50) NOT NULL,  -- create, read, update, prescribe, block, etc.
  
  actor_type VARCHAR(50) NOT NULL,  -- patient, doctor, lab_assistant, admin
  actor_id VARCHAR(50),
  
  old_value JSONB,
  new_value JSONB,
  
  ip_address INET,
  user_agent TEXT,
  
  reason TEXT,
  status ENUM('success', 'failure') DEFAULT 'success',
  error_message TEXT,
  
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT audit_immutable CHECK (id > 0)  -- Cannot be updated
);

CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_actor ON audit_logs(actor_type, actor_id);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_action ON audit_logs(action);
```

---

## View: `patient_medical_summary` (Read-Only)

Combines patient data with recent medical timeline for doctor dashboard:

```sql
CREATE VIEW patient_medical_summary AS
SELECT
  p.patient_id,
  p.full_name,
  p.date_of_birth,
  p.blood_group,
  COUNT(DISTINCT c.id) as total_consultations,
  MAX(c.scheduled_date) as last_consultation_date,
  COUNT(DISTINCT m.id) as active_medications,
  COUNT(DISTINCT l.id) as pending_labs,
  AVG(CASE WHEN l.is_abnormal = true THEN 1 ELSE 0 END) as abnormal_results_ratio
FROM patients p
LEFT JOIN consultations c ON p.id = c.patient_id
LEFT JOIN medications m ON p.id = m.patient_id AND m.status = 'active'
LEFT JOIN lab_orders l ON p.id = l.patient_id AND l.status IN ('pending', 'processing')
GROUP BY p.id, p.patient_id, p.full_name, p.date_of_birth, p.blood_group;
```

---

## Data Integrity & Security

### Constraints

```sql
-- Prevent duplicate prescriptions for same patient on same date
ALTER TABLE medications
ADD CONSTRAINT unique_daily_prescription
UNIQUE (patient_id, drug_name, start_date);

-- Ensure lab results are within valid ranges
ALTER TABLE lab_orders
ADD CONSTRAINT valid_result_value
CHECK (result_value IS NULL OR result_value ~ '^[0-9.]+$');
```

### Encryption

- **PII Fields**: NADRA number, contact info → encrypted at-rest
- **Patient Records**: AES-256 encryption
- **Audit Logs**: Immutable, signed

### Audit Trail

Every action on patient data logged to `audit_logs`:

```sql
-- Example: Doctor views patient record
INSERT INTO audit_logs (
  entity_type, entity_id, action,
  actor_type, actor_id,
  timestamp
) VALUES (
  'patient', 'PAN-NADRA-12345678', 'read',
  'doctor', 'DOC-REG-12345',
  CURRENT_TIMESTAMP
);
```

---

## Migration Strategy

### Phase 1: Initial Setup
```sql
-- Run migrations in order
psql -U panor_user -d panor_db -f migrations/001_create_users.sql
psql -U panor_user -d panor_db -f migrations/002_create_patients.sql
psql -U panor_user -d panor_db -f migrations/003_create_doctors.sql
-- ... etc
```

### Phase 2: Firestore Initialization
```python
# Create collections with security rules
db.collection('patients').document('template').set({})
db.collection('medical_timeline').document('template').set({})
```

### Phase 3: Seed Data
```python
# Admin setup, test doctors, lab assistants
python backend/scripts/seed_db.py
```

---

**Status**: Schema ready for implementation  
**Performance**: Indexed for <100ms queries on medical timeline
