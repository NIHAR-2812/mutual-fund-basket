import json
import os
import sqlite3
from contextlib import contextmanager
from pathlib import Path

DB = Path(os.getenv('DATABASE_PATH', str(Path(__file__).parent.parent / 'basket.sqlite3')))

@contextmanager
def connection():
    DB.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(DB, timeout=10)
    db.row_factory = sqlite3.Row
    try:
        db.execute('PRAGMA foreign_keys = ON')
        yield db
        db.commit()
    finally:
        db.close()

def initialize():
    with connection() as db:
        db.execute('CREATE TABLE IF NOT EXISTS funds (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, three_year_return REAL NOT NULL, expense_ratio REAL NOT NULL, risk_level TEXT NOT NULL)')
        db.execute('CREATE TABLE IF NOT EXISTS basket (user_id TEXT NOT NULL, fund_id INTEGER NOT NULL REFERENCES funds(id), PRIMARY KEY(user_id, fund_id))')
        if db.execute('SELECT COUNT(*) FROM funds').fetchone()[0] == 0:
            data = json.loads((Path(__file__).parent / 'funds.json').read_text())
            db.executemany('INSERT INTO funds VALUES (:id,:name,:category,:three_year_return,:expense_ratio,:risk_level)', data)
