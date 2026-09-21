"""Local SQLite storage with WAL mode, write-first ordering, and pending queue."""
import json
import sqlite3
from datetime import datetime, timezone
from typing import Optional, Iterable, List, Dict, Any
from .models import Sample, Decision

class LocalStore:
    def __init__(self, path: str = "edge_monitor.db"):
        self.path = path
        self.db = sqlite3.connect(path, check_same_thread=False)
        self.db.execute("PRAGMA journal_mode=WAL")
        self._init_schema()

    def _init_schema(self):
        self.db.execute("""
            CREATE TABLE IF NOT EXISTS observations (
                event_id TEXT PRIMARY KEY,
                device_id TEXT NOT NULL,
                event_time TEXT NOT NULL,
                sensor TEXT NOT NULL,
                raw_value REAL,
                processed_value REAL,
                unit TEXT NOT NULL,
                quality_status TEXT NOT NULL,
                quality_score REAL NOT NULL,
                baseline REAL,
                deviation REAL,
                severity TEXT NOT NULL,
                confidence TEXT NOT NULL,
                anomaly_score REAL,
                reason_codes TEXT NOT NULL,
                explanation TEXT NOT NULL,
                sync_status TEXT NOT NULL DEFAULT 'PENDING',
                created_at TEXT NOT NULL,
                is_fixture INTEGER NOT NULL DEFAULT 0
            )
        """)
        self.db.execute("""
            CREATE TABLE IF NOT EXISTS sync_attempts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                attempted_at TEXT NOT NULL,
                sent_count INTEGER NOT NULL,
                result TEXT NOT NULL,
                error_category TEXT
            )
        """)
        self.db.commit()

    def add(self, event_id: str, device_id: str, sample: Sample, decision: Decision, is_fixture: bool = False) -> None:
        now = datetime.now(timezone.utc).isoformat()
        self.db.execute("""
            INSERT OR IGNORE INTO observations (
                event_id, device_id, event_time, sensor, raw_value, processed_value, unit,
                quality_status, quality_score, baseline, deviation, severity, confidence,
                anomaly_score, reason_codes, explanation, sync_status, created_at, is_fixture
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?, ?)
        """, (
            event_id, device_id, sample.event_time, sample.sensor, sample.value,
            decision.processed_value, sample.unit, decision.quality_status,
            decision.quality_score, decision.baseline, decision.deviation,
            decision.severity, decision.confidence, decision.anomaly_score,
            json.dumps(decision.reason_codes), decision.explanation, now, 1 if is_fixture else 0
        ))
        self.db.commit()

    def pending(self, limit: int = 50) -> List[Dict[str, Any]]:
        cur = self.db.execute(
            "SELECT * FROM observations WHERE sync_status='PENDING' ORDER BY event_time ASC LIMIT ?",
            (limit,)
        )
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
        result = []
        for r in rows:
            d = dict(zip(cols, r))
            d["reason_codes"] = json.loads(d["reason_codes"]) if d["reason_codes"] else []
            d["is_fixture"] = bool(d["is_fixture"])
            result.append(d)
        return result

    def mark_synced(self, event_ids: Iterable[str]) -> None:
        self.db.executemany(
            "UPDATE observations SET sync_status='SYNCHRONIZED' WHERE event_id=?",
            [(eid,) for eid in event_ids]
        )
        self.db.commit()

    def record_sync(self, sent_count: int, result: str, error_category: Optional[str] = None) -> None:
        self.db.execute(
            "INSERT INTO sync_attempts (attempted_at, sent_count, result, error_category) VALUES (?, ?, ?, ?)",
            (datetime.now(timezone.utc).isoformat(), sent_count, result, error_category)
        )
        self.db.commit()

    def count_pending(self) -> int:
        cur = self.db.execute("SELECT COUNT(*) FROM observations WHERE sync_status='PENDING'")
        return cur.fetchone()[0]

    def count_total(self) -> int:
        cur = self.db.execute("SELECT COUNT(*) FROM observations")
        return cur.fetchone()[0]

    def close(self):
        self.db.close()
