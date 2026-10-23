"""Gemini-backed vision provider for Anvaya produce verification.

The AI returns a *perception* (what it sees). The server decides the final
status via ``_decide()`` — the model never picks VERIFIED / REJECTED / RETAKE.
"""

import asyncio
import json
import logging
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field

from app.core.config import settings
from app.services.providers.base import BaseVisionProvider, InferenceUnavailableError

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Pydantic model for the raw AI perception (used as response_schema)
# ---------------------------------------------------------------------------

class RawPerception(BaseModel):
    """What Gemini returns — a factual observation, NOT an uncalibrated guess."""
    image_usable: bool = Field(description="False if image is blurry, out-of-focus, overexposed, or too degraded to inspect produce surface.")
    produce_visible: bool = Field(description="True if real raw agricultural produce (fruits, vegetables, garlic, onions, grains, etc.) is visible.")
    has_multiple_produce: bool = Field(False, description="True if more than one distinct fruit or vegetable item or type is present.")
    detected_items: List[str] = Field(default_factory=list, description="Names of all distinct fruits or vegetables spotted in the image.")
    main_produce: Optional[str] = Field(None, description="The singular common English name of the single produce item if and only if exactly one produce item/type is captured.")
    condition: Optional[str] = Field(None, description="'fresh', 'damaged', or 'spoiled', or null if cannot be determined.")
    visible_issues: List[str] = Field(default_factory=list, description="List of visible physical defects only (bruises, mold, cuts). Empty if fresh or no visible defect.")
    confidence_score: Optional[float] = Field(None, description="Model's genuine confidence score from 0.0 to 1.0 evaluating certainty of produce identity and surface condition.")
    rejection_or_retake_reason: Optional[str] = Field(None, description="Explanation if unusable, non-produce, or multiple items detected.")
    certainty: Optional[str] = None          # Backwards-compatibility for mock/legacy unit tests: "high" | "medium" | "low" | null


# ---------------------------------------------------------------------------
# System instruction — step-by-step perception rules
# ---------------------------------------------------------------------------
_SYSTEM_INSTRUCTION = """\
You are an expert agricultural produce inspection module for the Anvaya Produce Verification Engine.
Return ONLY a JSON object adhering to the schema.

1. IMAGE USABILITY & CLARITY:
   Set image_usable = false if the image is blurry, severely out of focus, motion-blurred,
   underexposed (too dark), overexposed/glared, or too degraded to inspect surface texture.
   If image_usable = false, specify rejection_or_retake_reason.

2. PRODUCE PRESENT:
   Set produce_visible = true ONLY if real, raw agricultural produce (fruits, vegetables, garlic,
   onions, grains, etc.) is present.
   Set produce_visible = false for non-produce (electronics like laptops or keyboards, people,
   furniture, utensils, cooked food).
   If produce_visible = false, set main_produce = null, condition = null, confidence_score = null,
   and set rejection_or_retake_reason = "No agricultural produce detected."

3. MULTIPLE PRODUCE DETECTION (STRICT ONE-ITEM RULE):
   Anvaya strictly inspects ONE produce item per capture session.
   Identify all produce items in the image.
   If the image contains MORE THAN ONE distinct fruit, vegetable, or produce item (for example,
   a guava alongside an orange and garlic, or a mango alongside a guava), you MUST set:
   - has_multiple_produce = true
   - detected_items = list of all detected items, e.g. ["Guava", "Orange", "Garlic"]
   - main_produce = null
   - condition = null
   - rejection_or_retake_reason = "Multiple produce detected. Please capture one item at a time."
   Do NOT choose just one item when multiple items are present.

4. SINGLE PRODUCE IDENTIFICATION:
   If and only if exactly ONE produce item is present:
   - has_multiple_produce = false
   - detected_items = [item_name]
   - main_produce = Singular common English name (e.g. "Guava", "Mango", "Garlic", "Tomato", "Apple")
   Identify the actual produce accurately. Do not guess based on color alone.

5. CONDITION ASSESSMENT FROM VISIBLE EVIDENCE ONLY:
   Assess visible physical surface condition:
   - "fresh": Normal, healthy appearance. Natural skin texture, peel variations, stems, garlic husk lines,
     or potato eyes are completely NORMAL and fresh.
   - "damaged": Clear, unambiguous physical damage such as deep bruising, skin punctures, cuts, or dents.
   - "spoiled": Active rot, fungal decay, mold, or decomposition.
   CRITICAL: NEVER invent, hallucinate, or fabricate punctures, spots, holes, rot, or defects.
   If there are no unmistakable physical defects visible, condition MUST be "fresh" and visible_issues MUST be [].
   If condition cannot be determined with certainty, set condition = null.

6. CONFIDENCE SCORE:
   Supply a genuine confidence score between 0.0 and 1.0 reflecting your true visual certainty
   in the produce identification and condition.
   Never use a static or arbitrary number.
"""


# ---------------------------------------------------------------------------
# Provider
# ---------------------------------------------------------------------------

class CurrentVisionProvider(BaseVisionProvider):
    """Calls Gemini with structured output and returns a raw perception dict."""

    def __init__(
        self,
        api_key: Optional[str] = None,
        model_name: Optional[str] = None,
    ):
        self.api_key = api_key or settings.GEMINI_API_KEY
        self.model_name = model_name or settings.GEMINI_MODEL
        self._client = None
        if self.api_key:
            try:
                from google import genai
                self._client = genai.Client(
                    api_key=self.api_key,
                    http_options={"timeout": max(settings.INFERENCE_TIMEOUT_MS, 15000)},
                )
            except Exception as e:
                logger.error(f"Failed to initialize GenAI client: {e}")

    # ---- public interface --------------------------------------------------

    async def infer(self, image_bytes: bytes, mime_type: str = "image/jpeg") -> Dict[str, Any]:
        if not self._client:
            raise InferenceUnavailableError(
                "Gemini API client is not initialised or API key is missing."
            )
        perception = await self._call_gemini(image_bytes, mime_type)
        return self._decide(perception)

    # ---- Gemini call with retry --------------------------------------------

    _MAX_ATTEMPTS = 2
    _RETRY_CODES = {"429", "500", "503"}
    _FALLBACK_MODELS = ["gemini-3.5-flash-lite", "gemini-3.1-flash-lite", "gemini-3.8-flash"]

    async def _call_gemini(self, image_bytes: bytes, mime_type: str) -> RawPerception:
        from google.genai import types

        models_to_try = [self.model_name]
        for fb in self._FALLBACK_MODELS:
            if fb not in models_to_try:
                models_to_try.append(fb)

        last_exc: Optional[Exception] = None
        for model in models_to_try:
            for attempt in range(1, self._MAX_ATTEMPTS + 1):
                try:
                    response = await self._client.aio.models.generate_content(
                        model=model,
                        contents=[
                            types.Part.from_bytes(data=image_bytes, mime_type=mime_type),
                        ],
                        config=types.GenerateContentConfig(
                            system_instruction=_SYSTEM_INSTRUCTION,
                            response_mime_type="application/json",
                            response_schema=RawPerception,
                            temperature=0.0,
                        ),
                    )
                    raw_text = response.text.strip()
                    data = json.loads(raw_text)
                    perception = RawPerception(**data)
                    logger.info(f"Raw perception from {model}: {perception.model_dump_json()}")
                    return perception

                except Exception as exc:
                    last_exc = exc
                    err_str = str(exc)
                    retryable = any(code in err_str for code in self._RETRY_CODES) or "timeout" in err_str.lower()
                    if retryable and attempt < self._MAX_ATTEMPTS:
                        logger.warning(
                            f"Gemini {model} attempt {attempt} failed ({err_str[:120]}), retrying in 1.5s…"
                        )
                        await asyncio.sleep(1.5)
                        continue
                    break

            # Fallback to next candidate model if current model experiences quota, overload, 404, or 503
            err_text = str(last_exc).lower()
            if not any(code in err_text for code in ["429", "503", "404", "timeout", "unavailable", "resource"]):
                break

        raise InferenceUnavailableError(f"Gemini API unavailable across attempted models: {last_exc}")

    # ---- deterministic decision logic --------------------------------------

    @staticmethod
    def _decide(p: RawPerception) -> Dict[str, Any]:
        """Turn a perception into the final 5-field result.
        The model never chooses the status — this function does."""

        # 1. Unusable image (blurry, dark, glaring, etc.)
        if not p.image_usable:
            return _result(
                "RETAKE_REQUIRED",
                message=p.rejection_or_retake_reason or "Image quality is too low for reliable analysis. Please retake photo.",
            )

        # 2. Strict produce visibility
        if not p.produce_visible or (not p.detected_items and not p.main_produce):
            return _result(
                "REJECTED",
                message=p.rejection_or_retake_reason or "No agricultural produce detected. Please capture a fruit or vegetable.",
            )

        # 3. Multiple produce detected (STRICT ONE-PRODUCE RULE)
        if p.has_multiple_produce or len(p.detected_items) > 1:
            return _result(
                "RETAKE_REQUIRED",
                message="Multiple produce detected. Please capture one item at a time.",
            )

        # 4. Produce condition determination
        if p.certainty == "low" or not p.condition:
            return _result(
                "RETAKE_REQUIRED",
                message="Produce condition cannot be determined reliably. Please retake photo from a clearer angle.",
            )

        condition = p.condition.strip().lower()
        if condition not in ("fresh", "damaged", "spoiled"):
            return _result(
                "RETAKE_REQUIRED",
                message="Produce condition cannot be determined reliably. Please retake photo from a clearer angle.",
            )

        # 5. Genuine confidence score calculation (no fixed 68%, no artificial caps)
        if p.confidence_score is not None:
            confidence = round(max(0.0, min(1.0, float(p.confidence_score))), 2)
        elif p.certainty is not None:
            # Backwards-compatibility for unit test mocks specifying certainty
            certainty_map = {"high": 0.92, "medium": 0.78, "low": 0.50}
            confidence = certainty_map.get(p.certainty, 0.75)
        else:
            return _result(
                "RETAKE_REQUIRED",
                message="Confidence score is unreliable. Please retake photo.",
            )

        if confidence < 0.55:
            return _result(
                "RETAKE_REQUIRED",
                message="Confidence too low for reliable verification. Please take a clearer photo.",
            )

        # Produce name
        produce_name = (p.main_produce or (p.detected_items[0] if p.detected_items else "Produce")).strip().title()

        # Fresh produce never has visible issues
        issues = [] if condition == "fresh" else list(p.visible_issues)

        return {
            "status": "VERIFIED",
            "produce": produce_name,
            "condition": condition,
            "confidence": confidence,
            "visible_issues": issues,
            "message": "Produce verified successfully.",
        }


# ---------------------------------------------------------------------------
# helper
# ---------------------------------------------------------------------------

def _result(status: str, message: Optional[str] = None) -> Dict[str, Any]:
    return {
        "status": status,
        "produce": None,
        "condition": None,
        "confidence": None,
        "visible_issues": [],
        "message": message,
    }
