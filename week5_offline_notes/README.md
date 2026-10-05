# Offline Notes — Praktikum Minggu 5

Saya membuat aplikasi catatan lokal untuk mempelajari SharedPreferences, SQLite, Riverpod, dan pola offline-first. Aplikasi menyimpan preferensi tema, melakukan CRUD catatan, serta menyimpan cache posts agar dapat dibaca tanpa koneksi setelah pernah dimuat.

## Fitur dan teknologi

- SharedPreferences: tema dan waktu terakhir dibuka.
- sqflite: tabel `notes` dan `cached_posts`.
- Riverpod: state loading/error/data dan invalidasi setelah perubahan.
- Dio: pengambilan posts dari JSONPlaceholder.
- GoRouter: halaman utama, detail `/note/:id`, posts, dan pengaturan.
- NoteTile: badge **belum tersinkron** pada catatan dirty.
- Sync simulasi: penolakan melalui saklar **Paksa mode offline** dan pembersihan flag dirty.

## Menjalankan dan menguji

```sh
flutter pub get
flutter devices
flutter run -d <id-perangkat-android>
flutter analyze
flutter test
python docs/verify_storage.py
```

Saya menggunakan target Android sesuai modul. Konfigurasi sqflite proyek belum menyediakan implementasi web untuk Chrome. Buka Posts sekali saat online untuk mengisi cache; setelah itu ikuti [langkah uji offline](docs/uji-offline.md).

Ketuk catatan untuk membuka detail yang dibaca langsung dari repository berdasarkan ID. Gunakan **Ubah catatan** di halaman detail untuk mengedit. Pengaturan tema tetap mengikuti preferensi yang tersimpan.

## AI Verification Checklist

| Pemeriksaan | Temuan dan keputusan saya |
| --- | --- |
| Apakah daftar catatan ditempatkan di SharedPreferences? | Tidak. Saya menerima usulan dua key untuk preferensi dan tabel SQLite untuk koleksi; satu JSON besar akan menyulitkan update sebagian dan query. |
| Apakah skema mendukung antrean sync? | Ada `dirty` dan `updated_at`. Ini cukup untuk simulasi antrean, tetapi belum menyelesaikan konflik upload bersamaan dan propagasi penghapusan. |
| Apakah klaim real-time didukung stream? | Drift memiliki stream query `watch()`, Hive memiliki event `Box.watch()`. Proyek sqflite saya menggunakan invalidate provider, bukan stream database otomatis. |
| Apakah estimasi boilerplate terverifikasi? | Saya memeriksa implementasi yang ada, memasang GoRouter, dan menguji SQL migrasi in-memory. Instalasi/migrasi Hive dan Drift belum dicoba; penilaian keduanya bersifat kualitatif dari dokumentasi, bukan pengukuran langsung. |
| Keputusan akhir | SharedPreferences untuk preferensi, sqflite untuk catatan dan cache. Saya memilih query SQL dan transaksi dengan biaya mapping/invalidation manual yang masih dapat dikelola. |

Dasar perbandingan: [SharedPreferences](https://pub.dev/packages/shared_preferences), [Hive](https://pub.dev/packages/hive), [sqflite](https://pub.dev/packages/sqflite), serta [stream Drift](https://drift.simonbinder.eu/dart_api/streams/). Detail alasan, skema 1000+ catatan, dan batas verifikasi terdapat pada [lembar kerja](docs/perbandingan-storage.md).

## Aturan konflik dan batas implementasi

`resolveConflict()` memilih catatan dengan `updatedAt` terbaru; jika waktunya sama, versi lokal dipertahankan. Fungsi ini tersedia sebagai aturan konflik teruji, tetapi belum terhubung ke backend dua arah karena sync masih simulasi.

`markAllSynced()` dapat menandai bersih perubahan yang terjadi selama upload. Pengembangan berikutnya perlu menandai versi yang benar-benar dikirim dan menyediakan tombstone/outbox untuk penghapusan. Saklar offline mengendalikan simulasi sync; mode pesawat sendiri tidak menghentikan jeda simulasi tersebut.

## Hasil dan dokumentasi

Analisis terakhir bersih dan **13 test Flutter lulus**. Percobaan SQLite berhasil memeriksa 1.200 catatan, migrasi kolom/indeks tanpa kehilangan data, dan rollback cache. Batas pengujian dicatat pada dokumen hasil verifikasi.

- [Prompt AI](docs/ai-prompt.md)
- [Output awal AI](docs/ai-output-awal.md)
- [Lembar kerja perbandingan storage](docs/perbandingan-storage.md)
- [Hasil refactoring](docs/refactoring.md)
- [Hasil testing dan verifikasi](docs/hasil-verifikasi.md)
- [Uji offline manual](docs/uji-offline.md)
