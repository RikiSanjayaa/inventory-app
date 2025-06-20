from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Supplier as SupplierModel
from schemas.supplier import SupplierCreate, SupplierOut
from database.db import get_db
from routes.auth import get_current_user
from models.enum_items import Role
from utils.check_role import check_role

router = APIRouter()

db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[SupplierOut])
async def get_suppliers(db: Session = db_dependency, user: dict = user_dependency):
    return db.query(SupplierModel).all()

@router.post("/", response_model=SupplierOut, status_code=status.HTTP_201_CREATED)
@check_role([Role.ADMIN])
async def create_supplier(supplier: SupplierCreate, db: Session = db_dependency, user: dict = user_dependency):
    new_supplier = SupplierModel(**supplier.model_dump())
    db.add(new_supplier)
    db.commit()
    db.refresh(new_supplier)
    return new_supplier

@router.get("/{supplier_id}", response_model=SupplierOut)
async def get_supplier(supplier_id: int, db: Session = db_dependency, user: dict = user_dependency):
    supplier = db.query(SupplierModel).filter(SupplierModel.id == supplier_id).first()
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    return supplier

@router.put("/{supplier_id}", response_model=SupplierOut)
@check_role([Role.ADMIN])
async def update_supplier(supplier_id: int, supplier: SupplierCreate, db: Session = db_dependency, user: dict = user_dependency):
    db_supplier = db.query(SupplierModel).filter(SupplierModel.id == supplier_id).first()
    if not db_supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    for key, value in supplier.model_dump().items():
        setattr(db_supplier, key, value)
    db.commit()
    db.refresh(db_supplier)
    return db_supplier

@router.delete("/{supplier_id}", status_code=status.HTTP_204_NO_CONTENT)
@check_role([Role.ADMIN])
async def delete_supplier(supplier_id: int, db: Session = db_dependency, user: dict = user_dependency):
    supplier = db.query(SupplierModel).filter(SupplierModel.id == supplier_id).first()
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    db.delete(supplier)
    db.commit()
    return