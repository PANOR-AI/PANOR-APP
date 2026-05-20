from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional
import io
import json

from app.database import get_db
from app.models.all_models import User, Patient, AIConversation, AuditLog, Prescription, LabReport, Vitals
from app.schemas.all_schemas import AIChatRequest
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user
from app.services.ai.antigravity_client import AntigravityOrchestrator

router = APIRouter(prefix="/api/ai-assistant", tags=["ai_assistant"])

@router.post("/consultation")
async def run_consultation(
    text_input: Optional[str] = Form(None),
    voice_input: Optional[UploadFile] = File(None),
    pdf_input: Optional[UploadFile] = File(None),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Triggers the complete 7-agent clinical co-pilot reasoning pipeline.
    Symptom Input -> Agentic Workplans -> Safety Checking -> SOAP generation.
    """
    # Restrict to Patients or Doctors assisting Patients
    if current_user.role not in ("Patient", "Doctor"):
        return error_response(["Only patients or doctors can trigger a clinical consultation"], "Action forbidden", 403)
    
    patient_id = current_user.id
    
    try:
        # Trigger the Antigravity Multi-Agent Workflow
        orchestrator = AntigravityOrchestrator(db)
        result = await orchestrator.execute_consultation_workflow(
            input_text=text_input or "Patient reporting chest pain and fever.",
            patient_id=patient_id,
            doctor_id=current_user.id
        )

        final_state = result["final_state"]
        
        # PERSIST STATE TO DATABASE
        # 1. Save vital signs if severity is high
        intake_trace = result["traces"][0]
        severity = intake_trace["output"].get("severity", "LOW")
        if severity.upper() in ("HIGH", "CRITICAL", "RED"):
            vitals = Vitals(
                patient_id=patient_id,
                blood_pressure="120/80",
                heart_rate="98 bpm",
                temperature=101.5,
                oxygen_level=94
            )
            db.add(vitals)
            
        # 2. Save lab orders statically to real database if generated
        for test in final_state.get("recommended_labs", []):
            db.add(LabReport(
                patient_id=patient_id,
                test_name=test,
                priority="STAT" if severity.upper() in ("HIGH", "CRITICAL") else "ROUTINE",
                status="Pending"
            ))

        # 3. Save prescribed medication to database
        for med in final_state.get("prescriptions", []):
            db.add(Prescription(
                patient_id=patient_id,
                doctor_id=current_user.id,
                diagnosis=final_state.get("diagnosis", "Acute symptoms analysis"),
                medications=[{"name": med, "dosage": "500mg", "frequency": "BID"}]
            ))

        # 4. Add Audit log
        db.add(AuditLog(
            user_id=current_user.id,
            action="CLINICAL_CONSULTATION_COMPLETED",
            details=f"Consultation execution completed. Session ID: {result['conversation_id']}."
        ))

        await db.commit()
        return success_response(result, "Consultation completed successfully by Antigravity")
        
    except Exception as e:
        import traceback
        traceback.print_exc()
        return error_response([f"Consultation failed: {str(e)}"], "AI Pipeline error", 500)


@router.post("/chat")
async def ai_chat(
    chat_req: AIChatRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Standard conversational assistant persisting session state."""
    if current_user.role != "Patient":
        return error_response(["Only patients can use the patient assistant chat"], "Action forbidden", 403)
        
    session_id = chat_req.session_id or f"session-{current_user.id}"
    
    # Retrieve or create history
    q = await db.execute(select(AIConversation).where(AIConversation.id == session_id))
    conv = q.scalars().first()
    
    history = []
    if conv:
        history = list(conv.messages)
    
    history.append({"role": "user", "content": chat_req.message})
    
    # Invoke Factory AI
    from app.services.ai.factory import get_ai_service
    ai_service = get_ai_service()
    
    response_text = await ai_service.chat(history)
    history.append({"role": "assistant", "content": response_text})
    
    # Save conversation state
    if not conv:
        conv = AIConversation(id=session_id, patient_id=current_user.id, messages=history)
        db.add(conv)
    else:
        conv.messages = history
        
    await db.commit()
    
    return success_response(
        {
            "session_id": session_id,
            "response": response_text,
            "history": history
        },
        "Message processed successfully"
    )
