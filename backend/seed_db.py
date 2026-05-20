import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import AsyncSessionLocal
from app.models.all_models import User, Patient, Doctor
from app.security import get_password_hash
import random

async def seed():
    async with AsyncSessionLocal() as db:
        # Check if users already exist
        from sqlalchemy.future import select
        existing = await db.execute(select(User).limit(1))
        if existing.scalars().first():
            print("Users already exist. Skipping seeding.")
            return

        users = [
            User(email="patient@panor.com", hashed_password=get_password_hash("password"), full_name="Rahul Sharma", role="Patient"),
            User(email="doctor@panor.com", hashed_password=get_password_hash("password"), full_name="Dr. Amit Verma", role="Doctor"),
            User(email="admin@panor.com", hashed_password=get_password_hash("password"), full_name="Admin", role="Administrator"),
            User(email="lab@panor.com", hashed_password=get_password_hash("password"), full_name="Lab Tech", role="Lab Technician")
        ]
        db.add_all(users)
        await db.flush()  # Generate user IDs

        # Add corresponding patient and doctor profiles so their dashboards load fine
        for u in users:
            if u.role == "Patient":
                db.add(Patient(id=u.id))
            elif u.role == "Doctor":
                db.add(Doctor(id=u.id, specialty="Cardiology", license_number=f"LIC-{random.randint(10000, 99999)}"))

        try:
            await db.commit()
            print("Database seeded with test users and profiles!")
        except Exception as e:
            print("Seeding error:", e)

if __name__ == "__main__":
    asyncio.run(seed())
