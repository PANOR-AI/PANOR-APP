# PANOR Antigravity Agent Execution Protocol

## Overview
This document defines the precise execution flow for PANOR's 7-agent Antigravity pipeline. Each agent operates within strict time constraints, verification gates, and hard-stop conditions.

---

## Execution Flow Diagram

```
START: Patient Input (Voice/Text/Image)
  │
  ├─→ [A1] INTAKE MULTIMODAL AGENT (2s timeout)
  │     └─→ Output: StructuredSymptomObject
  │
  ├─→ [A2] CLINICAL REASONING (2.5s timeout)
  │     ├─→ Query: patient_complete_history
  │     ├─→ Detect: emergency_flag (RED/YELLOW/GREEN)
  │     └─→ Output: differential_diagnosis, risk_level
  │
  ├─→ [EMERGENCY GATE]
  │     IF emergency_flag == RED:
  │       ├─→ STOP_PIPELINE
  │       ├─→ ALERT_DOCTOR_IMMEDIATE
  │       ├─→ ALERT_PATIENT
  │       └─→ LOG_EMERGENCY_EVENT
  │
  ├─→ [A3] DRUG SAFETY VALIDATOR (1.5s timeout)
  │     └─→ Output: ALLOW|WARN|BLOCK
  │
  ├─→ [DRUG_SAFETY_GATE]
  │     IF decision == BLOCK:
  │       ├─→ HOLD_PIPELINE
  │       ├─→ NOTIFY_DOCTOR
  │       └─→ SUGGEST_ALTERNATIVES
  │
  ├─→ [A4] LAB COORDINATION (1.5s timeout)
  │     └─→ Output: lab_test_plan, urgency, clinical_intent
  │
  ├─→ [A5] EPIDEMIOLOGY AGENT (1s timeout, background)
  │     └─→ Output: cluster_alerts, geo_heatmaps (async)
  │
  ├─→ [A6] FOLLOW-UP AGENT (1s timeout)
  │     └─→ Output: reminders, compliance_score
  │
  ├─→ [A7] VERIFICATION GATE (2s timeout)
  │     ├─→ Score: confidence_score (0-1.0)
  │     ├─→ Generate: SOAP_note
  │     └─→ Decide: HOLD|REVIEW|APPROVE
  │
  ├─→ [CONFIDENCE GATE]
  │     IF confidence < 0.7: HOLD (requires doctor signature)
  │     IF 0.7-0.9: REVIEW (flag for verification)
  │     IF >0.9: APPROVE (auto-commit)
  │
  └─→ [TRANSACTION COMMIT]
        ├─→ Write to Firestore (append-only)
        ├─→ Write to PostgreSQL (structured)
        ├─→ Write Audit Log (immutable)
        └─→ NOTIFY_DOCTOR + NOTIFY_PATIENT
```

---

## Agent Timeout Strategy

| Agent | Timeout (ms) | Role | Hard-Fail Behavior |
|-------|------------|------|-------------------|
| A1 | 2000 | Intake | Use cached result or cached_previous_input |
| A2 | 2500 | Reasoning | HOLD (requires doctor override) |
| A3 | 1500 | Drug Safety | Default to WARN (require doctor verification) |
| A4 | 1500 | Lab | Minimal lab plan (only critical tests) |
| A5 | 1000 | Epidemiology | Skip (background only) |
| A6 | 1000 | Follow-up | Skip (non-critical) |
| A7 | 2000 | Verification | Confidence = 0.5 (HOLD) |

**Total Pipeline Max**: 10,000 ms (10 seconds)

---

## Verification Gates (Non-Bypassable)

### Gate 1: Emergency Detector
```
Condition: emergency_flag == RED
Trigger: Any of:
  - Unconscious / unresponsive
  - Severe respiratory distress (RR >30, SpO2 <88%)
  - Severe chest pain / suspected MI
  - Severe uncontrolled bleeding
  - Signs of anaphylaxis
  - Suspected septic shock

Action:
  1. IMMEDIATELY_PAUSE_PIPELINE
  2. ALERT_EMERGENCY_DOCTOR (within 5 seconds)
  3. ALERT_PATIENT (SMS + App notification)
  4. REROUTE_TO_EMERGENCY_CENTER
  5. LOG_AUDIT_TRAIL (EMERGENCY_PRIORITY tag)

Override: NOT POSSIBLE (cannot be bypassed)
```

### Gate 2: Drug Safety Block
```
Condition: drug_safety_decision == BLOCK
Triggers:
  - Known allergy to proposed medication
  - Major drug-drug interaction
  - Contraindication vs. patient disease
  - Unsafe dosage (toxicity risk)

Action:
  1. HOLD_PRESCRIPTION
  2. SUGGEST_SAFE_ALTERNATIVES
  3. NOTIFY_DOCTOR
  4. AWAIT_DOCTOR_OVERRIDE (requires MFA + signature)

Override: ONLY by doctor with:
  - Multi-factor authentication (SMS OTP + biometric)
  - Digital signature
  - Clinical justification
  - Full audit trail logged
```

### Gate 3: Confidence Threshold
```
Score: 0.0 - 1.0 (from A7 Verification Agent)

IF confidence < 0.7:
  Action: HOLD
  Reason: Insufficient clinical certainty
  Override: Doctor review + approval required

IF confidence 0.7-0.9:
  Action: REVIEW
  Reason: Moderate certainty, flag for doctor verification
  Auto-Commit: NO (awaits doctor action)

IF confidence > 0.9:
  Action: APPROVE
  Reason: High clinical certainty
  Auto-Commit: YES (write to patient record)
```

---

## Hard-Stop Conditions (Pipeline Terminator)

These conditions IMMEDIATELY halt the entire pipeline and route to human review:

1. **Emergency_flag == RED** → Emergency protocol
2. **Drug_safety == BLOCK** → Hold prescription
3. **Confidence < 0.5** → Critical hold (doctor required)
4. **Patient_data_inconsistency** → Investigate discrepancy
5. **Agent_timeout_cascade** → Multiple agent timeouts (≥3)
6. **Gemini_API_failure** → Fall back to cached_clinical_reasoning

---

## Agent Dependency Graph

```
A1 (INTAKE)
  └─→ A2 (CLINICAL REASONING)
       ├─→ A3 (DRUG SAFETY)
       ├─→ A4 (LAB COORDINATION)
       ├─→ A6 (FOLLOW-UP)
       └─→ A7 (VERIFICATION) ← depends on A2, A3, A4

A5 (EPIDEMIOLOGY) runs in parallel (background, non-blocking)
```

---

## Fallback & Graceful Degradation

### Agent Timeout Fallback
```python
try:
    result = await agent.execute(timeout=agent.timeout_ms)
except asyncio.TimeoutError:
    result = use_fallback_strategy(agent_id)
    log_timeout_event(agent_id, fallback_strategy)
```

### Fallback Strategies by Agent

| Agent | Fallback |
|-------|----------|
| A1 | Use cached previous input + ask patient clarification |
| A2 | Use statistical diagnosis based on symptom pattern |
| A3 | Default to WARN (require doctor acknowledgment) |
| A4 | Generate minimal lab plan (only critical tests) |
| A5 | Skip (background agent, non-blocking) |
| A6 | Use default follow-up template |
| A7 | Score confidence as 0.5 (HOLD status) |

---

## Execution Example: Patient with Fever

```
INPUT: Patient (Urdu): "آج 3 دن سے بخار ہے، سردی لگ رہی ہے"
       Translation: "I've had fever for 3 days, feeling chills"

[A1] INTAKE MULTIMODAL AGENT (1.2s)
     ↓
     Output: {
       "language": "urdu",
       "symptoms": [{"name": "fever", "duration_days": 3, "severity": 6}],
       "current_medications": ["Paracetamol 500mg"],
       "urgency_flag": "yellow"
     }

[A2] CLINICAL REASONING (1.8s)
     Query: Patient history (diabetes, hypertension)
     ↓
     Output: {
       "emergency_flag": "GREEN",
       "differential": [
         {"diagnosis": "Viral fever", "confidence": 0.70},
         {"diagnosis": "Dengue fever", "confidence": 0.55},
         {"diagnosis": "Typhoid", "confidence": 0.40}
       ],
       "risk_level": 0.35
     }

[A3] DRUG SAFETY (0.9s)
     Check: Paracetamol interactions with diabetes meds
     ↓
     Output: {
       "decision": "WARN",
       "rationale": "Max dosage with Metformin caution"
     }

[A4] LAB COORDINATION (1.1s)
     ↓
     Output: {
       "tests": [
         {"name": "CBC", "urgency": "ROUTINE"},
         {"name": "Dengue NS1", "urgency": "URGENT"},
         {"name": "Widal test", "urgency": "ROUTINE"}
       ]
     }

[A6] FOLLOW-UP (0.7s)
     ↓
     Output: {
       "reminders": ["Take Paracetamol every 8 hours"]
     }

[A7] VERIFICATION (1.5s)
     ↓
     Output: {
       "confidence": 0.78,
       "approval": "REVIEW",
       "soap": "..."
     }

[CONFIDENCE GATE] → Confidence 0.78 → REVIEW status
→ Notify doctor for verification before commit

RESULT: Doctor reviews SOAP, approves, writes to patient record
```

---

## Implementation Checklist

- [ ] Orchestrator timeout management
- [ ] Emergency detection hardcoded
- [ ] Drug safety blocker non-overridable
- [ ] Confidence threshold gates
- [ ] Fallback strategies
- [ ] Audit logging for all decisions
- [ ] Doctor alert system
- [ ] Patient notification system
- [ ] Transaction commit consistency
- [ ] Performance monitoring & alerting
