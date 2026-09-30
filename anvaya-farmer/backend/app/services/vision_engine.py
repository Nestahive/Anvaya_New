"""Core vision inference orchestrator.

Prepares the image, calls the provider, normalises the result.
System errors (provider crash, normalisation failure) raise
InferenceUnavailableError — they must NOT become RETAKE_REQUIRED.
"""

import logging
from typing import Optional

from app.schemas.inference import NormalizedInferenceResult
from app.services.image_prep import prepare_image
from app.services.normalization import NormalizationService
from app.services.providers.base import BaseVisionProvider, InferenceUnavailableError
from app.services.providers.current_provider import CurrentVisionProvider

logger = logging.getLogger(__name__)


class VisionInferenceEngine:
    """Decouples the API layer from any specific vision provider."""

    def __init__(self, provider: Optional[BaseVisionProvider] = None):
        self._provider = provider or CurrentVisionProvider()

    def set_provider(self, provider: BaseVisionProvider) -> None:
        self._provider = provider

    async def analyze(
        self,
        image_bytes: bytes,
        mime_type: str = "image/jpeg",
    ) -> NormalizedInferenceResult:
        # 1. Prepare image (EXIF fix, RGB, thumbnail, JPEG)
        try:
            prepared = prepare_image(image_bytes)
        except Exception as exc:
            logger.error(f"Image preparation failed: {exc}", exc_info=True)
            raise InferenceUnavailableError("Image preparation failed") from exc

        # 2. Run provider inference — always send as image/jpeg after prep
        try:
            raw_result = await self._provider.infer(
                image_bytes=prepared, mime_type="image/jpeg"
            )
        except InferenceUnavailableError:
            raise  # already the right type
        except Exception as exc:
            logger.error(f"Provider inference failed: {exc}", exc_info=True)
            raise InferenceUnavailableError("Provider inference failed") from exc

        # 3. Normalise
        try:
            return NormalizationService.normalize(raw_result)
        except Exception as exc:
            logger.error(
                f"Normalisation failed on raw result {raw_result}: {exc}",
                exc_info=True,
            )
            raise InferenceUnavailableError("Normalisation failed") from exc


# Global singleton
_default_engine: Optional[VisionInferenceEngine] = None


def get_vision_engine() -> VisionInferenceEngine:
    global _default_engine
    if _default_engine is None:
        _default_engine = VisionInferenceEngine()
    return _default_engine
