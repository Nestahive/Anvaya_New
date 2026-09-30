import io
import pytest
from fastapi.testclient import TestClient
from PIL import Image

from app.main import app
from app.services.vision_engine import get_vision_engine
from app.services.providers.mock_provider import MockVisionProvider
from app.services.normalization import NormalizationService
from app.schemas.inference import NormalizedInferenceResult


@pytest.fixture
def client():
    return TestClient(app)


def create_test_image(color=(255, 0, 0), size=(100, 100), format="JPEG") -> bytes:
    img = Image.new("RGB", size, color=color)
    buf = io.BytesIO()
    img.save(buf, format=format)
    return buf.getvalue()


class TestNormalizationService:
    def test_verified_produce_fresh(self):
        raw = {
            "status": "VERIFIED",
            "produce": "tomato",
            "condition": "fresh",
            "confidence": 0.94,
            "visible_issues": [],
        }
        res = NormalizationService.normalize(raw)
        assert res.status == "VERIFIED"
        assert res.produce == "Tomato"
        assert res.condition == "fresh"
        assert res.confidence == 0.94
        assert res.visible_issues == []

    def test_verified_produce_damaged(self):
        raw = {
            "status": "VERIFIED",
            "produce": "Tomato",
            "condition": "damaged",
            "confidence": 0.91,
            "visible_issues": ["Bruising", "Surface discoloration"],
        }
        res = NormalizationService.normalize(raw)
        assert res.status == "VERIFIED"
        assert res.produce == "Tomato"
        assert res.condition == "damaged"
        assert "Bruising" in res.visible_issues

    def test_verified_produce_spoiled(self):
        raw = {
            "status": "VERIFIED",
            "produce": "Tomato",
            "condition": "spoiled",
            "confidence": 0.96,
            "visible_issues": ["Visible rot", "Dark discoloration"],
        }
        res = NormalizationService.normalize(raw)
        assert res.status == "VERIFIED"
        assert res.condition == "spoiled"
        assert "Visible rot" in res.visible_issues

    def test_rejected_state(self):
        raw = {
            "status": "REJECTED",
            "produce": "Should Be Cleared",
            "condition": "fresh",
            "confidence": 0.5,
            "visible_issues": ["None"],
        }
        res = NormalizationService.normalize(raw)
        assert res.status == "REJECTED"
        assert res.produce is None
        assert res.condition is None
        assert res.confidence is None
        assert res.visible_issues == []

    def test_retake_required_state(self):
        raw = {
            "status": "RETAKE_REQUIRED",
            "produce": "Blurry",
            "condition": "unknown",
            "confidence": 0.2,
            "visible_issues": ["blurry"],
        }
        res = NormalizationService.normalize(raw)
        assert res.status == "RETAKE_REQUIRED"
        assert res.produce is None
        assert res.condition is None
        assert res.confidence is None
        assert res.visible_issues == []

    def test_forbidden_claims_filtered(self):
        raw = {
            "status": "VERIFIED",
            "produce": "Apple",
            "condition": "fresh",
            "confidence": 0.95,
            "visible_issues": ["Safe to eat", "Healthy", "Small cut"],
        }
        res = NormalizationService.normalize(raw)
        # "Safe to eat" and "Healthy" must be stripped out
        assert "Safe to eat" not in res.visible_issues
        assert "Healthy" not in res.visible_issues
        assert "Small cut" in res.visible_issues


class TestVisionApiEndpoints:
    def test_case_1_fresh_produce(self, client):
        """Test 1: Clear tomato image returns VERIFIED, Tomato, fresh, confidence, []"""
        engine = get_vision_engine()
        mock_provider = MockVisionProvider({
            "status": "VERIFIED",
            "produce": "Tomato",
            "condition": "fresh",
            "confidence": 0.94,
            "visible_issues": [],
        })
        engine.set_provider(mock_provider)

        img_bytes = create_test_image(color=(220, 20, 20))
        response = client.post(
            "/ai/analyze",
            files={"image": ("tomato.jpg", img_bytes, "image/jpeg")},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "VERIFIED"
        assert data["produce"] == "Tomato"
        assert data["condition"] == "fresh"
        assert data["confidence"] == 0.94
        assert data["visible_issues"] == []

    def test_case_2_damaged_produce(self, client):
        """Test 2: Tomato with visible bruising returns VERIFIED, Tomato, damaged, visible_issues contains Bruising"""
        engine = get_vision_engine()
        mock_provider = MockVisionProvider({
            "status": "VERIFIED",
            "produce": "Tomato",
            "condition": "damaged",
            "confidence": 0.91,
            "visible_issues": ["Bruising", "Surface discoloration"],
        })
        engine.set_provider(mock_provider)

        img_bytes = create_test_image(color=(200, 30, 30))
        response = client.post(
            "/ai/analyze",
            files={"image": ("bruised_tomato.jpg", img_bytes, "image/jpeg")},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "VERIFIED"
        assert data["produce"] == "Tomato"
        assert data["condition"] == "damaged"
        assert data["confidence"] == 0.91
        assert "Bruising" in data["visible_issues"]

    def test_case_3_spoiled_produce(self, client):
        """Test 3: Produce with visible decay returns VERIFIED, spoiled, visible_issues contains visible spoilage issue"""
        engine = get_vision_engine()
        mock_provider = MockVisionProvider({
            "status": "VERIFIED",
            "produce": "Tomato",
            "condition": "spoiled",
            "confidence": 0.96,
            "visible_issues": ["Visible rot", "Dark discoloration"],
        })
        engine.set_provider(mock_provider)

        img_bytes = create_test_image(color=(50, 40, 30))
        response = client.post(
            "/ai/analyze",
            files={"image": ("spoiled_tomato.jpg", img_bytes, "image/jpeg")},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "VERIFIED"
        assert data["condition"] == "spoiled"
        assert any("rot" in issue.lower() or "decay" in issue.lower() for issue in data["visible_issues"])

    def test_case_4_non_produce_object(self, client):
        """Test 4: Non-produce object (e.g. laptop) returns REJECTED, null, null, null, []"""
        engine = get_vision_engine()
        mock_provider = MockVisionProvider({
            "status": "REJECTED",
            "produce": None,
            "condition": None,
            "confidence": None,
            "visible_issues": [],
        })
        engine.set_provider(mock_provider)

        img_bytes = create_test_image(color=(128, 128, 128))
        response = client.post(
            "/ai/analyze",
            files={"image": ("laptop.jpg", img_bytes, "image/jpeg")},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "REJECTED"
        assert data["produce"] is None
        assert data["condition"] is None
        assert data["confidence"] is None
        assert data["visible_issues"] == []

    def test_case_5_poor_image_retake_required(self, client):
        """Test 5: Blurry/unusable image returns RETAKE_REQUIRED, null, null, null, []"""
        engine = get_vision_engine()
        mock_provider = MockVisionProvider({
            "status": "RETAKE_REQUIRED",
            "produce": None,
            "condition": None,
            "confidence": None,
            "visible_issues": [],
        })
        engine.set_provider(mock_provider)

        img_bytes = create_test_image(color=(0, 0, 0))
        response = client.post(
            "/ai/analyze",
            files={"image": ("blurry.jpg", img_bytes, "image/jpeg")},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "RETAKE_REQUIRED"
        assert data["produce"] is None
        assert data["condition"] is None
        assert data["confidence"] is None
        assert data["visible_issues"] == []

    def test_invalid_image_upload(self, client):
        """Corrupt or non-image files return 400 Bad Request"""
        response = client.post(
            "/ai/analyze",
            files={"image": ("bad.txt", b"not an image", "text/plain")},
        )
        assert response.status_code == 400
        assert "detail" in response.json()

    def test_health_endpoint(self, client):
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"
