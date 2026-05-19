from pydantic import BaseModel, EmailStr
from typing import Optional, Any

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    role: str

class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str
    role: str
    profile_data: Optional[Any] = None

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str
