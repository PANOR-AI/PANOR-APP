import os
import sys
import json
import asyncio
from dotenv import load_dotenv
from sqlalchemy import select

# Add parent directory to path so we can import app modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Load env variables from backend/.env
load_dotenv("g:\\PANOR-APP\\backend\\.env")

from app.database import AsyncSessionLocal
from app.models.all_models import User, Patient, Doctor, AIConversation, AuditLog, Vitals, LabReport, Prescription
from app.services.ai.antigravity_client import AntigravityOrchestrator
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

async def main():
    print("=============================================================")
    print("STARTING REAL GEMINI PIPELINE VERIFICATION")
    print("=============================================================")
    
    # 1. Setup DB Session
    async with AsyncSessionLocal() as session:
        # Create a fresh patient
        patient_email = "real_patient_test@panor.com"
        print(f"Creating/Ensuring real test patient: {patient_email}")
        
        stmt = select(User).where(User.email == patient_email)
        res = await session.execute(stmt)
        user = res.scalars().first()
        
        if not user:
            user = User(
                email=patient_email,
                hashed_password=pwd_context.hash("SecurePassword123"),
                full_name="Verification Patient",
                role="Patient",
                is_active=True
            )
            session.add(user)
            await session.commit()
            await session.refresh(user)
            
            # Create profile
            profile = Patient(id=user.id, blood_group="A+", gender="Female")
            session.add(profile)
            await session.commit()
            print(f"Created new patient with ID: {user.id}")
        else:
            print(f"Using existing patient with ID: {user.id}")
            
        patient_id = user.id
        
        # Create a doctor for auditing
        doctor_email = "real_doctor_test@panor.com"
        print(f"Creating/Ensuring real test doctor: {doctor_email}")
        stmt = select(User).where(User.email == doctor_email)
        res = await session.execute(stmt)
        doc_user = res.scalars().first()
        
        if not doc_user:
            doc_user = User(
                email=doctor_email,
                hashed_password=pwd_context.hash("SecurePassword123"),
                full_name="Dr. Sarah Jenkins",
                role="Doctor",
                is_active=True
            )
            session.add(doc_user)
            await session.commit()
            await session.refresh(doc_user)
            
            doc_profile = Doctor(id=doc_user.id, specialty="Pulmonology", license_number="LIC99887")
            session.add(doc_profile)
            await session.commit()
            print(f"Created new doctor with ID: {doc_user.id}")
        else:
            print(f"Using existing doctor with ID: {doc_user.id}")
            
        doctor_id = doc_user.id
        
        # 2. Trigger Orchestrator
        complaint = "I have had a sharp chest pain when breathing in, a deep dry cough, and a mild fever of 100.8 F for 3 days."
        print(f"\nTriggering Antigravity sequential 7-agent workflow...")
        print(f"Complaint: \"{complaint}\"")
        
        orchestrator = AntigravityOrchestrator(session)
        
        start_time = asyncio.get_event_loop().time()
        result = await orchestrator.execute_consultation_workflow(
            input_text=complaint,
            patient_id=patient_id,
            doctor_id=doctor_id
        )
        total_time = asyncio.get_event_loop().time() - start_time
        
        print("\n=============================================================")
        print("PIPELINE EXECUTION COMPLETED")
        print(f"Total Pipeline Runtime: {total_time:.2f} seconds")
        print(f"Conversation ID: {result['conversation_id']}")
        print("=============================================================\n")
        
        # Print Traces for all 7 Agents
        for idx, trace in enumerate(result["traces"], 1):
            print(f"[{idx}/7] AGENT: {trace['agent']}")
            print(f"    - ID: {trace['id']}")
            print(f"    - Execution Time: {trace['execution_time']}")
            print(f"    - Confidence: {trace['confidence']}")
            print(f"    - Input Keys: {list(trace['input'].keys())}")
            print(f"    - Reasoning: {trace['reasoning']}")
            print(f"    - Output Payload: {json.dumps(trace['output'], indent=2)}")
            print("-" * 50)
            
        # 3. Fetch Database Verification Proofs
        print("\n=============================================================")
        print("DATABASE VERIFICATION & INTEGRITY PROOFS")
        print("=============================================================")
        
        # Proof A: AIConversation check
        print("\n[Database Proof A] Querying AIConversation...")
        conv_stmt = select(AIConversation).where(AIConversation.id == result["conversation_id"])
        conv_res = await session.execute(conv_stmt)
        conversation = conv_res.scalars().first()
        
        if conversation:
            print("  - Found AIConversation Record:")
            print(f"    * ID: {conversation.id}")
            print(f"    * Patient ID: {conversation.patient_id}")
            print(f"    * Messages Count: {len(conversation.messages)}")
            # Show system metadata
            meta = conversation.messages[-1]
            print(f"    * AI Model Used: {meta.get('ai_model')}")
            print(f"    * Confidence Score: {meta.get('confidence_score')}")
            print("  - SUCCESS: Conversation persisted cleanly in PostgreSQL.")
        else:
            print("  - FAIL: AIConversation not found in database.")
            
        # Proof B: AuditLog check
        print("\n[Database Proof B] Querying AuditLogs...")
        audit_stmt = select(AuditLog).where(AuditLog.user_id == doctor_id).order_by(AuditLog.created_at.desc())
        audit_res = await session.execute(audit_stmt)
        logs = audit_res.scalars().all()
        
        print(f"  - Found {len(logs)} AuditLogs for User {doctor_id}:")
        for log in logs[:2]:
            print(f"    * Action: {log.action}")
            print(f"    * Details: {log.details}")
            print(f"    * Recorded At: {log.created_at}")
            
if __name__ == "__main__":
    asyncio.run(main())
