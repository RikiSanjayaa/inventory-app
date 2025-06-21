from pydantic import BaseModel
from typing import Optional

class ItemCreate(BaseModel):
    name: str
    description: Optional[str] = None
    quantity: int
    price: float
    category_id: int
    supplier_id: int

class ItemOut(ItemCreate):
    id: int

    class Config:
        from_attributes = True

class ItemJoinedOut(BaseModel):
    id: int
    name: str
    description: str
    quantity: int
    price: float
    category_id: int
    supplier_id: int
    category_name: str
    supplier_name: str
    
    class Config:
        from_attributes = True