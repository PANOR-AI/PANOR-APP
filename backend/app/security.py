"""
Security Module for PANOR.

This module handles:
1. Secure password hashing using raw `bcrypt` (ensuring compatibility across Python versions without passlib errors).
2. JWT (JSON Web Token) session token creation and encoding.
3. FastAPI dependency injections to retrieve and validate the current logged-in user.
"""

import os
from datetime import datetime, timedelta
import bcrypt
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database import get_db
from app.models.user import User

# Configuration parameters retrieved from environment variables
SECRET_KEY = os.getenv("SECRET_KEY", "supersecretjwtkey12345")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7  # Session tokens remain valid for 7 days

# OAuth2 schema configuration mapping to our unified login API endpoint
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verifies if a plain text password matches its stored bcrypt hash.
    
    Args:
        plain_password: The raw password submitted by the user.
        hashed_password: The secure string stored in the database.
        
    Returns:
        True if the password is valid, False otherwise.
    """
    try:
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except Exception:
        return False

def get_password_hash(password: str) -> str:
    """
    Generates a secure, salted bcrypt hash of a plain text password.
    
    Args:
        password: The plain text password to be encrypted.
        
    Returns:
        A secure string representation of the salted password hash.
    """
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    """
    Generates a signed JWT access token containing secure session details.
    
    Args:
        data: A dictionary containing claims (e.g. user identity and authorization role).
        expires_delta: Optional custom session duration override.
        
    Returns:
        A signed JWT token string.
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)):
    """
    FastAPI Dependency: Authenticates a request by decoding and validating the Bearer JWT token,
    then fetching the corresponding User object from the database.
    
    Throws status 401 Unauthorized if the token is invalid or the user does not exist.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # Decode token and extract the user subject (email claim)
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    # Query database to retrieve the authenticated user
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalars().first()
    
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    """
    FastAPI Dependency: Validates that the authenticated user is currently active.
    
    Throws status 400 Bad Request if the account is deactivated.
    """
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

