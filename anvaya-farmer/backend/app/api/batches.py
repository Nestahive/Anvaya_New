import logging
import random
from datetime import datetime
from typing import List
from fastapi import APIRouter, HTTPException, status

from app.db.database import get_all_batches, insert_batch
from app.schemas.batch import ProduceBatchCreate, ProduceBatchResponse

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/batches", tags=["Produce Batches"])

@router.get("", response_model=List[ProduceBatchResponse])
async def list_batches():
    """Retrieve all registered produce batches, ordered from newest to oldest."""
    try:
        batches = get_all_batches()
        return batches
    except Exception as e:
        logger.error(f"Failed to fetch batches: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not retrieve produce batches from database.",
        )

@router.post("", response_model=ProduceBatchResponse, status_code=status.HTTP_201_CREATED)
async def create_batch(batch_in: ProduceBatchCreate):
    """Register a new produce batch and persist it to the SQLite database."""
    try:
        # Generate batch ID if not supplied
        batch_id = batch_in.batch_id
        if not batch_id or not batch_id.strip():
            random_num = random.randint(1000, 9999)
            batch_id = f"Batch #AG-{random_num}"
        elif not batch_id.startswith("Batch #"):
            batch_id = f"Batch #{batch_id.strip()}"

        # Generate human-readable date if not provided
        date_str = batch_in.date
        if not date_str or not date_str.strip():
            now = datetime.now()
            date_str = now.strftime("%b %d, %Y • %I:%M %p")

        # Determine type for icon matching if not provided
        produce_type = batch_in.type
        if not produce_type:
            title_lower = batch_in.title.lower()
            if "coffee" in title_lower:
                produce_type = "coffee"
            elif "honey" in title_lower:
                produce_type = "honey"
            elif "spinach" in title_lower or "leaf" in title_lower:
                produce_type = "spinach"
            elif "apple" in title_lower or "mango" in title_lower or "guava" in title_lower or "fruit" in title_lower:
                produce_type = "fruits"
            else:
                produce_type = "vegetables"

        batch_dict = {
            "batch_id": batch_id,
            "title": batch_in.title.strip(),
            "category": batch_in.category.strip() if batch_in.category else "Vegetables",
            "quantity": batch_in.quantity.strip() if batch_in.quantity else "100 kg",
            "price": batch_in.price.strip() if batch_in.price else "$4.50",
            "date": date_str,
            "status": batch_in.status.strip().upper() if batch_in.status else "VERIFIED",
            "condition": batch_in.condition.strip().lower() if batch_in.condition else None,
            "confidence": batch_in.confidence,
            "visible_issues": batch_in.visible_issues,
            "location": batch_in.location or "Green Valley Farm, Sector B",
            "description": batch_in.description or "",
            "type": produce_type,
        }

        created = insert_batch(batch_dict)
        logger.info(f"Successfully registered batch {batch_id} for produce '{batch_in.title}'")
        return created
    except Exception as e:
        logger.error(f"Failed to register produce batch: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to register produce batch into database.",
        )
