from abc import ABC, abstractmethod
from typing import List, Dict, Any

class BaseAIService(ABC):
    @abstractmethod
    async def chat(self, messages: List[Dict[str, str]]) -> str:
        """Sends a conversation history to the model and returns the text response."""
        pass

    @abstractmethod
    async def run_intake(self, input_text: str) -> Dict[str, Any]:
        """Runs the Intake Agent on multilingual text."""
        pass

    @abstractmethod
    async def check_drug_safety(self, medications: List[str], patient_conditions: List[str]) -> Dict[str, Any]:
        """Checks for drug-drug and drug-condition interactions."""
        pass

    @abstractmethod
    async def generate_soap_note(self, patient_info: Dict[str, Any], symptoms: List[str], diagnosis: str, plan: str) -> Dict[str, str]:
        """Generates structured SOAP clinical notes."""
        pass
