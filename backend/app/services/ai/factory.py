from app.services.ai.base import BaseAIService
from app.services.ai.gemini import GeminiAIService

def get_ai_service() -> BaseAIService:
    """
    Returns the production Gemini AI Service.
    Mock fallback has been completely removed to enforce strict production rules.
    """
    return GeminiAIService()
