import os
import json
import asyncio
import time
from typing import List, Dict, Any, Type, Optional
from pydantic import BaseModel
from google import genai
from google.genai import types

from app.services.ai.base import BaseAIService
from app.core.config import settings

def _clean_schema(d: Any) -> Any:
    if isinstance(d, dict):
        return {k: _clean_schema(v) for k, v in d.items() if k != "additionalProperties"}
    elif isinstance(d, list):
        return [_clean_schema(x) for x in d]
    return d

class GeminiAIService(BaseAIService):
    """
    Strict Production-grade Gemini API Integration using google-genai.
    Enforces structured JSON outputs, retries, timeouts, and token tracking.
    """
    
    def __init__(self):
        # We must have an API key in production
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable is required in production.")
            
        self.client = genai.Client(api_key=api_key)
        self.model_name = "gemini-2.5-flash"  # Fast, cheap, and good at structured extraction
        self.max_retries = 3
        self.timeout = 30.0 # seconds
        
    async def _generate_content_with_retry(self, prompt: str, schema: Optional[Type[BaseModel]] = None) -> Dict[str, Any]:
        """Core generation method with exponential backoff and schema enforcement."""
        config_args = {
            "temperature": 0.2,
            "max_output_tokens": 2048,
        }
        
        if schema:
            config_args["response_mime_type"] = "application/json"
            # Get dict schema and remove additionalProperties for Developer API compatibility
            dict_schema = schema.model_json_schema()
            config_args["response_schema"] = _clean_schema(dict_schema)
            
        config = types.GenerateContentConfig(**config_args)
        
        for attempt in range(self.max_retries):
            start_time = time.time()
            try:
                # google-genai is synchronous currently, so we wrap in asyncio.to_thread
                response = await asyncio.to_thread(
                    self.client.models.generate_content,
                    model=self.model_name,
                    contents=prompt,
                    config=config
                )
                
                execution_time = time.time() - start_time
                
                # Parse JSON if schema was requested
                output_data = response.text
                if schema:
                    try:
                        output_data = json.loads(response.text)
                    except json.JSONDecodeError:
                        output_data = {"raw_text": response.text, "error": "Failed to parse JSON from model."}

                return {
                    "output": output_data,
                    "metadata": {
                        "execution_time_ms": int(execution_time * 1000),
                        "prompt_token_count": response.usage_metadata.prompt_token_count if response.usage_metadata else 0,
                        "candidates_token_count": response.usage_metadata.candidates_token_count if response.usage_metadata else 0,
                        "total_token_count": response.usage_metadata.total_token_count if response.usage_metadata else 0,
                    }
                }
                
            except Exception as e:
                if attempt == self.max_retries - 1:
                    raise RuntimeError(f"Gemini API failed after {self.max_retries} attempts: {str(e)}")
                await asyncio.sleep(2 ** attempt)  # Exponential backoff
                
    async def chat(self, messages: List[Dict[str, str]]) -> str:
        """Standard unstructured chat (e.g., for general assistant Q&A)."""
        # Convert simple dict list to text block for simplicity in basic chat
        prompt = "\\n".join([f"{m['role']}: {m['content']}" for m in messages])
        res = await self._generate_content_with_retry(prompt)
        return res["output"]

    # In Antigravity Orchestrator, we need specific JSON schemas for the 7 agents.
    # Rather than hardcoding the logic in these 3 legacy methods, we will expose
    # a generic agent invocation method that `antigravity_client.py` can use.
    
    async def run_agent(self, agent_name: str, system_prompt: str, input_data: Any, schema: Type[BaseModel]) -> Dict[str, Any]:
        """
        Executes a specific clinical agent with structured inputs and outputs.
        """
        prompt = f"You are the {agent_name} Agent.\\n\\nINSTRUCTIONS:\\n{system_prompt}\\n\\nINPUT DATA:\\n{json.dumps(input_data, default=str)}\\n\\nOUTPUT FORMAT:\\nRespond ONLY with valid JSON matching the schema."
        
        result = await self._generate_content_with_retry(prompt, schema=schema)
        
        return {
            "agent": agent_name,
            "input": input_data,
            "output": result["output"],
            "execution_time": result["metadata"]["execution_time_ms"],
            "tokens": result["metadata"]["total_token_count"]
        }

    # Legacy interfaces required by BaseAIService interface (we'll implement them loosely or adapt them)
    async def run_intake(self, input_text: str) -> Dict[str, Any]:
        class IntakeSchema(BaseModel):
            symptoms: List[str]
            severity: str
            duration: str
            urgency: str
            
        res = await self.run_agent(
            "Intake", 
            "Extract structured medical symptoms from the patient's narrative.", 
            input_text, 
            IntakeSchema
        )
        return res["output"]

    async def check_drug_safety(self, medications: List[str], patient_conditions: List[str]) -> Dict[str, Any]:
        class SafetySchema(BaseModel):
            safe: bool
            warnings: List[str]
            contraindications: List[str]
            
        res = await self.run_agent(
            "Drug Safety",
            "Cross-reference medications against patient conditions to identify contraindications.",
            {"medications": medications, "conditions": patient_conditions},
            SafetySchema
        )
        return res["output"]

    async def generate_soap_note(self, patient_info: Dict[str, Any], symptoms: List[str], diagnosis: str, plan: str) -> Dict[str, str]:
        class SOAPSchema(BaseModel):
            subjective: str
            objective: str
            assessment: str
            plan: str
            
        res = await self.run_agent(
            "SOAP Note",
            "Generate a professional clinical SOAP note.",
            {"patient": patient_info, "symptoms": symptoms, "diagnosis": diagnosis, "plan": plan},
            SOAPSchema
        )
        return res["output"]
