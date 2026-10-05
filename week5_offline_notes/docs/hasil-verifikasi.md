# Hasil Verifikasi AI Challenge dan Refactoring

Saya menggunakan hasil perintah berikut untuk memeriksa rekomendasi dan perubahan kode. Pengujian dibantu Codex di workspace proyek. Catatan ini membedakan hasil otomatis dengan hal yang belum diuji pada perangkat.

## Dependensi dan analisis

`flutter pub add go_router` berhasil menyelesaikan dependensi dan memasang **go_router 18.0.2**. `pubspec.yaml` dan `pubspec.lock` menyimpan hasilnya. SharedPreferences, sqflite, Riverpod, dan Dio sudah tersedia dari praktikum sebelumnya. Hive dan Drift tidak ditambahkan ke aplikasi; penilaian keduanya berasal dari dokumentasi yang ditautkan di [lembar kerja](perbandingan-storage.md).

```text
flutter analyze
No issues found! (ran in 5.6s)
```

## Pengujian Flutter

```text
flutter test
00:07 +13: All tests passed!
```

| Kelompok | Jumlah | Yang diperiksa |
| --- | --- | --- |
| Model Note | 2 | Nilai bawaan field dan serialisasi dirty/waktu |
| Provider dengan fake repository | 2 | Hasil sukses dan penerusan error |
| Offline-first | 3 | Sync membersihkan dirty, penolakan offline, aturan konflik |
| Refactoring widget/routing | 6 | Badge dan aksi tile, detail berdasarkan ID, missing/error/retry, edit memperbarui detail dan list, ID tidak valid |
| Total | 13 | Seluruh test lulus |

Test Flutter menggunakan repository palsu dan tema uji. Hasil ini memverifikasi logika dan navigasi widget, bukan koneksi HTTP nyata, persistensi perangkat, maupun migrasi SQLite melalui plugin Android.

## Percobaan SQL dan migrasi

Perintah yang dapat diulang dari root proyek:

```text
python docs/verify_storage.py
PASS: 1200 catatan, 400 dirty, urutan updated_at benar
PASS: migrasi pinned dan indeks mempertahankan 1200 catatan
PASS: kegagalan penggantian cache memulihkan cache lama
SQLite 3.37.2: seluruh pemeriksaan lulus
```

Script membaca perintah CREATE TABLE dari `lib/data/local/db.dart`, lalu menjalankannya pada SQLite in-memory milik Python. Percobaan menambah 1.200 catatan, memeriksa query dirty dan urutan, menambah `pinned` serta dua indeks, dan memastikan data lama tidak berubah. Penggantian cache sengaja digagalkan dengan primary key duplikat untuk memeriksa rollback.

Saya tidak mengubah versi database aplikasi menjadi 2. Percobaan ini membuktikan perilaku SQL usulan, tetapi belum membuktikan bahwa callback `onUpgrade` Flutter berjalan di perangkat. Percobaan ini juga bukan benchmark kecepatan atau perbandingan performa Hive/Drift.

## Batas verifikasi

- Saya belum menjalankan uji perangkat baru setelah refactoring atau memeriksa deep link dari sistem operasi. Test rute memakai initial location GoRouter di widget test.
- Saya belum melakukan instalasi, migrasi, atau benchmark Hive dan Drift. Saya membatasi penilaian boilerplate kedua opsi pada dokumentasi setup, adapter/generator, dan migrasinya.
- Sinkronisasi catatan tetap simulasi. Kelemahan `markAllSynced()` dan penghapusan tanpa tombstone belum diubah dalam challenge ini.
- Pengujian manual mode pesawat tetap mengikuti [uji-offline.md](uji-offline.md); saya tidak mengisi hasil aktual yang belum diamati pada pengujian ini.
