from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
<<<<<<< HEAD
from app.database import init_db
from app.routes import auth, patient, doctor, admin, consultation, timeline, drug_safety
=======
>>>>>>> fc499ec72141c05a34cfc3a83443f62db6c598dc

# v1 Route Controllers
from app.api.v1.auth import auth_routes
from app.api.v1.dashboard import dashboard_routes
from app.api.v1.appointments import appointment_routes
from app.api.v1.health_records import health_record_routes
from app.api.v1.ai_assistant import ai_routes
from app.api.v1.patients import patient_routes
from app.api.v1.doctors import doctor_routes
from app.api.v1.admins import admin_routes
from app.api.v1.notifications import notification_routes

<<<<<<< HEAD
app = FastAPI(title="PANOR API — National Clinical Intelligence Platform", lifespan=lifespan)
=======
>>>>>>> fc499ec72141c05a34cfc3a83443f62db6c598dc

app = FastAPI(
    title="PANOR — Agentic Clinical Intelligence Platform",
    description=(
        "**PANOR** (Patient-Augmented Network for Operational Reasoning) is a "
        "production-grade multi-agent healthcare intelligence platform powered by "
        "Google Antigravity orchestration. It runs 7 specialised clinical AI agents "
        "to provide intake intelligence, differential diagnosis, drug-safety checking, "
        "lab coordination, epidemiology monitoring, follow-up scheduling and SOAP "
        "note generation — all in a single consultation workflow."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS ─────────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # Tighten to specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

<<<<<<< HEAD
app.include_router(auth.router)
app.include_router(patient.router)
app.include_router(doctor.router)
app.include_router(admin.router)
app.include_router(consultation.router)
app.include_router(timeline.router)
app.include_router(drug_safety.router)

@app.get("/")
def read_root():
    return {
        "message": "PANOR Backend API is running",
        "version": "2.0-hackathon",
        "platform": "National Agentic Healthcare Intelligence — Pakistan",
        "agents_online": 7,
    }
=======
# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(auth_routes.router)
app.include_router(dashboard_routes.router)
app.include_router(appointment_routes.router)
app.include_router(health_record_routes.router)
app.include_router(ai_routes.router)
app.include_router(patient_routes.router)
app.include_router(doctor_routes.router)
app.include_router(admin_routes.router)
app.include_router(notification_routes.router)

# ── Health Check ──────────────────────────────────────────────────────────────
@app.get("/", tags=["health"])
def health_check():
    return {
        "success": True,
        "message": "PANOR Agentic Clinical Intelligence Platform is running",
        "data": {
            "version": "1.0.0",
            "framework": "FastAPI",
            "orchestrator": "Google Antigravity",
            "agents": 7,
            "docs": "/docs",
        },
        "errors": [],
        "meta": {},
    }


@app.get("/health", tags=["health"])
def liveness():
    return {"status": "ok"}
>>>>>>> fc499ec72141c05a34cfc3a83443f62db6c598dc
