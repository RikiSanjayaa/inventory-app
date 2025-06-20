from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Category as CategoryModel
from schemas.category import CategoryCreate, CategoryOut
from database.db import get_db
from routes.auth import get_current_user
from models.enum_items import Role
from utils.check_role import check_role

router = APIRouter()

db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[CategoryOut])
async def get_categories(db: Session = db_dependency, user: dict = user_dependency):
    return db.query(CategoryModel).all()

@router.post("/", response_model=CategoryOut, status_code=status.HTTP_201_CREATED)
@check_role([Role.ADMIN])
async def create_category(category: CategoryCreate, db: Session = db_dependency, user: dict = user_dependency):
    new_category = CategoryModel(**category.model_dump())
    db.add(new_category)
    db.commit()
    db.refresh(new_category)
    return new_category

@router.get("/{category_id}", response_model=CategoryOut)
async def get_category(category_id: int, db: Session = db_dependency, user: dict = user_dependency):
    category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category

@router.put("/{category_id}", response_model=CategoryOut)
@check_role([Role.ADMIN])
async def update_category(category_id: int, category: CategoryCreate, db: Session = db_dependency, user: dict = user_dependency):
    db_category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not db_category:
        raise HTTPException(status_code=404, detail="Category not found")
    for key, value in category.model_dump().items():
        setattr(db_category, key, value)
    db.commit()
    db.refresh(db_category)
    return db_category

@router.delete("/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
@check_role([Role.ADMIN])
async def delete_category(category_id: int, db: Session = db_dependency, user: dict = user_dependency):
    category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    db.delete(category)
    db.commit()
    return
