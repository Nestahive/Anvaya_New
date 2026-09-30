import logging
import io
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from PIL import Image

from app.core.config import settings
from app.schemas.inference import NormalizedInferenceResult
from app.services.providers.base import InferenceUnavailableError
from app.services.vision_engine import VisionInferenceEngine, get_vision_engine

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ai", tags=["Vision Inference"])


@router.post(
    "/analyze",
    response_model=NormalizedInferenceResult,
    status_code=status.HTTP_200_OK,
    summary="Analyze Produce Image",
    description="Processes an image of a fruit or vegetable and returns a fixed structured inference result.",
)
async def analyze_image(
    image: UploadFile = File(..., description="Produce image file to be analyzed"),
    engine: VisionInferenceEngine = Depends(get_vision_engine),
) -> NormalizedInferenceResult:
    # 1. Validation: File presence
    if not image or not image.filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An image file is required.",
        )

    # 2. Validation: Content-Type check
    content_type = image.content_type or ""
    allowed_types = settings.ALLOWED_IMAGE_TYPES
    if content_type and content_type.lower() not in allowed_types:
        # Check by extension as fallback
        filename_lower = image.filename.lower()
        if not any(filename_lower.endswith(ext) for ext in [".jpg", ".jpeg", ".png", ".webp"]):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unsupported image format. Allowed formats: JPEG, PNG, WEBP.",
            )

    # 3. Read image bytes and validate size
    try:
        image_bytes = await image.read()
    except Exception as e:
        logger.error(f"Error reading uploaded file: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Failed to read the uploaded image file.",
        )

    if not image_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The uploaded image file is empty.",
        )

    if len(image_bytes) > settings.MAX_IMAGE_SIZE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Image file exceeds maximum allowed size of {settings.MAX_IMAGE_SIZE_BYTES // (1024 * 1024)}MB.",
        )

    # 4. Validation: Verify image integrity via Pillow
    try:
        with Image.open(io.BytesIO(image_bytes)) as pil_img:
            pil_img.verify()
    except Exception as e:
        logger.warning(f"Corrupt or invalid image uploaded: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is corrupt or not a recognized image format.",
        )

    # 5. Run vision inference through the decoupled engine
    mime = content_type if content_type else "image/jpeg"
    try:
        result = await engine.analyze(image_bytes=image_bytes, mime_type=mime)
        return result
    except InferenceUnavailableError:
        # System error — tell the client to retry, do NOT return RETAKE_REQUIRED
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Analysis is temporarily unavailable. Please try again.",
        )
    except Exception as e:
        logger.error(f"Inference execution failed: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Analysis is temporarily unavailable. Please try again.",
        )
