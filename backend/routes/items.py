from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Item as ItemModel
from models.db_schema import Category as CategoryModel
from models.db_schema import Supplier as SupplierModel
from schemas.item import ItemCreate, ItemOut, ItemJoinedOut
from database.db import get_db
from routes.auth import get_current_user
from models.enum_items import Role
from utils.check_role import check_role

router = APIRouter()

db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[ItemJoinedOut])
async def get_items(db: Session = db_dependency, user: dict = user_dependency):
    items = db.query(
        ItemModel.id,
        ItemModel.name,
        ItemModel.description,
        ItemModel.quantity,
        ItemModel.price,
        ItemModel.category_id,
        ItemModel.supplier_id,
        CategoryModel.name.label("category_name"),
        SupplierModel.name.label("supplier_name"),
    ).join(
        CategoryModel, ItemModel.category_id == CategoryModel.id
    ).join(
        SupplierModel, ItemModel.supplier_id == SupplierModel.id
    ).all()
    
    return items

@router.post("/", response_model=ItemOut, status_code=status.HTTP_201_CREATED)
async def create_item(item: ItemCreate, db: Session = db_dependency, user: dict = user_dependency):
    new_item = ItemModel(**item.model_dump())
    db.add(new_item)
    db.commit()
    db.refresh(new_item)
    return new_item

@router.get("/{item_id}", response_model=ItemOut)
async def get_item(item_id: int, db: Session = db_dependency, user: dict = user_dependency):
    item = db.query(ItemModel).filter(ItemModel.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@router.put("/{item_id}", response_model=ItemOut)
async def update_item(item_id: int, item: ItemCreate, db: Session = db_dependency, user: dict = user_dependency):
    db_item = db.query(ItemModel).filter(ItemModel.id == item_id).first()
    if not db_item:
        raise HTTPException(status_code=404, detail="Item not found")
    for key, value in item.model_dump().items():
        setattr(db_item, key, value)
    db.commit()
    db.refresh(db_item)
    return db_item

@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
@check_role([Role.ADMIN])
async def delete_item(item_id: int, db: Session = db_dependency, user: dict = user_dependency):
    item = db.query(ItemModel).filter(ItemModel.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    db.delete(item)
    db.commit()
    return
