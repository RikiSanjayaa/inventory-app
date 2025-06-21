import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


from sqlalchemy.orm import Session
from db_schema import Users, Category, Supplier, Item, Stock  # assuming your schema is in models.py
from datetime import datetime
from passlib.hash import bcrypt

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = 'sqlite:///database/app.db'

engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={'check_same_thread': False})

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db: Session = SessionLocal()

# Clear existing data (optional, for clean testing)
db.query(Stock).delete()
db.query(Item).delete()
db.query(Supplier).delete()
db.query(Category).delete()
db.query(Users).delete()

# Users
users = [
    Users(username="admin", hashed_password=bcrypt.hash("admin123"), role="admin", is_active=True),
    Users(username="johndoe", hashed_password=bcrypt.hash("password"), role="general-user", is_active=True)
]
db.add_all(users)
db.commit()

# Categories
categories = [
    Category(name="Electronics", description="Electronic gadgets"),
    Category(name="Books", description="Reading materials"),
    Category(name="Clothing", description="Apparel and accessories")
]
db.add_all(categories)
db.commit()

# Suppliers
suppliers = [
    Supplier(name="TechSource", contact_info="tech@source.com"),
    Supplier(name="BookWorld", contact_info="support@bookworld.com"),
    Supplier(name="FashionHub", contact_info="contact@fashionhub.com")
]
db.add_all(suppliers)
db.commit()

# Items
items = [
    Item(name="Laptop", description="Gaming laptop", quantity=50, price=1500.0, category_id=1, supplier_id=1),
    Item(name="Smartphone", description="Latest model", quantity=80, price=999.0, category_id=1, supplier_id=1),
    Item(name="Wireless Mouse", description="Bluetooth mouse", quantity=200, price=25.5, category_id=1, supplier_id=1),
    Item(name="USB-C Charger", description="Fast charger", quantity=150, price=19.99, category_id=1, supplier_id=1),
    Item(name="Novel Book", description="Fiction novel", quantity=120, price=12.0, category_id=2, supplier_id=2),
    Item(name="Textbook", description="Math textbook", quantity=60, price=45.0, category_id=2, supplier_id=2),
    Item(name="Notebook", description="College ruled", quantity=300, price=3.5, category_id=2, supplier_id=2),
    Item(name="T-Shirt", description="Cotton T-shirt", quantity=100, price=10.0, category_id=3, supplier_id=3),
    Item(name="Jeans", description="Blue denim", quantity=70, price=40.0, category_id=3, supplier_id=3),
    Item(name="Jacket", description="Winter jacket", quantity=40, price=60.0, category_id=3, supplier_id=3),
    Item(name="Socks", description="Pair of socks", quantity=500, price=2.0, category_id=3, supplier_id=3)
]
db.add_all(items)
db.commit()

# Stock Movements
movements = [
    Stock(item_id=1, user_id=1, quantity=10, movement_type="in", timestamp=datetime.now()),
    Stock(item_id=2, user_id=2, quantity=5, movement_type="out", timestamp=datetime.now()),
    Stock(item_id=3, user_id=2, quantity=20, movement_type="in", timestamp=datetime.now()),
    Stock(item_id=4, user_id=1, quantity=7, movement_type="out", timestamp=datetime.now()),
    Stock(item_id=5, user_id=1, quantity=15, movement_type="in", timestamp=datetime.now()),
    Stock(item_id=6, user_id=2, quantity=2, movement_type="out", timestamp=datetime.now()),
    Stock(item_id=7, user_id=2, quantity=50, movement_type="in", timestamp=datetime.now()),
    Stock(item_id=8, user_id=1, quantity=6, movement_type="out", timestamp=datetime.now()),
    Stock(item_id=9, user_id=1, quantity=3, movement_type="out", timestamp=datetime.now()),
    Stock(item_id=10, user_id=2, quantity=25, movement_type="in", timestamp=datetime.now()),
    Stock(item_id=11, user_id=1, quantity=100, movement_type="in", timestamp=datetime.now())
]
db.add_all(movements)
db.commit()

print("Dummy data inserted successfully.")
