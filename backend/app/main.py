from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.future import select
import asyncio

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

from app.core.websocket import get_user_id_from_token, manager
from app.database import AsyncSessionLocal
from app.models.all_models import User

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

# ── WebSockets ───────────────────────────────────────────────────────────────
async def authenticate_ws(websocket: WebSocket, token: str) -> str | None:
    """Verifies access token and returns user ID."""
    email = get_user_id_from_token(token)
    if not email:
        return None
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalars().first()
        if user:
            return user.id
    return None

@app.websocket("/ws/notifications")
async def ws_notifications(websocket: WebSocket, token: str = Query(...)):
    user_id = await authenticate_ws(websocket, token)
    if not user_id:
        await websocket.close(code=1008)
        return
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
    except Exception:
        manager.disconnect(websocket, user_id)

@app.websocket("/ws/appointments")
async def ws_appointments(websocket: WebSocket, token: str = Query(...)):
    user_id = await authenticate_ws(websocket, token)
    if not user_id:
        await websocket.close(code=1008)
        return
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
    except Exception:
        manager.disconnect(websocket, user_id)

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
