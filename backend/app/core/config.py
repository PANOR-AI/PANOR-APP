import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "PANOR"
    API_V1_STR: str = "/api"
    
    # Security
    SECRET_KEY: str = "supersecretjwtkey12345"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    REFRESH_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30  # 30 days
    
    # Databases
    # PostgreSQL for production
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/panor"
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # AI Config
    MOCK_AI: bool = True
    GCP_PROJECT_ID: str = "panor-hackathon-2026"
    GCP_REGION: str = "us-central1"
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )

settings = Settings()
