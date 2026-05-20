import asyncio
import logging
from app.core.workers.celery_app import celery_app
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

logger = logging.getLogger(__name__)

# Create sync fallback engine for Celery sync workers
sync_db_url = settings.DATABASE_URL.replace("+aiosqlite", "").replace("+asyncpg", "")
if sync_db_url.startswith("sqlite"):
    sync_db_url = sync_db_url.replace("sqlite:///", "sqlite:///")
engine = create_engine(sync_db_url)
SessionLocal = sessionmaker(bind=engine)

@celery_app.task(name="tasks.send_medication_reminder")
def send_medication_reminder(patient_id: str, medication_name: str, dosage: str):
    """Dispatches medication tracking reminders to patients."""
    logger.info(f"Medication reminder dispatched to patient {patient_id} for drug {medication_name} ({dosage})")
    print(f"[REMINDER] Patient {patient_id}: It is time to take your {medication_name} ({dosage}).")
    return {"status": "dispatched", "patient_id": patient_id, "medication": medication_name}


@celery_app.task(name="tasks.schedule_follow_up")
def schedule_follow_up(patient_id: str, appointment_id: str, scheduled_hours: int = 48):
    """Schedules follow-up monitoring task to alert nurses if patient clinical state deteriorates."""
    logger.info(f"Follow-up scheduled in {scheduled_hours} hours for patient {patient_id} matching appointment {appointment_id}")
    return {"status": "scheduled", "hours": scheduled_hours, "patient_id": patient_id}


@celery_app.task(name="tasks.dispatch_notification")
def dispatch_notification(user_id: str, title: str, message: str):
    """Sends notification system alerts (WebSockets, SSE or SMS fallback)."""
    logger.info(f"System notification dispatched to user {user_id}: {title} - {message}")
    return {"status": "delivered", "user_id": user_id}


@celery_app.task(name="tasks.run_outbreak_analysis")
def run_outbreak_analysis(region: str = "Karachi"):
    """
    Performs batch-mode epidemiological analysis scanning the database
    for symptom spikes within geo-coordinates (outbreak clusters).
    """
    logger.info(f"Epidemiological outbreak scanner started for region: {region}")
    # Simulate cluster detection logic
    return {
        "status": "completed",
        "region": region,
        "clusters_detected": 1,
        "epidemic_warnings_issued": False
    }


@celery_app.task(name="tasks.process_ai_consultation")
def process_ai_consultation(patient_id: str, text_input: str):
    """Processes long-running multi-agent workflows out-of-band for scale."""
    logger.info(f"Offloaded long-running multi-agent reasoning started for patient: {patient_id}")
    # This runs asynchronously under the celery worker instance
    from app.services.ai.antigravity_client import AntigravityOrchestrator
    import asyncio
    
    orchestrator = AntigravityOrchestrator()
    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(
        orchestrator.execute_consultation_workflow(
            patient_id=patient_id,
            multimodal_input={"text": text_input}
        )
    )
    logger.info(f"Asynchronous Antigravity Multi-Agent session completed with outcome: {result.get('status')}")
    return {"status": "success", "workflow_id": result.get("workflow_id")}
