from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.database import init_db
from app.routes import auth, patient, doctor, admin, consultation, timeline, drug_safety

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize DB schema on startup
    await init_db()
    yield

app = FastAPI(title="PANOR API — National Clinical Intelligence Platform", lifespan=lifespan)

# Allow Flutter app to connect from any origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
