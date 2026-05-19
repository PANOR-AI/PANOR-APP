import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import AsyncSessionLocal, init_db
from app.models.user import User
from app.security import get_password_hash

async def seed():
    await init_db()
    async with AsyncSessionLocal() as db:
        users = [
            User(email="patient@panor.com", hashed_password=get_password_hash("password"), full_name="Rahul Sharma", role="Patient"),
            User(email="doctor@panor.com", hashed_password=get_password_hash("password"), full_name="Dr. Amit Verma", role="Doctor"),
            User(email="admin@panor.com", hashed_password=get_password_hash("password"), full_name="Admin", role="Administrator"),
            User(email="lab@panor.com", hashed_password=get_password_hash("password"), full_name="Lab Tech", role="Lab Technician")

        ]
        db.add_all(users)
        try:
            await db.commit()
            print("Database seeded with test users!")
        except Exception as e:
            print("Users already exist or error:", e)

if __name__ == "__main__":
    asyncio.run(seed())
