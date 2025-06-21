from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Stock as StockModel
from models.db_schema import Item as ItemModel
from models.db_schema import Users as UserModel
from schemas.stock import StockCreate, StockOut
from database.db import get_db
from routes.auth import get_current_user
from models.enum_items import Role
from utils.check_role import check_role

router = APIRouter()

db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[StockOut])
async def get_stock_entries(db: Session = db_dependency, user: dict = user_dependency):
    stocks = db.query(
        StockModel.id,
        StockModel.item_id,
        StockModel.user_id,
        StockModel.quantity,
        StockModel.movement_type,
        StockModel.timestamp,
        ItemModel.name.label("item_name"),
        UserModel.username.label("username"),
    ).join(
        ItemModel, StockModel.item_id == ItemModel.id
    ).join(
        UserModel, StockModel.user_id == UserModel.id
    ).all()
    
    return stocks

@router.post("/", response_model=StockCreate, status_code=status.HTTP_201_CREATED)
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

@router.put("/{stock_id}", response_model=StockCreate)
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