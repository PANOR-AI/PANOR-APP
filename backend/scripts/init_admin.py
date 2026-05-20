import asyncio
import argparse
import sys
from sqlalchemy import select
from app.database import AsyncSessionLocal
from app.models.all_models import User, AuditLog
from passlib.context import CryptContext
from datetime import datetime

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

async def init_admin(email: str, password: str):
    async with AsyncSessionLocal() as session:
        # Check if any admin exists
        stmt = select(User).where(User.role == "Administrator")
        result = await session.execute(stmt)
        existing_admins = result.scalars().all()
        
        if existing_admins:
            print(f"Error: Initial administrator already exists. Script rejected.")
            sys.exit(1)
            
        # Create admin user
        hashed_password = pwd_context.hash(password)
        admin_user = User(
            email=email,
            hashed_password=hashed_password,
            full_name="System Administrator",
            role="Administrator",
            is_active=True
        )
        session.add(admin_user)
        await session.commit()
        await session.refresh(admin_user)
        
        # Create Audit Log
        audit_log = AuditLog(
            user_id=admin_user.id,
            action="SYSTEM_INIT",
            details="Root administrator created via init_admin.py script"
        )
        session.add(audit_log)
        await session.commit()
        
        print(f"Success: Root administrator {email} created successfully.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Initialize the root administrator.")
    parser.add_argument("--email", required=True, help="Email for the root admin")
    parser.add_argument("--password", required=True, help="Password for the root admin")
    args = parser.parse_args()
    
    asyncio.run(init_admin(args.email, args.password))
