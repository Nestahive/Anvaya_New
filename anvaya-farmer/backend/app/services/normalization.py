"""Normalisation layer: validates provider output into NormalizedInferenceResult.

Raises ValueError for anything unexpected — never silently invents values.
"""

import logging
import re
from typing import Any, Dict, List

from app.schemas.inference import NormalizedInferenceResult

logger = logging.getLogger(__name__)

# Phrases forbidden by safety / accuracy boundary rules
FORBIDDEN_CLAIM_PATTERNS = [
    re.compile(r"\bsafe\s+to\s+eat\b", re.IGNORECASE),
    re.compile(r"\bchemically\s+uncontaminated\b", re.IGNORECASE),
    re.compile(r"\bhealthy\b", re.IGNORECASE),
    re.compile(r"\bmicrobe-?free\b", re.IGNORECASE),
    re.compile(r"\blaboratory\b", re.IGNORECASE),
    re.compile(r"\bpesticide-?free\b", re.IGNORECASE),
    re.compile(r"\b100%\s+pure\b", re.IGNORECASE),
]

_VALID_STATUSES = {"VERIFIED", "REJECTED", "RETAKE_REQUIRED"}
_VALID_CONDITIONS = {"fresh", "damaged", "spoiled"}


class NormalizationService:
    """Transforms provider output into NormalizedInferenceResult.
    Raises ValueError for unknown status, unknown condition, or missing confidence."""

    @classmethod
    def normalize(cls, raw_data: Dict[str, Any]) -> NormalizedInferenceResult:
        if not isinstance(raw_data, dict):
            raise ValueError(f"Expected dict from provider, got {type(raw_data).__name__}")

        # 1. Status — must be one of the three known values
        raw_status = str(raw_data.get("status", "")).strip().upper()
        if raw_status not in _VALID_STATUSES:
            raise ValueError(f"Unknown status '{raw_status}' from provider")

        # Message if present
        raw_message = raw_data.get("message")
        message = str(raw_message).strip() if raw_message else None

        # 2. Non-verified states
        if raw_status in ("REJECTED", "RETAKE_REQUIRED"):
            return NormalizedInferenceResult(
                status=raw_status,
                produce=None,
                condition=None,
                confidence=None,
                visible_issues=[],
                message=message,
            )

        # 3. VERIFIED — every field must be present and valid
        raw_produce = raw_data.get("produce")
        if not raw_produce or not isinstance(raw_produce, str) or not raw_produce.strip():
            raise ValueError("VERIFIED result has no produce name")

        produce = raw_produce.strip().title()

        raw_condition = raw_data.get("condition")
        if raw_condition is None or str(raw_condition).strip().lower() not in _VALID_CONDITIONS:
            raise ValueError(f"Unknown condition '{raw_condition}' in VERIFIED result")
        condition = str(raw_condition).strip().lower()

        raw_conf = raw_data.get("confidence")
        if raw_conf is None:
            raise ValueError("VERIFIED result has no confidence value")
        try:
            confidence = float(raw_conf)
        except (ValueError, TypeError) as exc:
            raise ValueError(f"Invalid confidence value '{raw_conf}'") from exc
        if not (0.0 <= confidence <= 1.0):
            raise ValueError(f"Confidence {confidence} out of range [0, 1]")
        confidence = round(confidence, 2)

        # Visible issues — clean and filter
        raw_issues = raw_data.get("visible_issues", [])
        if not isinstance(raw_issues, list):
            raw_issues = [str(raw_issues)]

        clean_issues: List[str] = []
        for issue in raw_issues:
            if not issue or not isinstance(issue, str):
                continue
            cleaned = issue.strip()
            if not cleaned:
                continue
            if any(pattern.search(cleaned) for pattern in FORBIDDEN_CLAIM_PATTERNS):
                continue
            cleaned_title = cleaned[0].upper() + cleaned[1:] if len(cleaned) > 1 else cleaned.upper()
            if cleaned_title not in clean_issues:
                clean_issues.append(cleaned_title)

        return NormalizedInferenceResult(
            status="VERIFIED",
            produce=produce,
            condition=condition,
            confidence=confidence,
            visible_issues=clean_issues,
            message=message,
        )
