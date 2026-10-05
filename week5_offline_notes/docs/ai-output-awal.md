# Output Awal AI — Perbandingan Storage

Dokumen ini menyimpan usulan awal Codex untuk prompt pada [ai-prompt.md](ai-prompt.md). Penilaian akhir dan batas verifikasinya dicatat terpisah di lembar kerja.

| Pilihan | Kelebihan untuk kebutuhan ini | Trade-off | Rekomendasi awal |
| --- | --- | --- | --- |
| SharedPreferences | Penyimpanan nilai kecil dengan API sederhana | Tidak menyediakan query koleksi dan relasi | Pilih untuk tema dan waktu terakhir dibuka |
| Hive | Box dengan akses per key; dapat menyimpan objek melalui adapter | Filter, urutan, dan hubungan antardata perlu dirancang di aplikasi | Alternatif untuk koleksi sederhana |
| sqflite | SQL, transaksi, filter dirty, serta pengurutan catatan | Mapping Map ke model dan pembaruan state dikerjakan manual | Pilih untuk catatan dan cache posts pada praktikum |
| Drift | Query bertipe dan stream hasil query di atas SQLite | Memerlukan setup generator dan pengelolaan migrasi | Pertimbangkan saat kebutuhan query dan reaktivitas bertambah |

Usulan struktur untuk 1000+ catatan: satu baris per catatan dengan `id`, `title`, `body`, `updated_at`, dan `dirty`. Tambahkan indeks untuk pengurutan waktu dan pemilihan catatan dirty; ambil daftar per halaman. Jika menggunakan Hive, gunakan satu key per ID catatan dalam `Box<Note>`, bukan satu key berisi seluruh daftar.

Untuk relasi seperti catatan dan tag, sqflite/Drift dapat memakai tabel penghubung. Pada Hive, simpan ID referensi dan kelola konsistensinya di kode. Pada SharedPreferences, koleksi catatan sebagai satu JSON akan menyulitkan perubahan sebagian data.

Kesimpulan awal AI: pertahankan SharedPreferences + sqflite untuk proyek ini. Jumlah 1000 catatan saja belum cukup untuk menyatakan satu storage paling cepat; perlu mengukur ukuran isi catatan, pola akses, dan perangkat yang digunakan.

Rujukan usulan: dokumentasi [SharedPreferences](https://pub.dev/packages/shared_preferences), [Hive](https://pub.dev/packages/hive), [sqflite](https://pub.dev/packages/sqflite), serta [setup Drift](https://drift.simonbinder.eu/setup/). Ini adalah rekomendasi teknis, bukan hasil benchmark keempat paket.
