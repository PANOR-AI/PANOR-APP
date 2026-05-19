from fastapi import APIRouter, Depends, HTTPException
from app.database import get_db
from app.models.user import User
from app.security import get_current_active_user
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

router = APIRouter(prefix="/api/admin", tags=["admin"])

@router.get("/dashboard")
async def get_admin_dashboard(current_user: User = Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    if current_user.role != "Administrator":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # Real DB counts
    total_users_result = await db.execute(select(User))
    users = total_users_result.scalars().all()
    
    total_patients = len([u for u in users if u.role == "Patient"])
    total_doctors = len([u for u in users if u.role == "Doctor"])
    
    return {
        "metrics": {
            "total_patients": total_patients,
            "active_doctors": total_doctors
        },
        "recent_activities": [
            {"title": "New Doctor Registered", "desc": "Dr. Neha Singh", "time": "2 mins ago"},
            {"title": "New Patient Registered", "desc": "Rahul Sharma", "time": "5 mins ago"}
        ]
    }
