"""Tests for the provider decision logic, normalisation, and API error handling.

All tests use mocked providers — no real Gemini calls.
"""

import io
import pytest
from unittest.mock import AsyncMock, patch, MagicMock

from PIL import Image

# ---------------------------------------------------------------------------
# Provider decision-logic tests (unit)
# ---------------------------------------------------------------------------
from app.services.providers.current_provider import (
    CurrentVisionProvider,
    RawPerception,
)
from app.services.providers.base import InferenceUnavailableError
from app.services.normalization import NormalizationService


class TestDecideFunction:
    """Tests for CurrentVisionProvider._decide() — pure logic, no I/O."""

    def test_clear_potato_is_verified(self):
        """A clear potato image → VERIFIED, fresh, genuine high confidence."""
        p = RawPerception(
            image_usable=True,
            produce_visible=True,
            main_produce="Potato",
            condition="fresh",
            visible_issues=[],
            confidence_score=0.94,
        )
        result = CurrentVisionProvider._decide(p)
        assert result["status"] == "VERIFIED"
        assert result["produce"] == "Potato"
        assert result["condition"] == "fresh"
        assert result["confidence"] == 0.94
        assert result["visible_issues"] == []

    def test_multiple_produce_detected_is_retake(self):
        """Multiple produce items in image → RETAKE_REQUIRED with message."""
        p = RawPerception(
            image_usable=True,
            produce_visible=True,
            has_multiple_produce=True,
            detected_items=["Guava", "Orange", "Garlic"],
            main_produce=None,
            condition=None,
            visible_issues=[],
        )
        result = CurrentVisionProvider._decide(p)
        assert result["status"] == "RETAKE_REQUIRED"
        assert result["produce"] is None
        assert result["message"] == "Multiple produce detected. Please capture one item at a time."

    def test_unusable_image_is_retake(self):
        """Unreadable image → RETAKE_REQUIRED."""
        p = RawPerception(
            image_usable=False,
            produce_visible=False,
            main_produce=None,
            condition=None,
            visible_issues=[],
            certainty=None,
        )
        result = CurrentVisionProvider._decide(p)
        assert result["status"] == "RETAKE_REQUIRED"
        assert result["produce"] is None

    def test_no_produce_is_rejected(self):
        """Usable image, no produce visible → REJECTED."""
        p = RawPerception(
            image_usable=True,
            produce_visible=False,
            main_produce=None,
            condition=None,
            visible_issues=[],
            certainty=None,
        )
        result = CurrentVisionProvider._decide(p)
        assert result["status"] == "REJECTED"
        assert result["produce"] is None

    def test_low_certainty_is_retake(self):
        """Low certainty → RETAKE_REQUIRED even with produce visible."""
        p = RawPerception(
            image_usable=True,
            produce_visible=True,
            main_produce="Tomato",
            condition="fresh",
            visible_issues=[],
            certainty="low",
        )
        result = CurrentVisionProvider._decide(p)
        assert result["status"] == "RETAKE_REQUIRED"

    def test_fresh_has_no_issues(self):
        """Fresh produce always has empty visible_issues, even if model sent some."""
        p = RawPerception(
            image_usable=True,
            produce_visible=True,
            main_produce="Apple",
            condition="fresh",
            visible_issues=["minor scratch"],
            confidence_score=0.91,
        )
        result = CurrentVisionProvider._decide(p)
        assert result["status"] == "VERIFIED"
        assert result["condition"] == "fresh"
        assert result["visible_issues"] == []

    def test_medium_certainty_confidence(self):
        """Medium certainty or confidence score → genuine confidence."""
        p = RawPerception(
            image_usable=True,
            produce_visible=True,
            main_produce="Banana",
            condition="damaged",
            visible_issues=["small bruise"],
            confidence_score=0.82,
        )
        result = CurrentVisionProvider._decide(p)
        assert result["status"] == "VERIFIED"
        assert result["confidence"] == 0.82
        assert "small bruise" in result["visible_issues"]

    def test_null_condition_is_retake(self):
        """Null condition → RETAKE_REQUIRED."""
        p = RawPerception(
            image_usable=True,
            produce_visible=True,
            main_produce="Mango",
            condition=None,
            visible_issues=[],
            confidence_score=0.90,
        )
        result = CurrentVisionProvider._decide(p)
        assert result["status"] == "RETAKE_REQUIRED"


# ---------------------------------------------------------------------------
# Normalisation tests
# ---------------------------------------------------------------------------

class TestNormalization:
    def test_malformed_provider_output_raises(self):
        """Non-dict raw output must raise ValueError."""
        with pytest.raises(ValueError, match="Expected dict"):
            NormalizationService.normalize("not a dict")

    def test_unknown_status_raises(self):
        """Unknown status must raise ValueError."""
        with pytest.raises(ValueError, match="Unknown status"):
            NormalizationService.normalize({"status": "MAYBE_OK"})

    def test_verified_without_produce_raises(self):
        """VERIFIED without produce must raise ValueError."""
        with pytest.raises(ValueError, match="no produce name"):
            NormalizationService.normalize({
                "status": "VERIFIED",
                "produce": None,
                "condition": "fresh",
                "confidence": 0.90,
                "visible_issues": [],
            })

    def test_verified_without_confidence_raises(self):
        """VERIFIED without confidence must raise ValueError."""
        with pytest.raises(ValueError, match="no confidence"):
            NormalizationService.normalize({
                "status": "VERIFIED",
                "produce": "Tomato",
                "condition": "fresh",
                "confidence": None,
                "visible_issues": [],
            })

    def test_unknown_condition_raises(self):
        """VERIFIED with unknown condition must raise ValueError."""
        with pytest.raises(ValueError, match="Unknown condition"):
            NormalizationService.normalize({
                "status": "VERIFIED",
                "produce": "Tomato",
                "condition": "rotten",
                "confidence": 0.85,
                "visible_issues": [],
            })

    def test_valid_verified_normalises(self):
        """Valid VERIFIED data normalises correctly."""
        result = NormalizationService.normalize({
            "status": "VERIFIED",
            "produce": "potato",
            "condition": "fresh",
            "confidence": 0.92,
            "visible_issues": [],
        })
        assert result.status == "VERIFIED"
        assert result.produce == "Potato"
        assert result.condition == "fresh"
        assert result.confidence == 0.92


# ---------------------------------------------------------------------------
# API-level tests (503 on provider failure, no leaked text)
# ---------------------------------------------------------------------------

from fastapi.testclient import TestClient
from app.main import app


def _make_test_image_bytes() -> bytes:
    """Create a minimal valid JPEG in memory."""
    img = Image.new("RGB", (100, 100), color="green")
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


class TestAPIErrorHandling:
    def test_provider_failure_returns_503_no_leak(self):
        """Provider crash → HTTP 503, message has no internal text."""
        with patch(
            "app.services.vision_engine.VisionInferenceEngine.analyze",
            new_callable=AsyncMock,
            side_effect=InferenceUnavailableError("Gemini exploded"),
        ):
            client = TestClient(app)
            img_bytes = _make_test_image_bytes()
            resp = client.post(
                "/ai/analyze",
                files={"image": ("test.jpg", img_bytes, "image/jpeg")},
            )
            assert resp.status_code == 503
            body = resp.json()
            assert "temporarily unavailable" in body["detail"].lower()
            # Must not contain internal details
            assert "Gemini" not in body["detail"]
            assert "exploded" not in body["detail"]


class TestRetryBehaviour:
    @pytest.mark.asyncio
    async def test_retry_once_on_503(self):
        """Provider retries once on a 503, then raises InferenceUnavailableError."""
        provider = CurrentVisionProvider.__new__(CurrentVisionProvider)
        provider.api_key = "fake-key"
        provider.model_name = "gemini-test"
        provider._client = MagicMock()

        call_count = 0

        async def fake_generate(*args, **kwargs):
            nonlocal call_count
            call_count += 1
            raise Exception("503 UNAVAILABLE")

        provider._client.aio.models.generate_content = fake_generate

        with pytest.raises(InferenceUnavailableError, match="unavailable across attempted models"):
            await provider._call_gemini(b"fake-image", "image/jpeg")

        assert call_count == 8  # 2 attempts x 4 candidate models
