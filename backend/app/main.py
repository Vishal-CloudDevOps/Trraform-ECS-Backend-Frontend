from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import psycopg2
import psycopg2.extras
import os

# --- FastAPI app ---
app = FastAPI(
    title="Demo CRUD API",
    version="1.0.0",
    root_path="/api"   # 👈 ensures all routes are under /api/*
)

# --- CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- DB Connection ---
def get_db():
    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST"),
        port=os.environ.get("DB_PORT", 5432),
        dbname=os.environ.get("DB_NAME", "demodb"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASSWORD"),
        cursor_factory=psycopg2.extras.RealDictCursor
    )
    try:
        yield conn
    finally:
        conn.close()

# --- Schema ---
class ItemBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    in_stock: bool = True

class ItemCreate(ItemBase):
    pass

class ItemUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    in_stock: Optional[bool] = None

class Item(ItemBase):
    id: int

# --- Init DB ---
@app.on_event("startup")
def startup():
    import time
    for attempt in range(10):
        try:
            conn = psycopg2.connect(
                host=os.environ.get("DB_HOST"),
                port=os.environ.get("DB_PORT", 5432),
                dbname=os.environ.get("DB_NAME", "demodb"),
                user=os.environ.get("DB_USER"),
                password=os.environ.get("DB_PASSWORD"),
            )
            cur = conn.cursor()
            cur.execute("""
                CREATE TABLE IF NOT EXISTS items (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    description TEXT,
                    price NUMERIC(10,2) NOT NULL,
                    in_stock BOOLEAN DEFAULT TRUE
                )
            """)
            conn.commit()
            cur.close()
            conn.close()
            print("DB initialized successfully.")
            break
        except Exception as e:
            print(f"DB not ready (attempt {attempt+1}/10): {e}")
            time.sleep(3)

# --- Routes ---
@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/items", response_model=List[Item])
def list_items(db=Depends(get_db)):
    cur = db.cursor()
    cur.execute("SELECT * FROM items ORDER BY id")
    rows = cur.fetchall()
    return [Item(**row) for row in rows]

@app.post("/items", response_model=Item, status_code=201)
def create_item(item: ItemCreate, db=Depends(get_db)):
    cur = db.cursor()
    cur.execute(
        "INSERT INTO items (name, description, price, in_stock) VALUES (%s, %s, %s, %s) RETURNING *",
        (item.name, item.description, item.price, item.in_stock)
    )
    db.commit()
    row = cur.fetchone()
    return Item(**row)

@app.get("/items/{item_id}", response_model=Item)
def get_item(item_id: int, db=Depends(get_db)):
    cur = db.cursor()
    cur.execute("SELECT * FROM items WHERE id = %s", (item_id,))
    row = cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Item not found")
    return Item(**row)

@app.put("/items/{item_id}", response_model=Item)
def update_item(item_id: int, item: ItemUpdate, db=Depends(get_db)):
    cur = db.cursor()
    cur.execute("SELECT * FROM items WHERE id = %s", (item_id,))
    if not cur.fetchone():
        raise HTTPException(status_code=404, detail="Item not found")
    fields = {k: v for k, v in item.dict().items() if v is not None}
    if not fields:
        raise HTTPException(status_code=400, detail="No fields to update")
    set_clause = ", ".join(f"{k} = %s" for k in fields)
    values = list(fields.values()) + [item_id]
    cur.execute(f"UPDATE items SET {set_clause} WHERE id = %s RETURNING *", values)
    db.commit()
    row = cur.fetchone()
    return Item(**row)

@app.delete("/items/{item_id}", status_code=204)
def delete_item(item_id: int, db=Depends(get_db)):
    cur = db.cursor()
    cur.execute("DELETE FROM items WHERE id = %s RETURNING id", (item_id,))
    if not cur.fetchone():
        raise HTTPException(status_code=404, detail="Item not found")
    db.commit()

# Root route
@app.get("/")
def read_root():
    return {"message": "Backend is alive!"}