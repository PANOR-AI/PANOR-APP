from app.services.ai.base import BaseAIService
from app.core.config import settings
from typing import List, Dict, Any, TYPE_CHECKING

if TYPE_CHECKING:
    from app.services.ai.gemini import GeminiAIService

class MockAIService(BaseAIService):
    async def chat(self, messages: List[Dict[str, str]]) -> str:
        return "Mock AI response. Set MOCK_AI=False and configure GEMINI_API_KEY for real responses."
    async def run_intake(self, input_text: str) -> Dict[str, Any]:
        return {"symptoms": ["mock_symptom"], "severity": "low", "duration": "2 days", "urgency": "non-urgent"}
    async def check_drug_safety(self, medications: List[str], patient_conditions: List[str]) -> Dict[str, Any]:
        return {"safe": True, "warnings": [], "contraindications": []}
    async def generate_soap_note(self, patient_info: Dict[str, Any], symptoms: List[str], diagnosis: str, plan: str) -> Dict[str, str]:
        return {"subjective": "Mock SOAP subjective", "objective": "Mock objective", "assessment": diagnosis, "plan": plan}
    async def run_agent(self, agent_name: str, system_prompt: str, input_data: Any, schema: type) -> Dict[str, Any]:
        return {"output": {"confidence": 0.95, "reasoning": ["Mock reasoning"]}, "execution_time": 0, "metadata": {"execution_time_ms": 0, "total_token_count": 0}}

def get_ai_service() -> BaseAIService:
    if settings.MOCK_AI:
        return MockAIService()
    from app.services.ai.gemini import GeminiAIService
    return GeminiAIService()
