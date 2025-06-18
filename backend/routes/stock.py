from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Stock as StockModel
from schemas.stock import StockCreate, StockOut
from database.db import get_db
from routes.auth import get_current_user
from models.enum import Role
from utils.check_role import check_role

router = APIRouter()

db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[StockOut])
async def get_stock_entries(db: Session = db_dependency, user: dict = user_dependency):
    return db.query(StockModel).all()

@router.post("/", response_model=StockOut, status_code=status.HTTP_201_CREATED)
@check_role([Role.ADMIN])
async def create_stock_entry(stock: StockCreate, db: Session = db_dependency, user: dict = user_dependency):
    new_stock = StockModel(**stock.model_dump())
    db.add(new_stock)
    db.commit()
    db.refresh(new_stock)
    return new_stock

@router.get("/{stock_id}", response_model=StockOut)
async def get_stock_entry(stock_id: int, db: Session = db_dependency, user: dict = user_dependency):
    stock = db.query(StockModel).filter(StockModel.id == stock_id).first()
    if not stock:
        raise HTTPException(status_code=404, detail="Stock entry not found")
    return stock

@router.put("/{stock_id}", response_model=StockOut)
@check_role([Role.ADMIN])
async def update_stock_entry(stock_id: int, stock: StockCreate, db: Session = db_dependency, user: dict = user_dependency):
    db_stock = db.query(StockModel).filter(StockModel.id == stock_id).first()
    if not db_stock:
        raise HTTPException(status_code=404, detail="Stock entry not found")
    for key, value in stock.model_dump().items():
        setattr(db_stock, key, value)
    db.commit()
    db.refresh(db_stock)
    return db_stock

@router.delete("/{stock_id}", status_code=status.HTTP_204_NO_CONTENT)
@check_role([Role.ADMIN])
async def delete_stock_entry(stock_id: int, db: Session = db_dependency, user: dict = user_dependency):
    stock = db.query(StockModel).filter(StockModel.id == stock_id).first()
    if not stock:
        raise HTTPException(status_code=404, detail="Stock entry not found")
    db.delete(stock)
    db.commit()
    return