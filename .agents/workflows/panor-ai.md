---
description: Panor workflow
---

WINDOWS_EXECUTION_PROTOCOL: PANOR_HEALTHCARE_SYSTEM_V2

MODE: STRICT_AGENTIC_ONLY
ALLOW_MANUAL_OVERRIDE: FALSE
TRACE_LEVEL: FULL
AUDIT_MODE: IMMUTABLE

------------------------------------------------------------

1. SYSTEM ENTRY POINT

------------------------------------------------------------

ON_EVENT:

- patient_login
- doctor_login
- lab_login
- admin_login
- new_medical_input
- emergency_signal_detected

EXECUTE:
  STEP_1 → AUTHENTICATION_LAYER
  STEP_2 → IDENTITY_RESOLUTION
  STEP_3 → AGENT_ROUTING_ENGINE

------------------------------------------------------------
1. IDENTITY RESOLUTION (CRITICAL LAYER)

------------------------------------------------------------

AGENT: Agent_00_Identity_Guardian

IF new_user:
  VERIFY:
    - CNIC validation (NADRA linkage required)
    - biometric hash match
    - phone/email OTP verification

  GENERATE:
    P_ID = "PAK-HEALTH-XXXXXXXXXXXX"

  LOCK_FIELDS:
    - CNIC
    - DOB
    - biological_sex

  CREATE:
    - patient_master_record (immutable)
    - empty_medical_timeline (append-only)

ELSE:
  FETCH patient_master_record USING P_ID

OUTPUT:
  identity_verified = TRUE

------------------------------------------------------------
1. MULTIMODAL INPUT PIPELINE

------------------------------------------------------------

AGENT: Agent_01_Intake_Intelligence

INPUT_CHANNELS:

- voice (Urdu / Sindhi / English / Roman Urdu)
- image (camera scan)
- PDF upload
- manual text

PROCESS:

  1. detect_language()
  2. speech_to_text_if_required()
  3. OCR_if_image_or_pdf()
  4. extract_clinical_entities()
  5. normalize_to_FHIR_LITE()

OUTPUT:
  structured_medical_event

------------------------------------------------------------
1. CLINICAL REASONING ENGINE

------------------------------------------------------------

AGENT: Agent_02_Clinical_Reasoning

INPUT:
  structured_medical_event + patient_history

PROCESS:

- analyze_symptoms()
- generate_differential_diagnosis()
- compute_risk_score()

IF risk_score >= HIGH:
  TRIGGER emergency_protocol

OUTPUT:
  clinical_summary
  risk_level = [GREEN | YELLOW | RED]
  reasoning_trace

------------------------------------------------------------
1. DRUG SAFETY ENGINE

------------------------------------------------------------

AGENT: Agent_03_Drug_Safety_Guardian

INPUT:
  prescriptions OR medication_query

PROCESS:

- check_drug_interactions(patient_history)
- validate_dosage_rules()
- check_contraindications()

IF conflict_detected:
  RETURN:
    status = BLOCK
    safe_alternative = TRUE
    explanation = medical_reason

ELSE:
  status = APPROVE

------------------------------------------------------------
1. LAB ORCHESTRATION ENGINE

------------------------------------------------------------

AGENT: Agent_04_Laboratory_Coordination

INPUT:
  doctor_lab_order OR emergency_flag

PROCESS:

- classify_urgency(STAT / URGENT / ROUTINE)
- attach_clinical_intent()
- assign_lab_workflow()

OUTPUT:
  structured_lab_order
  patient_prep_instructions
  escalation_thresholds

------------------------------------------------------------
1. FOLLOW-UP & MONITORING ENGINE

------------------------------------------------------------

AGENT: Agent_06_FollowUp_Monitoring

INPUT:
  prescription + lab_results + consultation_completion

PROCESS:

- schedule_followup()
- generate_medication_reminders()
- compute_adherence_score()

OUTPUT:
  notification_plan
  followup_schedule

------------------------------------------------------------
1. FINAL VERIFICATION ENGINE

------------------------------------------------------------

AGENT: Agent_07_Verification_Safety_SOAP

INPUT:
  outputs_from_all_agents

PROCESS:

- validate_consistency()
- detect_conflicts()
- generate_SOAP_note()
- assign_confidence_scores()

IF inconsistency_detected:
  STATUS = HOLD_FOR_REVIEW
ELSE:
  STATUS = APPROVED

OUTPUT:
  final_clinical_packet
  SOAP_note
  audit_log_id

------------------------------------------------------------
1. IMMUTABLE DATA WRITE LAYER

------------------------------------------------------------

WRITE_MODE: APPEND_ONLY

STORE:

- patient_timeline_entry
- agent_outputs
- reasoning_traces
- audit_logs

ENFORCE:

- no_update_allowed
- no_delete_allowed
- cryptographic_hash_chain_enabled

------------------------------------------------------------
1. ROLE-BASED OUTPUT ROUTING

------------------------------------------------------------

IF role == PATIENT:
  DISPLAY:
    - simplified_medical_history
    - medications + reminders
    - AI health assistant chat

IF role == DOCTOR:
  DISPLAY:
    - clinical_summary
    - differential_diagnosis
    - lab_orders
    - prescription_tool
    - timeline_view

IF role == LAB:
  DISPLAY:
    - lab_requests_queue
    - urgency_tags
    - result_submission_interface

IF role == ADMIN:
  DISPLAY:
    - analytics_dashboard
    - pricing_controls
    - epidemiology_heatmaps
    - audit_logs

------------------------------------------------------------
1. EMERGENCY OVERRIDE PROTOCOL

------------------------------------------------------------

IF Agent_02.risk_level == RED:

EXECUTE IMMEDIATELY:

- suspend_non_critical_processes()
- notify_doctor_dashboard()
- generate_STAT_lab_orders()
- alert_nearest_hospital_network()
- lock_audit_trail()

REQUIRE:

- doctor_biometric_auth for any override

------------------------------------------------------------
1. PERFORMANCE GUARANTEE LAYER

------------------------------------------------------------

TARGETS:

- intake_processing < 8 seconds
- emergency_detection < 2 seconds
- SOAP_generation < 3 seconds
- dashboard_load < 3 seconds

------------------------------------------------------------

END OF PROTOCOL
------------------------------------------------------------
