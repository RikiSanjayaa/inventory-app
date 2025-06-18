# 🧾 FastAPI Inventory Management Backend

This is a backend API for a multi-user **inventory management system** built with **FastAPI**, **SQLAlchemy**, and **SQLite**. It features reusable components and supports full CRUD operations with user roles and token-based authentication.

---

## 🚀 Quickstart

### 1. **Install dependencies**

```bash
pip install -r requirements.txt
```

### 2. **Run the API server**

```bash
python main.py
```

---

## 🛠️ Features

- ✅ JWT-based user authentication
- ✅ Role-based access (admin/user)
- ✅ CRUD operations for:
  - Users
  - Items
  - Categories
  - Suppliers
  - Stock movements (in/out)
- ✅ SQLite support for local dev
- ✅ Modular route structure

---

## 🔐 Authentication

### Register:

`POST /auth/register`

```json
{
  "username": "admin",
  "password": "secret"
}
```

### Login:

`POST /auth/login`

```json
{
  "username": "admin",
  "password": "secret"
}
```

Returns an access token.

### Use Token:

Pass it in headers:

```http
Authorization: Bearer <token>
```

---

## 📦 API Endpoints

### 🔹 Items

| Method | Endpoint      | Auth Required | Role  |
| ------ | ------------- | ------------- | ----- |
| GET    | `/items/`     | ✅            | Any   |
| POST   | `/items/`     | ✅            | Admin |
| PUT    | `/items/{id}` | ✅            | Admin |
| DELETE | `/items/{id}` | ✅            | Admin |

### 🔹 Categories

Similar to items (`/categories/...`)

### 🔹 Suppliers

Similar to items (`/suppliers/...`)

### 🔹 Stock

| Method | Endpoint  | Description            |
| ------ | --------- | ---------------------- |
| GET    | `/stock/` | View all stock records |
| POST   | `/stock/` | Add new stock movement |

---

## 🧠 Tech Stack

- **FastAPI** – web framework
- **SQLAlchemy** – ORM
- **SQLite** – development DB (switchable)
- **JWT** – authentication
- **Pydantic** – schema validation

---

## 📌 Next Steps

- Add inventory summary endpoint per item
- Add pagination + filters
- Add Swagger security scheme

---

## 🧑‍💻 Author

You, the backend rockstar ⚡
