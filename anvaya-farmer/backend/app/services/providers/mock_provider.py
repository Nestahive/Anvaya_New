from typing import Any, Dict, Optional
from app.services.providers.base import BaseVisionProvider


class MockVisionProvider(BaseVisionProvider):
    """
    Mock vision provider for unit tests and local simulation of all 5 state variations.
    """

    def __init__(self, forced_response: Optional[Dict[str, Any]] = None):
        self.forced_response = forced_response

    def set_response(self, response: Dict[str, Any]):
        self.forced_response = response

    async def infer(self, image_bytes: bytes, mime_type: str = "image/jpeg") -> Dict[str, Any]:
        if self.forced_response is not None:
            return self.forced_response

        # Default mock response: Fresh Tomato
        return {
            "status": "VERIFIED",
            "produce": "Tomato",
            "condition": "fresh",
            "confidence": 0.94,
            "visible_issues": [],
        }
