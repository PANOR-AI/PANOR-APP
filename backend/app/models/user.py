from sqlalchemy import Column, Integer, String, Boolean, JSON
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, nullable=False) # patient, doctor, admin
    full_name = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    profile_data = Column(JSON, nullable=True) # For specific details like specialties or age
