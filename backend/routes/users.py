from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Users
from schemas.user import UserOut
from database.db import get_db
from routes.auth import get_current_user

router = APIRouter()

db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[UserOut])
async def get_users(db: Session = db_dependency, user: dict = user_dependency):
    return db.query(Users).all()