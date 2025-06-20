from pydantic import BaseModel
from typing import Optional

class SupplierCreate(BaseModel):
    name: str
    contact_info: Optional[str] = None

class SupplierOut(SupplierCreate):
    id: int

    class Config:
        from_attributes = True
