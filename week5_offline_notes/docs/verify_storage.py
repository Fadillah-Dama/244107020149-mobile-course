"""Verifikasi SQL modul dan usulan migrasi, hanya pada SQLite in-memory.

Jalankan dari root proyek: python docs/verify_storage.py
"""

from datetime import datetime, timedelta
from pathlib import Path
import re
import sqlite3


source = (Path(__file__).resolve().parents[1] / "lib/data/local/db.dart").read_text()
statements = re.findall(r"db.execute\('''(.*?)'''\)", source, re.S)
assert len(statements) == 2, "Skema modul berubah; periksa ulang script verifikasi."

with sqlite3.connect(":memory:") as db:
    for sql in statements:
        db.execute(sql)
    start = datetime(2026, 10, 5)
    db.executemany(
        "INSERT INTO notes(title, body, updated_at, dirty) VALUES (?, ?, ?, ?)",
        [
            (f"Catatan {i}", f"Isi {i}", (start + timedelta(seconds=i)).isoformat(), int(i % 3 == 0))
            for i in range(1200)
        ],
    )
    db.commit()
    assert db.execute("SELECT COUNT(*) FROM notes").fetchone()[0] == 1200
    assert db.execute("SELECT COUNT(*) FROM notes WHERE dirty = 1").fetchone()[0] == 400
    assert db.execute("SELECT title FROM notes ORDER BY updated_at DESC LIMIT 1").fetchone()[0] == "Catatan 1199"
    print("PASS: 1200 catatan, 400 dirty, urutan updated_at benar")

    before = db.execute("SELECT * FROM notes ORDER BY id").fetchall()
    # Usulan migrasi; tidak mengubah version atau database aplikasi Flutter.
    with db:
        db.execute("ALTER TABLE notes ADD COLUMN pinned INTEGER NOT NULL DEFAULT 0")
        db.execute("CREATE INDEX idx_notes_updated ON notes(updated_at DESC, id DESC)")
        db.execute("CREATE INDEX idx_notes_dirty_updated ON notes(dirty, updated_at, id)")
    after = db.execute("SELECT id, title, body, updated_at, dirty FROM notes ORDER BY id").fetchall()
    assert before == after
    assert db.execute("SELECT COUNT(*) FROM notes WHERE pinned = 0").fetchone()[0] == 1200
    print("PASS: migrasi pinned dan indeks mempertahankan 1200 catatan")

    db.execute("INSERT INTO cached_posts VALUES (1, 'cache lama', '2026-10-05')")
    db.commit()
    try:
        with db:
            db.execute("DELETE FROM cached_posts")
            db.execute("INSERT INTO cached_posts VALUES (2, 'baru', '2026-10-05')")
            db.execute("INSERT INTO cached_posts VALUES (2, 'duplikat', '2026-10-05')")
    except sqlite3.IntegrityError:
        pass
    else:
        raise AssertionError("Insert duplikat seharusnya gagal")
    assert db.execute("SELECT payload FROM cached_posts").fetchall() == [("cache lama",)]
    print("PASS: kegagalan penggantian cache memulihkan cache lama")

print(f"SQLite {sqlite3.sqlite_version}: seluruh pemeriksaan lulus")
