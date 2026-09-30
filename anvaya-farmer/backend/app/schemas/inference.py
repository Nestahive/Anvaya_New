from typing import List, Optional, Literal
from pydantic import BaseModel, Field, model_validator


class NormalizedInferenceResult(BaseModel):
    """
    Fixed conceptual schema for Anvaya Vision Inference Engine.
    Only exactly these 5 fields are allowed.
    """
    status: Literal["VERIFIED", "REJECTED", "RETAKE_REQUIRED"]
    produce: Optional[str] = None
    condition: Optional[Literal["fresh", "damaged", "spoiled"]] = None
    confidence: Optional[float] = None
    visible_issues: List[str] = Field(default_factory=list)

    model_config = {
        "extra": "forbid",  # Strictly forbid any additional fields
    }

    @model_validator(mode="after")
    def validate_state_consistency(self):
        if self.status in ("REJECTED", "RETAKE_REQUIRED"):
            if self.produce is not None:
                raise ValueError(f"produce must be null when status is {self.status}")
            if self.condition is not None:
                raise ValueError(f"condition must be null when status is {self.status}")
            if self.confidence is not None:
                raise ValueError(f"confidence must be null when status is {self.status}")
            if len(self.visible_issues) > 0:
                raise ValueError(f"visible_issues must be empty when status is {self.status}")
        elif self.status == "VERIFIED":
            if not self.produce:
                raise ValueError("produce must not be empty when status is VERIFIED")
            if not self.condition:
                raise ValueError("condition must not be empty when status is VERIFIED")
            if self.confidence is None or not (0.0 <= self.confidence <= 1.0):
                raise ValueError("confidence must be a float between 0.0 and 1.0 when status is VERIFIED")
        return self
