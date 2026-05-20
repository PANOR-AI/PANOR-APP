import pytest
import asyncio
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.database import AsyncSessionLocal, get_db
from app.main import app
from app.core.config import settings
from app.models.all_models import User, Patient, Doctor
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@pytest.fixture(scope="session", autouse=True)
def seed_test_database():
    """Session fixture to seed the required test users for test suites."""
    asyncio.run(async_seed())

async def async_seed():
    async with AsyncSessionLocal() as session:
        # Delete from child tables in raw SQL to prevent SQLAlchemy from attempting SET NULL updates
        child_tables = [
            "audit_logs", "notifications", "messages", "prescriptions", "lab_reports", 
            "imaging_reports", "vitals", "medications", "ai_conversations", 
            "health_records", "appointments", "documents", "patients", "doctors", 
            "administrators", "users"
        ]
        for table in child_tables:
            await session.execute(text(f"DELETE FROM {table}"))
        await session.commit()

        # 1. Seed Admin
        admin = User(
            email="admin@panor.com",
            hashed_password=pwd_context.hash("password"),
            full_name="Test Admin",
            role="Administrator",
            is_active=True
        )
        session.add(admin)
            
        # 2. Seed Patient
        patient_user = User(
            email="patient@panor.com",
            hashed_password=pwd_context.hash("password"),
            full_name="Test Patient User",
            role="Patient",
            is_active=True
        )
        session.add(patient_user)
        await session.commit()
        await session.refresh(patient_user)
        
        # Seed Patient Profile
        patient_profile = Patient(
            id=patient_user.id,
            blood_group="O+",
            gender="Male"
        )
        session.add(patient_profile)

        # 3. Seed Doctor
        doctor_user = User(
            email="doctor@panor.com",
            hashed_password=pwd_context.hash("password"),
            full_name="Test Doctor User",
            role="Doctor",
            is_active=True
        )
        session.add(doctor_user)
        await session.commit()
        await session.refresh(doctor_user)
        
        # Seed Doctor Profile
        doctor_profile = Doctor(
            id=doctor_user.id,
            specialty="Cardiology",
            license_number="LIC12345"
        )
        session.add(doctor_profile)

        await session.commit()


@pytest.fixture(autouse=True)
def override_database_dependency():
    """Create a fresh engine and sessionmaker per test call to prevent async event loop teardown issues on Windows."""
    test_engine = create_async_engine(settings.DATABASE_URL, echo=False)
    TestAsyncSessionLocal = sessionmaker(test_engine, class_=AsyncSession, expire_on_commit=False)
    
    async def _get_test_db():
        async with TestAsyncSessionLocal() as session:
            try:
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise
            finally:
                await session.close()
                await test_engine.dispose()
                
    app.dependency_overrides[get_db] = _get_test_db
    yield
    app.dependency_overrides.clear()
