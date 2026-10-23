import sqlite3
import json
import os
import logging
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "anvaya_produce.db")

def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS batches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        batch_id TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity TEXT NOT NULL,
        price TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        condition TEXT,
        confidence REAL,
        visible_issues TEXT,
        location TEXT,
        description TEXT,
        type TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)
    conn.commit()

    # Seed initial batches if empty so Produce History starts with reference records
    cursor.execute("SELECT COUNT(*) FROM batches")
    count = cursor.fetchone()[0]
    if count == 0:
        initial_batches = [
            (
                "Batch #AG-8291",
                "Organic Arabica Coffee",
                "Coffee",
                "250 kg",
                "$14.20",
                "Oct 24, 2023 • 09:45 AM",
                "VERIFIED",
                "fresh",
                0.96,
                json.dumps([]),
                "Highland Estate, Block 4",
                "Grade A single-origin organic arabica beans.",
                "coffee",
            ),
            (
                "Batch #AG-7422",
                "Golden Manuka Honey",
                "Honey",
                "120 jars",
                "$28.50",
                "Oct 23, 2023 • 02:15 PM",
                "PENDING",
                None,
                None,
                json.dumps([]),
                "Apiary Ridge, Zone 2",
                "Raw unpasteurized certified manuka honey.",
                "honey",
            ),
            (
                "Batch #AG-1104",
                "Fresh Baby Spinach",
                "Vegetables",
                "85 kg",
                "$3.80",
                "Oct 21, 2023 • 08:30 AM",
                "REJECTED",
                "damaged",
                0.88,
                json.dumps(["Wilting", "Excessive moisture"]),
                "Green Valley Farm, Sector B",
                "Leafy produce failed post-harvest check.",
                "spinach",
            ),
            (
                "Batch #AG-0922",
                "Premium Robusta Coffee",
                "Coffee",
                "400 kg",
                "$9.50",
                "Oct 19, 2023 • 11:20 AM",
                "VERIFIED",
                "fresh",
                0.92,
                json.dumps([]),
                "South Ridge Farm, Plot 1",
                "Sun-dried robusta beans for espresso blending.",
                "coffee",
            ),
            (
                "Batch #AG-0881",
                "Wildflower Honey",
                "Honey",
                "90 jars",
                "$16.00",
                "Oct 15, 2023 • 04:10 PM",
                "VERIFIED",
                "fresh",
                0.94,
                json.dumps([]),
                "Meadow Hives, Station 3",
                "Seasonal pure wildflower honey.",
                "honey",
            ),
        ]
        cursor.executemany("""
        INSERT INTO batches (
            batch_id, title, category, quantity, price, date, status,
            condition, confidence, visible_issues, location, description, type
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, initial_batches)
        conn.commit()
        logger.info("Initialized and seeded batches database with reference records.")

    conn.close()

def get_all_batches() -> List[Dict[str, Any]]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM batches ORDER BY id DESC")
    rows = cursor.fetchall()
    batches = []
    for row in rows:
        b = dict(row)
        if b.get("visible_issues"):
            try:
                b["visible_issues"] = json.loads(b["visible_issues"])
            except Exception:
                b["visible_issues"] = []
        else:
            b["visible_issues"] = []
        batches.append(b)
    conn.close()
    return batches

def insert_batch(batch_data: Dict[str, Any]) -> Dict[str, Any]:
    conn = get_db_connection()
    cursor = conn.cursor()
    
    issues_json = json.dumps(batch_data.get("visible_issues", []))
    cursor.execute("""
    INSERT INTO batches (
        batch_id, title, category, quantity, price, date, status,
        condition, confidence, visible_issues, location, description, type
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        batch_data["batch_id"],
        batch_data["title"],
        batch_data.get("category", "Vegetables"),
        batch_data.get("quantity", "100 kg"),
        batch_data.get("price", "$4.50"),
        batch_data["date"],
        batch_data.get("status", "VERIFIED"),
        batch_data.get("condition"),
        batch_data.get("confidence"),
        issues_json,
        batch_data.get("location", "Green Valley Farm"),
        batch_data.get("description", ""),
        batch_data.get("type", "vegetables"),
    ))
    conn.commit()
    inserted_id = cursor.lastrowid
    cursor.execute("SELECT * FROM batches WHERE id = ?", (inserted_id,))
    row = cursor.fetchone()
    result = dict(row)
    if result.get("visible_issues"):
        try:
            result["visible_issues"] = json.loads(result["visible_issues"])
        except Exception:
            result["visible_issues"] = []
    else:
        result["visible_issues"] = []
    conn.close()
    return result
