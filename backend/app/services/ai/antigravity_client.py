import uuid
import time
import json
from typing import Dict, Any, List
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.services.ai.factory import get_ai_service
from app.services.ai.gemini import GeminiAIService
from app.models.all_models import AIConversation, AuditLog

# Define Schemas for the 7 Agents
class IntakeSchema(BaseModel):
    symptoms: List[str]
    severity: str
    duration: str
    urgency_score: int
    reasoning: List[str]

class ClinicalReasoningSchema(BaseModel):
    differential_diagnosis: List[str]
    primary_hypothesis: str
    confidence: float
    reasoning: List[str]

class DrugSafetySchema(BaseModel):
    is_safe: bool
    contraindications: List[str]
    warnings: List[str]
    reasoning: List[str]

class LabCoordinationSchema(BaseModel):
    recommended_tests: List[str]
    priority: str
    reasoning: List[str]

class EpidemiologySchema(BaseModel):
    outbreak_risk: str
    cluster_detected: bool
    reasoning: List[str]

class FollowUpSchema(BaseModel):
    follow_up_timeframe: str
    monitoring_flags: List[str]
    reasoning: List[str]

class SoapNoteSchema(BaseModel):
    subjective: str
    objective: str
    assessment: str
    plan: str

class VerificationSchema(BaseModel):
    hallucination_detected: bool
    final_soap_note: SoapNoteSchema
    confidence: float
    reasoning: List[str]


class AntigravityOrchestrator:
    """
    Stateful 7-Agent Orchestration using LangGraph-style workflow.
    Executes sequentially, passing state, and records exact traces to the database.
    """
    
    def __init__(self, db_session: AsyncSession):
        self.db = db_session
        self.ai: GeminiAIService = get_ai_service()

    async def _execute_agent(
        self, 
        agent_name: str, 
        system_prompt: str, 
        state: Dict[str, Any], 
        schema_type: type
    ) -> Dict[str, Any]:
        """Executes a single agent and wraps the output in the standard trace format."""
        
        result = await self.ai.run_agent(
            agent_name=agent_name,
            system_prompt=system_prompt,
            input_data=state,
            schema=schema_type
        )
        
        output_data = result["output"]
        if isinstance(output_data, dict):
            confidence = output_data.get("confidence", 0.95)
            reasoning = output_data.get("reasoning", [])
        else:
            confidence = getattr(output_data, "confidence", 0.95)
            reasoning = getattr(output_data, "reasoning", [])
            output_data = output_data.model_dump()
            
        trace = {
            "id": str(uuid.uuid4()),
            "agent": agent_name,
            "input": state.copy(),
            "output": output_data,
            "confidence": float(confidence),
            "reasoning": reasoning,
            "tool_calls": [],
            "execution_time": f"{result['execution_time']}ms"
        }
        return trace

    async def execute_consultation_workflow(self, input_text: str, patient_id: str, doctor_id: str) -> Dict[str, Any]:
        """
        Orchestrates the 7 agents in sequence, building a comprehensive state.
        """
        # Initialize Shared State
        state = {
            "patient_id": patient_id,
            "initial_complaint": input_text,
            "extracted_symptoms": [],
            "diagnosis": "",
            "recommended_labs": [],
            "prescriptions": [],
            "soap_note": {}
        }
        
        traces = []

        # 1. Intake Agent
        trace1 = await self._execute_agent(
            "Intake Agent",
            "Extract symptoms, severity, duration, and compute an urgency score (1-10).",
            {"complaint": state["initial_complaint"]},
            IntakeSchema
        )
        state["extracted_symptoms"] = trace1["output"]["symptoms"]
        traces.append(trace1)

        # 2. Clinical Reasoning Agent
        trace2 = await self._execute_agent(
            "Clinical Reasoning Agent",
            "Generate differential diagnoses based on the extracted symptoms.",
            {"symptoms": state["extracted_symptoms"]},
            ClinicalReasoningSchema
        )
        state["diagnosis"] = trace2["output"]["primary_hypothesis"]
        traces.append(trace2)

        # 3. Drug Safety Guardian
        trace3 = await self._execute_agent(
            "Drug Safety Guardian",
            "Check for contraindications. Assume standard treatments for the primary hypothesis.",
            {"diagnosis": state["diagnosis"], "symptoms": state["extracted_symptoms"]},
            DrugSafetySchema
        )
        state["prescriptions"] = ["Standard Care"] if trace3["output"]["is_safe"] else ["Requires Review"]
        traces.append(trace3)

        # 4. Lab Coordination Agent
        trace4 = await self._execute_agent(
            "Laboratory Coordination Agent",
            "Recommend required laboratory tests based on the diagnosis and symptoms.",
            {"diagnosis": state["diagnosis"]},
            LabCoordinationSchema
        )
        state["recommended_labs"] = trace4["output"]["recommended_tests"]
        traces.append(trace4)

        # 5. Epidemiology Agent
        trace5 = await self._execute_agent(
            "Epidemiology Agent",
            "Assess outbreak risk based on symptoms and diagnosis.",
            {"symptoms": state["extracted_symptoms"], "diagnosis": state["diagnosis"]},
            EpidemiologySchema
        )
        traces.append(trace5)

        # 6. Follow-up Agent
        trace6 = await self._execute_agent(
            "Follow-Up Agent",
            "Determine the follow-up timeframe and monitoring flags.",
            {"diagnosis": state["diagnosis"], "severity": trace1["output"]["severity"]},
            FollowUpSchema
        )
        traces.append(trace6)

        # 7. Verification Agent
        trace7 = await self._execute_agent(
            "Verification Agent",
            "Verify all previous reasoning to ensure no hallucinations, and generate the final SOAP note.",
            {
                "complaint": state["initial_complaint"],
                "symptoms": state["extracted_symptoms"],
                "diagnosis": state["diagnosis"],
                "labs": state["recommended_labs"],
                "safety": trace3["output"]
            },
            VerificationSchema
        )
        state["soap_note"] = trace7["output"]["final_soap_note"]
        traces.append(trace7)

        # Persist to Database (AuditLog and AIConversation)
        messages_list = [
            {"role": "user", "content": input_text},
            {"role": "assistant", "content": str(state["soap_note"])},
            {"role": "system_metadata", "traces": traces, "ai_model": "gemini-2.5-flash", "confidence_score": trace7["output"].get("confidence", 1.0)}
        ]
        conversation = AIConversation(
            patient_id=patient_id,
            messages=messages_list
        )
        self.db.add(conversation)
        
        audit_log = AuditLog(
            user_id=doctor_id,
            action="AI_CONSULTATION_WORKFLOW",
            details=json.dumps({"agents_run": 7, "patient_id": patient_id, "conversation_id": None})
        )
        self.db.add(audit_log)
        
        await self.db.commit()
        await self.db.refresh(conversation)

        # Update audit log details with correct conversation ID
        audit_log.details = json.dumps({"agents_run": 7, "patient_id": patient_id, "conversation_id": str(conversation.id)})
        await self.db.commit()

        return {
            "conversation_id": str(conversation.id),
            "final_state": state,
            "traces": traces
        }
