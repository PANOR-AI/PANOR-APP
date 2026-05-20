"""
PANOR Database Seed Script — Hackathon Demo Data
Seeds the complete Ahmed Raza cardiac emergency scenario with:
- Pakistani patient, doctor, lab tech, and admin accounts
- NADRA P_ID national identity
- Active medications for drug interaction demo
- Pre-loaded timeline entries for append-only demo
"""
import asyncio
import hashlib
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import AsyncSessionLocal, init_db
from app.models.user import User
from app.models.medication import Medication
from app.models.timeline import TimelineEntry
from app.security import get_password_hash


def cnic_hash(cnic: str) -> str:
    """Generate SHA-256 hash of CNIC number (NADRA mock)."""
    return hashlib.sha256(cnic.encode()).hexdigest()


async def seed():
    await init_db()
    async with AsyncSessionLocal() as db:
        # ──────────────────────────────────────────────────────────
        # 1. SEED USERS — Pakistani Healthcare Scenario
        # ──────────────────────────────────────────────────────────
        users = [
            User(
                email="patient@panor.com",
                hashed_password=get_password_hash("password"),
                full_name="Ahmed Raza",
                role="Patient",
                p_id="PAK-HEALTH-DEMO-0001",
                cnic_hash=cnic_hash("35202-1234567-1"),
                profile_data={
                    "age": 52,
                    "gender": "Male",
                    "blood_group": "A+",
                    "city": "Lahore",
                    "province": "Punjab",
                    "chronic_conditions": ["Type 2 Diabetes Mellitus", "Hypertension"],
                    "emergency_contact": "Fatima Raza (Spouse) • +92 300 1234567",
                    "vitals": {
                        "bp": "130/85",
                        "hr": "78 bpm",
                        "spo2": "97%",
                        "temp": "99.1 °F",
                    },
                    "bmi": 28.4,
                    "prior_ecg": "Normal sinus rhythm (6 months ago)",
                },
            ),
            User(
                email="doctor@panor.com",
                hashed_password=get_password_hash("password"),
                full_name="Dr. Fatima Hassan",
                role="Doctor",
                p_id=None,
                cnic_hash=None,
                profile_data={
                    "specialty": "Cardiology",
                    "hospital": "PANOR Cardiac Centre, Lahore",
                    "pmdc_registration": "PMC-42891-L",
                    "experience_years": 14,
                },
            ),
            User(
                email="admin@panor.com",
                hashed_password=get_password_hash("password"),
                full_name="Noorullah Khan",
                role="Administrator",
                p_id=None,
                cnic_hash=None,
                profile_data={
                    "access_level": "Tier 1 — Regional Health Director",
                    "region": "Punjab",
                    "jurisdiction": "Lahore Division",
                },
            ),
            User(
                email="lab@panor.com",
                hashed_password=get_password_hash("password"),
                full_name="Sana Malik",
                role="Lab Technician",
                p_id=None,
                cnic_hash=None,
                profile_data={
                    "specialization": "Clinical Pathology & Hematology",
                    "lab_name": "PANOR Central Pathology Lab, Lahore",
                    "license_id": "PML-2026-1847",
                },
            ),
        ]
        db.add_all(users)
        try:
            await db.commit()
            print("[OK] Users seeded successfully!")
        except Exception as e:
            await db.rollback()
            print(f"[WARN] Users may already exist: {e}")

        # Fetch patient user for FK references
        from sqlalchemy.future import select
        result = await db.execute(select(User).where(User.email == "patient@panor.com"))
        patient = result.scalars().first()
        if not patient:
            print("[ERROR] Patient user not found -- skipping medication and timeline seeding.")
            return

        # ──────────────────────────────────────────────────────────
        # 2. SEED MEDICATIONS — Active Prescriptions for Drug Safety Demo
        # ──────────────────────────────────────────────────────────
        medications = [
            Medication(
                patient_id=patient.id,
                drug_name="Metformin",
                dosage="500mg",
                frequency="Twice daily (morning + evening)",
                drug_class="Biguanide",
                purpose="Blood sugar control — T2DM",
                prescribed_by="Dr. Fatima Hassan",
                is_active=True,
            ),
            Medication(
                patient_id=patient.id,
                drug_name="Amlodipine",
                dosage="5mg",
                frequency="Once daily (morning)",
                drug_class="Calcium Channel Blocker",
                purpose="Hypertension management",
                prescribed_by="Dr. Fatima Hassan",
                is_active=True,
            ),
            Medication(
                patient_id=patient.id,
                drug_name="Aspirin",
                dosage="75mg",
                frequency="Once daily (morning)",
                drug_class="Antiplatelet",
                purpose="Cardioprotective",
                prescribed_by="Dr. Fatima Hassan",
                is_active=True,
            ),
        ]
        db.add_all(medications)
        try:
            await db.commit()
            print("[OK] Medications seeded successfully!")
        except Exception as e:
            await db.rollback()
            print(f"[WARN] Medications error: {e}")

        # ──────────────────────────────────────────────────────────
        # 3. SEED TIMELINE — Pre-Loaded Append-Only History
        # ──────────────────────────────────────────────────────────
        now = datetime.utcnow()
        timeline_entries = [
            TimelineEntry(
                patient_id=patient.id,
                entry_type="consultation",
                title="Routine Diabetes Follow-Up",
                content_json={
                    "subjective": "Patient reports good compliance with Metformin. Occasional fatigue. No hypoglycemic episodes.",
                    "objective": "BP: 128/82 | HR: 74 | SpO2: 98% | FBS: 142 mg/dL | HbA1c: 7.2%",
                    "assessment": "T2DM — partially controlled. Hypertension — well controlled on Amlodipine.",
                    "plan": "Continue current regimen. Repeat HbA1c in 3 months. Lifestyle modification counselling.",
                },
                agent_source="Agent_07_Verification",
                trace_id="PANOR-20260401-A8F2C1D3",
                confidence_score="0.94",
                risk_level="GREEN",
                created_at=now - timedelta(days=90),
                created_by="doctor@panor.com",
                is_immutable=True,
            ),
            TimelineEntry(
                patient_id=patient.id,
                entry_type="lab_result",
                title="Lipid Panel — Routine",
                content_json={
                    "total_cholesterol": "218 mg/dL",
                    "hdl": "42 mg/dL",
                    "ldl": "148 mg/dL",
                    "triglycerides": "165 mg/dL",
                    "interpretation": "Borderline high cholesterol. LDL above target for diabetic patient.",
                    "recommendation": "Consider statin therapy initiation.",
                },
                agent_source="Agent_04_Lab_Coordination",
                trace_id="PANOR-20260415-B7E4D2F1",
                confidence_score="0.98",
                risk_level="YELLOW",
                created_at=now - timedelta(days=35),
                created_by="lab@panor.com",
                is_immutable=True,
            ),
            TimelineEntry(
                patient_id=patient.id,
                entry_type="consultation",
                title="Cardiology Assessment — ECG Review",
                content_json={
                    "subjective": "Patient complains of occasional exertional dyspnea. No chest pain at rest. Good medication compliance.",
                    "objective": "BP: 130/84 | HR: 76 | ECG: Normal sinus rhythm, no ST changes. Weight: 86kg.",
                    "assessment": "1. T2DM — stable. 2. Hypertension — controlled. 3. Lipids borderline — statin discussion deferred per patient preference.",
                    "plan": "Continue current medications. Aspirin 75mg added for cardiovascular prophylaxis. Follow-up in 3 months or PRN.",
                },
                agent_source="Agent_07_Verification",
                trace_id="PANOR-20260502-C3A1E5B8",
                confidence_score="0.91",
                risk_level="GREEN",
                created_at=now - timedelta(days=18),
                created_by="doctor@panor.com",
                is_immutable=True,
            ),
        ]
        db.add_all(timeline_entries)
        try:
            await db.commit()
            print("[OK] Timeline entries seeded successfully!")
        except Exception as e:
            await db.rollback()
            print(f"[WARN] Timeline error: {e}")

        print("\nPANOR database fully seeded for hackathon demo!")
        print("   Patient: Ahmed Raza (PAK-HEALTH-DEMO-0001)")
        print("   Doctor:  Dr. Fatima Hassan (Cardiology)")
        print("   Lab:     Sana Malik (Clinical Pathology)")
        print("   Admin:   Noorullah Khan (Regional Director)")


if __name__ == "__main__":
    asyncio.run(seed())
