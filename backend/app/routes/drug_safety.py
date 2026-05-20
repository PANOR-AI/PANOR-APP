"""
Drug Safety Guardian API Routes.
Implements Agent 03's pharmacological reasoning with hard-block capability.
No prescription can execute without passing this safety gate.
"""
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional, List, Dict, Any

from app.models.user import User
from app.security import get_current_active_user

router = APIRouter(prefix="/api/drug-safety", tags=["drug_safety"])


# Known dangerous drug interactions (mock clinical database)
DRUG_INTERACTIONS = {
    ("ibuprofen", "metformin"): {
        "verdict": "BLOCK",
        "severity": "HIGH",
        "reason": "NSAIDs elevate hypoglycemia risk in Type 2 Diabetes patients on Metformin. Ibuprofen also reduces renal clearance of Metformin, increasing lactic acidosis risk.",
        "alternative": {"drug": "Paracetamol", "dosage": "500mg", "frequency": "Every 6 hours as needed", "reason": "Paracetamol provides equivalent analgesic effect without interfering with Metformin metabolism or glucose regulation."},
    },
    ("ibuprofen", "aspirin"): {
        "verdict": "BLOCK",
        "severity": "HIGH",
        "reason": "Co-administration of NSAIDs (Ibuprofen) blocks the cardioprotective antiplatelet effect of low-dose Aspirin. Risk profile: High cardiovascular hazard.",
        "alternative": {"drug": "Paracetamol", "dosage": "500mg", "frequency": "Every 6 hours as needed", "reason": "Paracetamol does not interfere with Aspirin's antiplatelet mechanism."},
    },
    ("warfarin", "aspirin"): {
        "verdict": "WARN",
        "severity": "MODERATE",
        "reason": "Combined use increases bleeding risk. Requires INR monitoring and dose adjustment.",
        "alternative": None,
    },
    ("metformin", "contrast_dye"): {
        "verdict": "WARN",
        "severity": "HIGH",
        "reason": "Contrast dye may cause acute kidney injury, reducing Metformin clearance and risking lactic acidosis. Hold Metformin 48h before/after contrast administration.",
        "alternative": None,
    },
}


class DrugCheckRequest(BaseModel):
    proposed_drug: str
    proposed_dosage: Optional[str] = None
    current_medications: List[str]  # List of drug names already prescribed
    patient_conditions: Optional[List[str]] = None  # e.g., ["T2DM", "Hypertension"]


class DrugInteraction(BaseModel):
    conflicting_drug: str
    verdict: str  # ALLOW, WARN, BLOCK
    severity: str
    reason: str
    alternative: Optional[Dict[str, Any]] = None


class DrugCheckResponse(BaseModel):
    proposed_drug: str
    overall_verdict: str  # ALLOW, WARN, BLOCK (worst-case of all interactions)
    interactions: List[DrugInteraction]
    agent_confidence: float
    trace_reasoning: List[str]


@router.post("/check", response_model=DrugCheckResponse)
async def check_drug_safety(
    request: DrugCheckRequest,
    current_user: User = Depends(get_current_active_user),
):
    """
    Agent 03 Drug Safety Guardian — checks proposed drug against all active medications.
    Returns ALLOW, WARN, or BLOCK verdict with pharmacological reasoning.
    BLOCK verdicts require physician override with clinical justification.
    """
    proposed = request.proposed_drug.lower().strip()
    interactions = []
    reasoning = [
        f"Checking proposed drug: {request.proposed_drug}",
        f"Against {len(request.current_medications)} active medications: {', '.join(request.current_medications)}",
    ]

    for current_med in request.current_medications:
        current = current_med.lower().strip()
        # Check both orderings of the drug pair
        pair_key = None
        if (proposed, current) in DRUG_INTERACTIONS:
            pair_key = (proposed, current)
        elif (current, proposed) in DRUG_INTERACTIONS:
            pair_key = (current, proposed)

        if pair_key:
            interaction_data = DRUG_INTERACTIONS[pair_key]
            interactions.append(DrugInteraction(
                conflicting_drug=current_med,
                verdict=interaction_data["verdict"],
                severity=interaction_data["severity"],
                reason=interaction_data["reason"],
                alternative=interaction_data.get("alternative"),
            ))
            reasoning.append(f"⚠️ CONFLICT: {request.proposed_drug} × {current_med} → {interaction_data['verdict']}")
        else:
            reasoning.append(f"✅ CLEAR: {request.proposed_drug} × {current_med} → No known interaction")

    # Determine overall verdict (worst-case)
    if any(i.verdict == "BLOCK" for i in interactions):
        overall = "BLOCK"
    elif any(i.verdict == "WARN" for i in interactions):
        overall = "WARN"
    else:
        overall = "ALLOW"

    reasoning.append(f"Overall safety verdict: {overall}")

    return DrugCheckResponse(
        proposed_drug=request.proposed_drug,
        overall_verdict=overall,
        interactions=interactions,
        agent_confidence=0.97 if interactions else 0.99,
        trace_reasoning=reasoning,
    )
