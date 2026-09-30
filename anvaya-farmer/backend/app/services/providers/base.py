from abc import ABC, abstractmethod
from typing import Any, Dict


class BaseVisionProvider(ABC):
    """
    Abstract Base Class for Vision Inference Providers.
    Allows easy swapping between Gemini, EfficientNet, YOLO, or local edge models.
    """

    @abstractmethod
    async def infer(self, image_bytes: bytes, mime_type: str = "image/jpeg") -> Dict[str, Any]:
        """
        Analyze the given image bytes and return raw structured inference data.
        """
        pass


class InferenceUnavailableError(Exception):
    """Raised when the inference backend is temporarily unable to serve requests
    (e.g. Gemini 503, network timeout, provider crash).
    Must never be surfaced as RETAKE_REQUIRED — the client should see HTTP 503."""
    pass
