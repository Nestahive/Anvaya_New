"""Gemini-backed vision provider for Anvaya produce verification.

The AI returns a *perception* (what it sees). The server decides the final
status via ``_decide()`` — the model never picks VERIFIED / REJECTED / RETAKE.
"""

import asyncio
import json
import logging
from typing import Any, Dict, List, Optional

from pydantic import BaseModel

from app.core.config import settings
from app.services.providers.base import BaseVisionProvider, InferenceUnavailableError

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Pydantic model for the raw AI perception (used as response_schema)
# ---------------------------------------------------------------------------

class RawPerception(BaseModel):
    """What Gemini returns — a factual observation, NOT a verdict."""
    image_usable: bool
    produce_visible: bool
    main_produce: Optional[str] = None
    condition: Optional[str] = None          # "fresh" | "damaged" | "spoiled" | null
    visible_issues: List[str] = []
    certainty: Optional[str] = None          # "high" | "medium" | "low" | null


# ---------------------------------------------------------------------------
# Certainty → confidence bucket (not a real probability — just a UX bucket)
# User constraint: confidence should never exceed 0.70 (70%) to appear genuine.
# ---------------------------------------------------------------------------
_CERTAINTY_TO_CONFIDENCE: Dict[str, float] = {
    "high": 0.68,
    "medium": 0.62,
}

# ---------------------------------------------------------------------------
# System instruction — step-by-step perception rules
# ---------------------------------------------------------------------------
_SYSTEM_INSTRUCTION = """\
You are an expert agricultural produce inspection module. Return ONLY the JSON schema.

Steps — follow in order:

1. IMAGE USABILITY & CLARITY (Blur, Lighting, Focus)
   Set image_usable = false if:
   - The picture is blurry, out of focus, motion-blurred, or shaken.
   - The picture is severely underexposed (too dark) or overexposed/glared (washed out).
   - The resolution or quality is too low to inspect skin texture and surface quality.
   Set image_usable = true ONLY when the image is sharp, clear, and well-focused.

2. PRODUCE PRESENT (Strict Non-Produce Rejection)
   Set produce_visible = true ONLY if real, raw agricultural produce (fresh fruit,
   vegetable, grain, pulse, root, spice, or herb) is present.
   Set produce_visible = false for any non-produce photo, including:
   - Electronics: laptops, desktop computers, mobile phones, screens, keyboards, mice, TVs.
   - Everyday objects: furniture, vehicles, utensils, clothing, books, tools, office items.
   - People: faces, selfies, human portraits (a hand merely holding produce is acceptable).
   - Animals, pets, nature landscapes without cultivated produce.
   - Cooked dishes, processed foods, snacks, packaged groceries, or bread.
   If produce_visible is false, set main_produce = null, condition = null, certainty = null, visible_issues = [].

3. PRODUCE RECOGNITION (All Agricultural Crops)
   Identify ANY real agricultural produce item — do NOT restrict to tomato, potato, or banana.
   Accurately recognize all crops, including but not limited to:
   - Vegetables: Potato, Tomato, Onion, Garlic, Ginger, Carrot, Cabbage, Cauliflower,
     Cucumber, Eggplant, Bell Pepper, Chili, Okra, Spinach, Radish, Beetroot, Peas, Beans.
   - Fruits: Apple, Banana, Mango, Orange, Lemon, Grapes, Strawberry, Papaya, Watermelon,
     Guava, Pomegranate, Pineapple, Avocado, Coconut, Peach, etc.
   - Grains & Pulses: Rice, Wheat, Corn/Maize, Coffee Beans, Chickpeas, Lentils, Soybean, etc.
   If multiple items exist, pick the primary item in the foreground or center.
   Set main_produce to the singular common English title (e.g. "Apple", "Onion", "Tomato").

4. CONDITION
   Evaluate the main produce item:
   - fresh: normal, healthy appearance. Note: Natural soil, potato eyes/dots, skin texture,
     and minor superficial scuffs are completely NORMAL and fresh.
   - damaged: visible bruises, cuts, deep scratches, cracks, or dents without rot.
   - spoiled: active rot, mold, decomposition, slime, or fungal growth.
   When uncertain between fresh and damaged, choose fresh.
   When uncertain between damaged and spoiled, choose damaged.

5. VISIBLE ISSUES
   List 1-3 word phrases describing ONLY visible defects (e.g. "bruise on side", "surface mold").
   If condition is fresh, visible_issues MUST be an empty list [].

6. CERTAINTY
   - high: produce identity and condition are distinctly clear and recognizable.
   - medium: produce is recognizable but angle or lighting is borderline.
   - low: produce cannot be reliably identified or condition cannot be assessed.

NEVER claim food safety, nutrition, chemical purity, or internal consumption quality.
Do NOT provide explanations — return ONLY the JSON object."""


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
                    http_options={"timeout": settings.INFERENCE_TIMEOUT_MS},
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
    _FALLBACK_MODELS = ["gemini-3.6-flash", "gemini-3.5-flash-lite"]

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

            # Only fallback to another model if the error was 429 (quota exhausted on this specific model)
            if "429" not in str(last_exc):
                break

        raise InferenceUnavailableError(f"Gemini API unavailable after {self._MAX_ATTEMPTS} attempts: {last_exc}")

    # ---- deterministic decision logic --------------------------------------

    @staticmethod
    def _decide(p: RawPerception) -> Dict[str, Any]:
        """Turn a perception into the final 5-field result.
        The model never chooses the status — this function does."""

        if not p.image_usable:
            return _result("RETAKE_REQUIRED")

        if not p.produce_visible or not p.main_produce:
            return _result("REJECTED")

        if p.certainty == "low" or p.condition is None:
            return _result("RETAKE_REQUIRED")

        condition = p.condition.lower() if p.condition else None
        if condition not in ("fresh", "damaged", "spoiled"):
            return _result("RETAKE_REQUIRED")

        raw_conf = _CERTAINTY_TO_CONFIDENCE.get(p.certainty, 0.62)
        confidence = round(min(raw_conf, 0.70), 2)

        # Fresh produce never has visible issues (by definition in our system)
        issues = [] if condition == "fresh" else list(p.visible_issues)

        return {
            "status": "VERIFIED",
            "produce": p.main_produce.strip().title(),
            "condition": condition,
            "confidence": confidence,
            "visible_issues": issues,
        }


# ---------------------------------------------------------------------------
# helper
# ---------------------------------------------------------------------------

def _result(status: str) -> Dict[str, Any]:
    return {
        "status": status,
        "produce": None,
        "condition": None,
        "confidence": None,
        "visible_issues": [],
    }
