# Lembar Kerja — Tabel Perbandingan Storage

Saya membandingkan storage untuk dua kebutuhan: preferensi kecil dan koleksi catatan yang dapat diubah saat offline. Saya menggunakan kode proyek, dokumentasi resmi, dan pengujian sebagai dasar keputusan. Penilaian boilerplate di bawah bersifat kualitatif.

| Kriteria | SharedPreferences | Hive | sqflite | Drift |
| --- | --- | --- | --- | --- |
| Kompleksitas query | Baca/tulis per key; tanpa SQL | Akses key; filter dan sort koleksi melalui kode Dart | SQL untuk filter, sort, join, agregasi, dan pagination | Query Dart/SQL dengan pemeriksaan tipe dan generator |
| Dukungan relasi | Tidak tersedia | Referensi antarobjek dikelola aplikasi; tanpa SQL join | Foreign key dan tabel penghubung; penegakan FK perlu dikonfigurasi | Relasi melalui skema SQLite dan query join |
| Reaktivitas (stream) | Pada kode saya, perubahan UI melalui provider | `Box.watch()` menghasilkan event perubahan; daftar perlu dibaca/diolah lagi | Pada kode saya, query Future diulang melalui invalidate | `watch()` menghasilkan stream hasil query yang diperbarui |
| Type-safety | Getter/setter tipe primitif; key berupa string | `Box<T>` dan adapter objek membantu; key/skema tetap perlu disiplin | Model Dart bertipe, tetapi SQL dan Map perlu mapping/cast manual | Model serta query dihasilkan dengan tipe; kesalahan skema/query dapat diperiksa saat build |
| Ukuran boilerplate | Kecil untuk dua preferensi saya | Kecil untuk primitif, bertambah untuk adapter dan perubahan model | Sedang: SQL, model, repository, invalidasi dan migrasi manual | Setup awal lebih banyak; generator mengurangi mapping manual |
| Kemudahan testing | Bisa mock nilai awal atau override repository | Bisa memakai direktori box sementara atau fake repository | Fake untuk provider; database sungguhan/FFI untuk menguji SQL | Database in-memory dan fasilitas pengujian migrasi |
| Cocok untuk preferensi? | Ya, pilihan saya | Ya, terutama bila Hive sudah digunakan | Bisa, tetapi berlebihan untuk dua key | Bisa, tetapi setup terlalu besar untuk dua key saja |
| Cocok untuk 1000+ catatan? | Tidak saya pilih untuk koleksi | Bisa; evaluasi biaya filter dan sort sesuai pola akses | Ya, dengan indeks dan pagination sesuai kebutuhan | Ya, dengan indeks, pagination dan stream sesuai kebutuhan |
| Keputusan & alasan | Saya pilih untuk tema dan waktu terakhir dibuka | Saya tidak memilihnya karena query dirty dan urutan lebih mudah dinyatakan dengan SQL | Saya pilih untuk catatan dan cache posts; sudah sesuai arsitektur praktikum | Saya pertimbangkan bila query, relasi, dan reaktivitas proyek bertambah kompleks |

Dasar fakta: [tipe dan batas SharedPreferences](https://pub.dev/packages/shared_preferences), [API Box Hive](https://pub.dev/documentation/hive/latest/hive/Box-class.html), [event Hive watch](https://pub.dev/documentation/hive/latest/hive/BoxBase/watch.html), [operasi sqflite](https://pub.dev/packages/sqflite), [stream Drift](https://drift.simonbinder.eu/dart_api/streams/), [setup Drift](https://drift.simonbinder.eu/setup/), serta [testing Drift](https://drift.simonbinder.eu/testing/). Saya membandingkan Hive klasik dengan API box, bukan menganggap semua fork/versi Hive memiliki API yang sama.

## Skema untuk 1000+ catatan

Saya mempertahankan struktur per catatan berikut. Dua indeks dan pagination merupakan usulan pengembangan; skema aplikasi saat ini masih versi 1 dari modul.

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_notes_updated ON notes(updated_at DESC, id DESC);
CREATE INDEX idx_notes_dirty_updated ON notes(dirty, updated_at, id);

-- Halaman awal, misalnya 50 catatan.
SELECT * FROM notes ORDER BY updated_at DESC, id DESC LIMIT 50;

-- Halaman berikutnya berdasarkan catatan terakhir halaman sebelumnya.
SELECT * FROM notes
WHERE updated_at < ? OR (updated_at = ? AND id < ?)
ORDER BY updated_at DESC, id DESC LIMIT 50;
```

Untuk skema yang dikembangkan lintas perangkat, saya akan memakai waktu UTC dengan format konsisten agar urutan teks tidak mencampur zona waktu. Jika memakai Drift, field dan indeks yang sama dapat dinyatakan sebagai tabel Drift. Jika memakai Hive, rancangan alternatif saya adalah `Box<Note>` dengan key ID dan field `title`, `body`, `updatedAt`, serta `dirty`; pemilihan dirty dan pagination memerlukan logika tambahan.

`dirty` dan `updated_at` mendukung antrean sederhana dan perbandingan versi. Keduanya belum menyelesaikan upload bersamaan atau penghapusan lintas perangkat. Untuk backend nyata, saya akan menandai bersih berdasarkan ID + versi yang diunggah dan menambahkan tombstone/outbox. Kode praktikum masih memakai `markAllSynced()` dan penghapusan langsung.

## Verifikasi dan keputusan akhir saya

1. Saya menolak penyimpanan seluruh daftar catatan sebagai JSON di SharedPreferences. Preferensi tetap memakai dua key, sedangkan catatan memakai baris SQLite.
2. Saya memeriksa `Note.toMap()`, skema `notes`, dan `syncNotes()`: field dirty dan waktu pembaruan tersedia, tetapi sinkronisasi masih simulasi.
3. Saya tidak menyebut sqflite dalam proyek ini otomatis real-time. UI diperbarui lewat invalidate. Drift menyediakan stream query, sedangkan Hive menyediakan event perubahan box; keduanya tidak otomatis berarti sinkronisasi server.
4. Saya memeriksa paket yang terpasang dan berhasil menambahkan GoRouter. Untuk SQL, saya menjalankan [percobaan in-memory](verify_storage.py) berisi 1.200 catatan, penambahan kolom `pinned`, indeks, dan rollback cache. Ini menguji SQL, belum menguji callback `onUpgrade` di Android. Hive dan Drift saya bandingkan melalui dokumentasi; saya belum menginstal atau mengukur keduanya sehingga tidak mengklaim angka performa maupun jumlah baris kode yang pasti.
5. Pilihan akhir saya adalah **SharedPreferences untuk preferensi + sqflite untuk catatan dan cache posts**. Alasannya adalah kebutuhan query yang jelas, transaksi untuk cache, dan kesesuaian dengan repository yang sudah dibuat. Saya menerima biaya mapping dan invalidasi manual sebagai bagian dari keputusan ini.

Catatan API: proyek mengikuti `SharedPreferences.getInstance()` dari modul. Dokumentasi paket menyarankan API Async/WithCache untuk penggunaan baru; saya mencatatnya sebagai bahan pengembangan, bukan menganggap API modul satu-satunya pilihan.

Hasil perintah dan batas pengujian saya catat di [hasil-verifikasi.md](hasil-verifikasi.md).
