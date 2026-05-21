# PANOR Security & Compliance Framework

## Overview

PANOR handles sensitive medical data in Pakistan with strict compliance requirements:
- Medical Data Protection (MDP) standards
- NADRA integration security
- Multi-layer encryption
- Comprehensive audit trails
- Role-based access control (RBAC)
- Emergency override protocols

---

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│           PANOR SECURITY LAYERS                         │
├─────────────────────────────────────────────────────────┤
│ Layer 1: Client-Side (Flutter App)                      │
│   ├─ Local data encryption (AES-256)                    │
│   ├─ Secure storage via platform keychain               │
│   ├─ Certificate pinning for API calls                  │
│   └─ Biometric + PIN authentication                     │
├─────────────────────────────────────────────────────────┤
│ Layer 2: Transport (Network)                            │
│   ├─ TLS 1.3 for all API calls                         │
│   ├─ Certificate pinning (prevent MITM)                 │
│   ├─ API key rotation every 90 days                     │
│   └─ Rate limiting (100 req/min per user)               │
├─────────────────────────────────────────────────────────┤
│ Layer 3: Application (API Gateway)                      │
│   ├─ OAuth 2.0 + JWT authentication                     │
│   ├─ MFA verification (SMS/Email/Authenticator)        │
│   ├─ Input validation & sanitization                    │
│   └─ SQL injection prevention (parameterized queries)   │
├─────────────────────────────────────────────────────────┤
│ Layer 4: Data (Database)                                │
│   ├─ AES-256 encryption at-rest                         │
│   ├─ Field-level encryption for PII                     │
│   ├─ Append-only medical records (immutable)            │
│   ├─ Firestore security rules (role-based)              │
│   └─ PostgreSQL row-level security (RLS)                │
├─────────────────────────────────────────────────────────┤
│ Layer 5: Audit & Monitoring                             │
│   ├─ Immutable event logs                               │
│   ├─ Real-time alerting (suspicious activity)           │
│   ├─ Monthly compliance reports                         │
│   └─ SIEM integration (security monitoring)             │
└─────────────────────────────────────────────────────────┘
```

---

## Authentication & Authorization

### Multi-Factor Authentication (MFA)

```
┌─────────────────────────────────────────────┐
│ User submits: Email + Password              │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│ Step 1: Verify credentials                  │
│ Hash comparison, rate limiting              │
└──────────────────┬──────────────────────────┘
                   │
          ┌────────┴────────┐
          │                 │
    ┌─────▼─────┐    ┌──────▼──────┐
    │ SMS OTP   │    │ Authenticator│
    │ (Primary) │    │ (Backup)     │
    └─────┬─────┘    └──────┬──────┘
          │                 │
    ┌─────▼─────────────────▼─────┐
    │ User enters 6-digit code     │
    └─────┬───────────────────────┘
          │
    ┌─────▼──────────────────────┐
    │ Verify OTP (30s expiry)    │
    │ Rate limit: 5 attempts     │
    └─────┬──────────────────────┘
          │
    ┌─────▼──────────────────────┐
    │ Generate JWT Token         │
    │ Exp: 2 hours               │
    │ Refresh: 7 days            │
    └─────┬──────────────────────┘
          │
    ┌─────▼──────────────────────┐
    │ User authenticated         │
    │ Return token + user data   │
    └────────────────────────────┘
```

### Role-Based Access Control (RBAC)

```yaml
Roles:
  patient:
    permissions:
      - read_own_medical_history
      - create_consultation_request
      - upload_medical_records
      - view_own_medications
      - book_appointments
    restrictions:
      - cannot_view_other_patients
      - cannot_modify_records
  
  doctor:
    permissions:
      - read_patient_complete_record
      - create_diagnosis
      - order_laboratory_tests
      - prescribe_medications
      - override_drug_safety_warn  # With signature
    restrictions:
      - cannot_override_drug_safety_block
      - cannot_modify_patient_demographics
  
  lab_assistant:
    permissions:
      - view_assigned_lab_orders
      - input_test_results
      - view_specimen_handling_guidelines
    restrictions:
      - cannot_view_patient_demographics
      - cannot_view_medical_history
  
  admin:
    permissions:
      - read_all_data
      - modify_system_settings
      - manage_user_accounts
      - set_pricing
      - generate_reports
      - view_audit_logs
    restrictions:
      - cannot_modify_patient_medical_records
      - cannot_prescribe_medications
```

---

## Encryption Strategy

### At-Rest Encryption

```python
# backend/app/core/encryption.py

from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2
import os

class EncryptionService:
    """AES-256 encryption for sensitive data"""
    
    def __init__(self, master_key: str):
        # Derive encryption key from master key
        salt = os.environ.get('ENCRYPTION_SALT', b'fixed_salt_32b')
        kdf = PBKDF2(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(master_key.encode()))
        self.cipher = Fernet(key)
    
    def encrypt_field(self, value: str) -> str:
        """Encrypt sensitive field"""
        return self.cipher.encrypt(value.encode()).decode()
    
    def decrypt_field(self, encrypted_value: str) -> str:
        """Decrypt sensitive field"""
        return self.cipher.decrypt(encrypted_value.encode()).decode()

# Usage in SQLAlchemy model
class Patient(Base):
    __tablename__ = 'patients'
    
    cnic_number = Column(String, nullable=False)  # Encrypted
    
    @property
    def cnic_number_decrypted(self):
        return encryption_service.decrypt_field(self.cnic_number)
    
    @cnic_number_decrypted.setter
    def cnic_number_decrypted(self, value: str):
        self.cnic_number = encryption_service.encrypt_field(value)
```

### Field-Level Encryption (PII)

```sql
-- PostgreSQL: Encrypt sensitive fields
CREATE TABLE patients (
  id BIGSERIAL PRIMARY KEY,
  
  -- Encrypted fields
  cnic_number VARCHAR(255) NOT NULL,  -- Encrypted: AES-256
  phone_primary VARCHAR(255) NOT NULL,  -- Encrypted
  address VARCHAR(255),  -- Encrypted
  
  -- Unencrypted fields (safe)
  patient_id VARCHAR(50),  -- NADRA reference (pseudonym)
  gender VARCHAR(10),
  blood_group VARCHAR(10)
);

-- Query encrypted data (encrypted field to encrypted parameter)
SELECT * FROM patients 
WHERE cnic_number = pgcrypto_encrypt('12345-6789012-3', 'key');
```

### In-Transit Encryption (TLS 1.3)

```python
# backend/app/core/config.py

import ssl

SSL_CONTEXT = ssl.SSLContext(ssl.PROTOCOL_TLSv1_3)
SSL_CONTEXT.load_cert_chain(
    certfile="certificates/server.crt",
    keyfile="certificates/server.key",
    password="cert_password"
)

# Uvicorn server configuration
# uvicorn main:app --ssl-keyfile=certificates/server.key \
#   --ssl-certfile=certificates/server.crt --ssl-version=TLS13
```

---

## Audit Logging

### Immutable Audit Trail

```python
# backend/app/services/audit_service.py

from datetime import datetime
import uuid

class AuditService:
    """Immutable audit logging for medical data access"""
    
    async def log_event(
        self,
        entity_type: str,  # patient, consultation, medication
        entity_id: str,
        action: str,  # read, create, update, delete, prescribe, block
        actor_type: str,  # patient, doctor, lab_assistant, admin
        actor_id: str,
        old_value: dict = None,
        new_value: dict = None,
        ip_address: str = None,
        reason: str = None,
        status: str = "success",
        error_message: str = None
    ):
        """Log immutable audit event"""
        
        audit_event = {
            "audit_id": str(uuid.uuid4()),
            "entity_type": entity_type,
            "entity_id": entity_id,
            "action": action,
            "actor_type": actor_type,
            "actor_id": actor_id,
            "old_value": old_value,
            "new_value": new_value,
            "ip_address": ip_address,
            "reason": reason,
            "status": status,
            "error_message": error_message,
            "timestamp": datetime.utcnow().isoformat(),
        }
        
        # Write to immutable audit log (append-only)
        await self.db.execute(
            """INSERT INTO audit_logs 
            (audit_id, entity_type, entity_id, action, actor_type, 
             actor_id, old_value, new_value, ip_address, reason, 
             status, error_message, timestamp)
            VALUES (:audit_id, :entity_type, :entity_id, :action, 
                    :actor_type, :actor_id, :old_value, :new_value, 
                    :ip_address, :reason, :status, :error_message, 
                    :timestamp)""",
            audit_event
        )

# Usage example: Doctor views patient record
await audit_service.log_event(
    entity_type="patient",
    entity_id="PAN-NADRA-12345678",
    action="read",
    actor_type="doctor",
    actor_id="DOC-REG-12345",
    ip_address="203.48.X.X",
    reason="Patient consultation review"
)

# Usage example: Drug safety blocks prescription
await audit_service.log_event(
    entity_type="medication",
    entity_id="MED-UUID-12345",
    action="prescribe_blocked",
    actor_type="ai_agent",
    actor_id="A3_DRUG_SAFETY",
    reason="Major drug-drug interaction detected",
    status="blocked",
    new_value={"decision": "BLOCK", "rationale": "Warfarin + Aspirin"}
)
```

---

## Compliance & Regulatory

### Medical Data Protection (MDP) Compliance

```markdown
# Data Retention Policy

## Patient Records
- **Active Patients**: Keep for duration of treatment + 5 years
- **Inactive Patients**: Archive after 5 years of no activity
- **Deletion**: Only upon explicit patient request + legal review

## Audit Logs
- **Retention**: Minimum 7 years (regulatory requirement)
- **Access**: Only authorized personnel (doctors, admins)
- **Immutable**: Cannot be modified or deleted

## Consent Management
- Written consent before any data sharing
- Explicit opt-in for AI processing
- Right to withdraw consent (stops future processing only)
- Data minimization (collect only necessary info)

## Cross-Border Data Transfer
- Pakistan data must stay in Pakistan servers (PDPA compliance)
- International transfer only with explicit patient consent
- Data Processing Agreement (DPA) signed
```

### NADRA Integration Security

```python
# backend/app/services/nadra_service.py

class NADRAVerificationService:
    """Secure integration with NADRA database"""
    
    async def verify_patient_identity(
        self,
        cnic: str,
        name: str,
        dob: str
    ) -> bool:
        """
        Verify patient identity against NADRA database
        Called only during initial registration
        Returns: True if verified, False otherwise
        """
        
        # 1. Validate CNIC format
        if not self._validate_cnic_format(cnic):
            raise ValueError("Invalid CNIC format")
        
        # 2. Hash CNIC for secure transmission
        hashed_cnic = hashlib.sha256(cnic.encode()).hexdigest()
        
        # 3. Call NADRA API with encrypted payload
        payload = {
            "cnic_hash": hashed_cnic,
            "verification_timestamp": datetime.utcnow().isoformat(),
            "request_id": str(uuid.uuid4())
        }
        
        # 4. Use mTLS for NADRA communication
        async with aiohttp.ClientSession(
            connector=aiohttp.TCPConnector(ssl=self.ssl_context)
        ) as session:
            async with session.post(
                "https://nadra-api.gov.pk/verify",
                json=payload,
                headers={"Authorization": f"Bearer {self.nadra_token}"}
            ) as resp:
                result = await resp.json()
        
        # 5. Verify signature of response
        if not self._verify_nadra_signature(result):
            raise SecurityError("NADRA response signature invalid")
        
        return result["verified"]
    
    def _validate_cnic_format(self, cnic: str) -> bool:
        """CNIC format: 12345-6789012-3"""
        return bool(re.match(r'^\d{5}-\d{7}-\d{1}$', cnic))
    
    def _verify_nadra_signature(self, response: dict) -> bool:
        """Verify NADRA API response signature"""
        # Implementation depends on NADRA's signature scheme
        # Typically: HMAC-SHA256 with shared secret
        pass
```

---

## Incident Response Protocol

### Security Incident Classification

```
CRITICAL (Red)
├─ Data breach (patient records exposed)
├─ Ransomware attack
├─ Unauthorized medical record access
├─ AI agent generating harmful diagnosis
└─ System-wide outage

→ Action: Immediate incident response team activation
→ Notify: Patients, regulatory authorities, legal team
→ Containment: <1 hour
→ Communication: <4 hours to affected parties

HIGH (Orange)
├─ Unauthorized access attempt (multiple failures)
├─ MFA bypass attempt
├─ Database corruption detected
└─ External API compromise

→ Action: Incident investigation & mitigation
→ Notify: Internal stakeholders
→ Containment: <4 hours
→ Communication: Transparent update

MEDIUM (Yellow)
├─ Single failed authentication
├─ Application error (non-critical)
├─ Performance degradation
└─ Audit log inconsistency

→ Action: Root cause analysis
→ Notify: Engineering team
→ Resolution: <24 hours

LOW (Green)
├─ Normal operational alerts
├─ Informational security events
└─ System maintenance

→ Action: Routine monitoring
→ Resolution: Scheduled maintenance
```

---

## Testing & Verification

### Security Testing Checklist

- [ ] **Authentication**
  - [ ] Test invalid credentials (brute force protection)
  - [ ] Test MFA bypass attempts
  - [ ] Test JWT token expiration
  - [ ] Test token refresh mechanism

- [ ] **Authorization**
  - [ ] Verify patient cannot see other patient records
  - [ ] Verify lab assistant cannot prescribe medications
  - [ ] Verify normal doctor cannot override drug safety blocks
  - [ ] Verify admin privileges controlled

- [ ] **Encryption**
  - [ ] Verify sensitive data encrypted at-rest
  - [ ] Verify TLS 1.3 for all API calls
  - [ ] Verify encryption keys rotated
  - [ ] Verify decryption of stored data successful

- [ ] **Injection**
  - [ ] Test SQL injection attempts
  - [ ] Test XSS payload injection
  - [ ] Test CSRF token protection
  - [ ] Test command injection

- [ ] **Data Protection**
  - [ ] Verify audit logs immutable
  - [ ] Verify no data in logs
  - [ ] Verify GDPR compliance (right to deletion)
  - [ ] Verify data minimization

---

**Status**: Security framework ready for implementation  
**Compliance**: PDPA, MDP, medical ethics aligned  
**Audit**: Every action logged and traceable
