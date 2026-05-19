from fastapi import APIRouter, Depends, HTTPException
from app.database import get_db
from app.models.user import User
from app.security import get_current_active_user
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix="/api/doctor", tags=["doctor"])

@router.get("/dashboard")
async def get_doctor_dashboard(current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    if current_user.role != "Doctor":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    return {
        "metrics": {
            "patients_today": 12,
            "appointments": 5
        },
        "appointments": [
            {"name": "Rahul Sharma", "time": "10:00 AM", "type": "Cardiology", "image_url": "https://i.pravatar.cc/150?img=11"},
            {"name": "Priya Patel", "time": "11:15 AM", "type": "Cardiology", "image_url": "https://i.pravatar.cc/150?img=5"}
        ]
    }
