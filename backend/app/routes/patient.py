from fastapi import APIRouter, Depends, HTTPException
from app.database import get_db
from app.models.user import User
from app.security import get_current_active_user
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix="/api/patient", tags=["patient"])

@router.get("/dashboard")
async def get_patient_dashboard(current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    if current_user.role != "Patient":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # Mock data that would normally come from PostgreSQL and Firestore
    return {
        "health_summary": {
            "blood_pressure": "120/80",
            "heart_rate": "72 bpm"
        },
        "appointments": [
            {
                "doctor_name": "Dr. Amit Verma",
                "specialty": "Cardiologist",
                "datetime": "24 May 2026, 10:00 AM",
                "image_url": "https://i.pravatar.cc/150?img=33"
            }
        ]
    }
