import os
from app.services.ai.base import BaseAIService
from app.services.ai.gemini import GeminiAIService
from app.services.ai.mock_service import MockAIService
from app.core.config import settings

def get_ai_service() -> BaseAIService:
    """
    Returns the production Gemini AI Service.
    If settings.MOCK_AI is enabled or GEMINI_API_KEY is not configured,
    gracefully falls back to MockAIService to prevent startup crashes.
    """
    if settings.MOCK_AI or not os.getenv("GEMINI_API_KEY"):
        return MockAIService()
    return GeminiAIService()
