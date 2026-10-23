from typing import List, Optional
from pydantic import BaseModel, Field

class ProduceBatchCreate(BaseModel):
    batch_id: Optional[str] = None
    title: str
    category: str = "Vegetables"
    quantity: str = "100 kg"
    price: str = "$4.50"
    date: Optional[str] = None
    status: str = "VERIFIED"
    condition: Optional[str] = None
    confidence: Optional[float] = None
    visible_issues: List[str] = Field(default_factory=list)
    location: Optional[str] = None
    description: Optional[str] = None
    type: Optional[str] = None

class ProduceBatchResponse(BaseModel):
    id: Optional[int] = None
    batch_id: str
    title: str
    category: str
    quantity: str
    price: str
    date: str
    status: str
    condition: Optional[str] = None
    confidence: Optional[float] = None
    visible_issues: List[str] = Field(default_factory=list)
    location: Optional[str] = None
    description: Optional[str] = None
    type: Optional[str] = None
    created_at: Optional[str] = None
