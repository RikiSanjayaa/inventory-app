from pydantic import BaseModel
from typing import Literal
from datetime import datetime

class StockCreate(BaseModel):
    item_id: int
    quantity: int
    movement_type: Literal['in', 'out']
    timestamp: datetime

class StockOut(StockCreate):
    id: int

    class Config:
        from_attributes = True