from fastapi import APIRouter

router = APIRouter(prefix="/api/consultation", tags=["consultation"])

@router.post("/start")
async def start_consultation():
    return {"status": "Consultation started through Antigravity pipeline"}
