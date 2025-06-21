from fastapi import APIRouter, Depends, HTTPException, status, Response
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Users
from schemas.user import UserOut, UserRoleUpdate, UserStatusUpdate
from database.db import get_db
from routes.auth import get_current_user
from models.enum_items import Role
from utils.check_role import check_role

router = APIRouter()

db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[UserOut])
async def get_users(db: Session = db_dependency, user: dict = user_dependency):
    return db.query(Users).all()
  

@router.put("/{user_id}/role")
async def update_user_role(
    user_id: int,
    role_update: UserRoleUpdate,
    db: Session = db_dependency,
    current_user: dict = user_dependency
):
    # Get target user
    user = db.query(Users).filter(Users.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Prevent modifying admin users
    if user.role == Role.ADMIN.value:
        raise HTTPException(
            status_code=403,
            detail="Cannot modify admin user's role"
        )
    
    # Update role
    user.role = role_update.role
    db.commit()
    return {"message": "Role updated successfully"}

@router.put("/{user_id}/status")
async def update_user_status(
    user_id: int,
    status_update: UserStatusUpdate,
    db: Session = db_dependency,
    current_user: dict = user_dependency
):
    # Get target user
    user = db.query(Users).filter(Users.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Prevent modifying admin users
    if user.role == Role.ADMIN.value:
        raise HTTPException(
            status_code=403,
            detail="Cannot modify admin user's status"
        )
    
    # Update status
    user.is_active = status_update.is_active
    db.commit()
    return {"message": "Status updated successfully"}

@router.delete("/{user_id}")
async def delete_user(
    user_id: int,
    db: Session = db_dependency,
    current_user: dict = user_dependency
):
    # Get target user
    user = db.query(Users).filter(Users.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Prevent deleting admin users
    if user.role == Role.ADMIN.value:
        raise HTTPException(
            status_code=403,
            detail="Cannot delete admin users"
        )
    
    # Delete user
    db.delete(user)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)