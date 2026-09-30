"""Image preparation: normalise uploads to a clean JPEG before sending to the model."""

import io
import logging

from PIL import Image, ImageOps

logger = logging.getLogger(__name__)

_MAX_DIMENSION = 1024
_JPEG_QUALITY = 88


def prepare_image(raw_bytes: bytes) -> bytes:
    """Return JPEG bytes: fix EXIF rotation, convert to RGB, thumbnail to 1024 px, quality 88."""
    with Image.open(io.BytesIO(raw_bytes)) as img:
        # Fix EXIF rotation (auto-orient) so the model sees the photo right-side-up
        img = ImageOps.exif_transpose(img)

        # Convert to RGB (drop alpha channel from PNGs, handle palette images, etc.)
        img = img.convert("RGB")

        # Thumbnail preserves aspect ratio; only shrinks, never enlarges
        img.thumbnail((_MAX_DIMENSION, _MAX_DIMENSION), Image.LANCZOS)

        buf = io.BytesIO()
        img.save(buf, format="JPEG", quality=_JPEG_QUALITY)
        return buf.getvalue()
