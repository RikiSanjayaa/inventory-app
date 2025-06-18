from database.db import Base
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
  
class Users(Base):
  __tablename__ = 'users'
  id = Column(Integer, primary_key=True, index=True)
  username = Column(String, unique=True)
  hashed_password = Column(String)
  role = Column(String) # USER or ADMIN
  
class Category(Base):
  __tablename__ = 'categories'

  id = Column(Integer, primary_key=True, index=True)
  name = Column(String, unique=True, nullable=False)
  description = Column(String, nullable=True)
    
class Supplier(Base):
  __tablename__ = 'suppliers'

  id = Column(Integer, primary_key=True, index=True)
  name = Column(String, unique=True, nullable=False)
  contact_info = Column(String, nullable=True)

class Item(Base):
  __tablename__ = 'items'

  id = Column(Integer, primary_key=True, index=True)
  name = Column(String, unique=True, nullable=False)
  description = Column(String, nullable=True)
  quantity = Column(Integer, default=0)
  price = Column(Float, nullable=False)

  category_id = Column(Integer, ForeignKey("categories.id"))
  supplier_id = Column(Integer, ForeignKey("suppliers.id"))

  # Optional relationships
  category = relationship("Category")
  supplier = relationship("Supplier")

class Stock(Base):
  __tablename__ = 'stock_movements'

  id = Column(Integer, primary_key=True, index=True)
  item_id = Column(Integer, ForeignKey("items.id"))
  user_id = Column(Integer, ForeignKey("users.id"))
  quantity = Column(Integer)
  movement_type = Column(String) # IN or OUT
  timestamp = Column(DateTime, default=datetime.now)

  item = relationship("Item")