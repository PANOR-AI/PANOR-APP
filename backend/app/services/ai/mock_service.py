import json
from typing import List, Dict, Any, Type
from pydantic import BaseModel
from app.services.ai.base import BaseAIService

class MockAIService(BaseAIService):
    """
    Mock AI service to allow running PANOR in zero-config development mode
    when GEMINI_API_KEY is not configured or settings.MOCK_AI is enabled.
    """
    
    async def chat(self, messages: List[Dict[str, str]]) -> str:
        return "This is a simulated response from the PANOR agentic co-pilot. In a production environment, this is powered by Gemini 2.5."

    async def run_agent(self, agent_name: str, system_prompt: str, input_data: Any, schema: Type[BaseModel]) -> Dict[str, Any]:
        """Returns high-quality mock data matching the requested schema."""
        output_data = {}
        
        # We can construct realistic response based on the agent name
        name_lower = agent_name.lower()
        
        if "intake" in name_lower:
            output_data = {
                "symptoms": ["Chest pain", "Fever", "Cough", "Mild dyspnea"],
                "severity": "HIGH",
                "duration": "3 days",
                "urgency_score": 8,
                "reasoning": [
                    "Patient reports chest pain combined with fever.",
                    "Potential acute respiratory infection or cardiac involvement.",
                    "Urgency elevated due to cardiovascular risk markers."
                ]
            }
        elif "reasoning" in name_lower:
            output_data = {
                "differential_diagnosis": [
                    "Community-Acquired Pneumonia",
                    "Acute Bronchitis",
                    "Pleurisy",
                    "Myocarditis"
                ],
                "primary_hypothesis": "Community-Acquired Pneumonia",
                "confidence": 0.85,
                "reasoning": [
                    "High fever and cough point towards lower respiratory tract infection.",
                    "Chest pain is likely pleuritic, secondary to lung inflammation.",
                    "Pneumonia remains the most probable clinical match."
                ]
            }
        elif "safety" in name_lower:
            output_data = {
                "is_safe": True,
                "contraindications": [],
                "warnings": [
                    "Monitor renal function if prescribing high-dose antibiotics.",
                    "Patient history check recommended for drug allergies."
                ],
                "reasoning": [
                    "No direct contraindications detected for standard pneumonia therapies.",
                    "Amoxicillin or Azithromycin is safe to proceed with."
                ]
            }
        elif "lab" in name_lower or "laboratory" in name_lower:
            output_data = {
                "recommended_tests": [
                    "Chest X-Ray (AP/Lateral)",
                    "Complete Blood Count (CBC) with differential",
                    "Sputum Culture",
                    "C-Reactive Protein (CRP)"
                ],
                "priority": "STAT",
                "reasoning": [
                    "Chest X-Ray is required to confirm consolidation in pneumonia.",
                    "CBC will confirm elevated white blood cell count indicating infection."
                ]
            }
        elif "epidemiology" in name_lower:
            output_data = {
                "outbreak_risk": "MEDIUM",
                "cluster_detected": False,
                "reasoning": [
                    "Pneumonia cases are within seasonal baselines.",
                    "No localized cluster detected in the patient's immediate region.",
                    "Routine epidemiology reporting advised."
                ]
            }
        elif "follow" in name_lower:
            output_data = {
                "follow_up_timeframe": "48 to 72 hours",
                "monitoring_flags": [
                    "Worsening shortness of breath",
                    "Persistent fever above 102F",
                    "Inability to tolerate oral fluids"
                ],
                "reasoning": [
                    "Standard re-evaluation timeframe for outpatient pneumonia care.",
                    "Warning flags are critical for early detection of treatment failure."
                ]
            }
        elif "verification" in name_lower or "soap" in name_lower:
            output_data = {
                "hallucination_detected": False,
                "confidence": 0.98,
                "reasoning": [
                    "All findings are consistent across all 6 preceding agents.",
                    "The plan matches standard clinical guidelines for pneumonia."
                ],
                "final_soap_note": {
                    "subjective": "34-year-old male presenting with chest pain, fever, cough and mild dyspnea lasting 3 days.",
                    "objective": "Temperature: 101.5 F, Heart Rate: 98 bpm, Blood Pressure: 120/80 mmHg, SpO2: 94%.",
                    "assessment": "Community-Acquired Pneumonia (Primary), R/O Pleurisy.",
                    "plan": "1. Recommend Chest X-Ray and CBC.\n2. Prescribe Amoxicillin 500mg PO TID for 7 days.\n3. Follow up in 48-72 hours or sooner if dyspnea worsens."
                }
            }
        else:
            # Fallback default schema matching
            # Let's inspect the fields in the schema and try to populate them
            for field_name, field_type in schema.__annotations__.items():
                if field_name == "confidence":
                    output_data[field_name] = 0.95
                elif field_name == "reasoning":
                    output_data[field_name] = ["Simulated reasoning path."]
                elif field_name == "symptoms":
                    output_data[field_name] = ["Cough", "Fever"]
                elif field_name == "differential_diagnosis":
                    output_data[field_name] = ["Infection"]
                elif field_name == "is_safe" or field_name == "safe":
                    output_data[field_name] = True
                elif field_name == "recommended_tests" or field_name == "recommended_labs":
                    output_data[field_name] = ["CBC"]
                elif field_name == "outbreak_risk":
                    output_data[field_name] = "LOW"
                elif field_name == "cluster_detected":
                    output_data[field_name] = False
                elif field_name == "follow_up_timeframe":
                    output_data[field_name] = "7 days"
                elif field_name == "monitoring_flags":
                    output_data[field_name] = ["Fever"]
                elif field_name == "hallucination_detected":
                    output_data[field_name] = False
                elif field_name == "final_soap_note" or field_name == "soap_note":
                    output_data[field_name] = {
                        "subjective": "Subjective summary.",
                        "objective": "Objective summary.",
                        "assessment": "Assessment details.",
                        "plan": "Plan details."
                    }
                else:
                    output_data[field_name] = "Mock value"

        # Validate using schema if possible
        validated = schema(**output_data)
        
        return {
            "agent": agent_name,
            "input": input_data,
            "output": validated.model_dump(),
            "execution_time": 150,
            "tokens": 420
        }

    # Legacy interfaces
    async def run_intake(self, input_text: str) -> Dict[str, Any]:
        return {
            "symptoms": ["chest pain", "fever"],
            "severity": "HIGH",
            "duration": "3 days",
            "urgency": "URGENT"
        }

    async def check_drug_safety(self, medications: List[str], patient_conditions: List[str]) -> Dict[str, Any]:
        return {
            "safe": True,
            "warnings": [],
            "contraindications": []
        }

    async def generate_soap_note(self, patient_info: Dict[str, Any], symptoms: List[str], diagnosis: str, plan: str) -> Dict[str, str]:
        return {
            "subjective": "Patient reports symptoms.",
            "objective": "Vitals recorded.",
            "assessment": "Suspected condition.",
            "plan": "Treatment plan."
        }
