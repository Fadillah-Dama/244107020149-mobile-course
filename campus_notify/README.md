# Campus Notify

Aplikasi Flutter untuk autentikasi API Laravel, pengumuman kampus, dan notifikasi Firebase Cloud Messaging. Struktur mengikuti materi pertemuan 11: **feature-first Clean Architecture dan SOLID**.

Penjelasan lengkap, peta setiap file lama, arah dependensi, contoh DI, keputusan AI Challenge, dan hasil pemeriksaan tersedia di [docs/CLEAN_ARCHITECTURE_SOLID.md](docs/CLEAN_ARCHITECTURE_SOLID.md).

## Fitur

- Login melalui `POST /api/auth/login`, dengan access/refresh token pada secure storage.
- Pemulihan sesi, refresh token bersama untuk request bersamaan, dan retry maksimal sekali.
- Sesi diakhiri ketika refresh ditolak; gangguan jaringan tidak otomatis menghapus token.
- Registrasi/rotasi token perangkat lewat `POST /api/devices`, pelepasan lewat `DELETE /api/devices`.
- Logout mencabut sesi server, melepas perangkat, dan membersihkan sesi lokal serta badge. UI melaporkan jika pencabutan server belum terkonfirmasi.
- Inbox belum dibaca lewat `GET /api/notifications`, detail lewat `GET /api/notifications/{id}`, serta status baca lewat `PATCH /api/notifications/{id}/read`.
- Banner foreground lokal, notifikasi background, dan navigasi dari terminated. Tujuan klik ditahan selama pemulihan sesi/login.
- Channel `pengumuman` dengan suara default dan ikon putih; tidak membuat banner background ganda.
- Langganan topik `pengumuman-kampus` dan tombol persiapan izin/salin token.
- Jumlah belum dibaca pada menu aplikasi; badge ikon mengikuti kemampuan dan pengaturan launcher HP.

Detail dari API memerlukan `notification_id` pada data pesan. Rute demo `/pengumuman/3` tanpa ID notifikasi tetap memakai contoh pengumuman seperti sebelumnya.

## Struktur dan dependency rule

```text
lib/
  main.dart
  app/                  # Bootstrap, router, widget aplikasi, composition root
  core/                 # Failure, parser rute, port bersama; Dart murni
  shared/data/network/  # Dio, konfigurasi API, interceptor, pemetaan error
  features/
    auth/
      domain/           # Entity, kontrak, use case
      data/             # Model, API, secure storage
      presentation/     # Halaman, controller, facade provider
    announcements/
      domain/           # Entity, kontrak, OpenNotification
      data/             # Model, API, Firebase, registrasi perangkat, badge
      presentation/     # Halaman dan state notifikasi
```

**Presentation -> Domain <- Data**. Domain dan core tidak mengimpor framework/SDK. Entity tidak melakukan mapping JSON. Implementasi konkret dipilih pada `app/di/providers.dart`, bukan dibuat oleh widget.

| Sebelum | Sesudah |
| --- | --- |
| `lib/data/` | Model/implementasi pada fitur terkait dan client bersama di `shared/data/network/` |
| `lib/providers/` | State di presentation; wiring di `app/di/`; alur bisnis di domain/usecases |
| `lib/pages/` | `features/auth/presentation/pages/` dan `features/announcements/presentation/pages/` |
| `lib/messaging/` | Implementasi plugin di data announcements; parser di core; state navigasi di app/routing |
| `lib/main.dart` yang menggabungkan router/provider/UI | Dipisah menjadi main, bootstrap, app, dan routing |

Peta terperinci dan penerapan lima prinsip SOLID ada pada [dokumentasi refaktor](docs/CLEAN_ARCHITECTURE_SOLID.md).

## Menjalankan

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://IP_LAPTOP:8000/api
```

Ganti `IP_LAPTOP` dengan alamat IPv4 laptop. HP dan laptop harus berada pada jaringan yang sama. Dari folder backend Laravel, jalankan:

```powershell
php artisan serve --host=0.0.0.0 --port=8000
```

Konfigurasi URL default berada pada `lib/shared/data/network/api_config.dart`, yaitu `http://127.0.0.1:8000/api`. Untuk koneksi USB dengan URL default, gunakan `adb reverse tcp:8000 tcp:8000`. Untuk emulator, gunakan alamat host yang sesuai lingkungan Anda. HTTP diizinkan pada manifest debug; gunakan HTTPS pada backend produksi.

Akun contoh seeder Laravel: `mahasiswa@kampus.ac.id`, kata sandi `123456`. Akun harus tersedia pada database backend. Firebase memerlukan `android/app/google-services.json` yang sesuai `applicationId`. Kredensial server Firebase tetap berada di Laravel, bukan aplikasi mobile.

Jalankan ulang aplikasi sepenuhnya setelah perubahan plugin/manifest. Refaktor tidak mengganti endpoint atau skema database.

## Mengirim notifikasi uji

Dari folder `campus_notify_api`:

```powershell
php artisan campus:notify mahasiswa@kampus.ac.id --title="Uji pengumuman" --body="Kelas Mobile pindah ke Ruang A2" --route="/pengumuman/3"
```

Command menyimpan notifikasi ke database dan mengirim push ke perangkat pengguna yang terdaftar. Setiap pemanggilan membuat pesan baru. Pesan tetap ada dalam inbox jika pengiriman push gagal.

Untuk pesan topik dari Firebase Console/backend, contoh data rute adalah `route=/pengumuman/3`. Pesan Firebase Console tidak otomatis membuat catatan di database Laravel. Gunakan command Laravel ketika menguji inbox dan status baca yang saling terhubung.

## Verifikasi otomatis

```powershell
dart format lib test
dart analyze lib test
flutter test --no-pub
```

Hasil refaktor: **36 test lulus**, tanpa error/warning analyzer, dengan 5 info deprecated pada API token Firebase yang sudah digunakan sebelumnya. Test mencakup use case sukses/gagal dengan repository palsu, aturan dependensi, API melalui adapter lokal, rotasi token, request bersamaan, logout offline, form, route guard, dan navigasi notifikasi. Test tidak menghubungi Laravel/Firebase sungguhan.

Pemeriksaan sterilitas berikut menghasilkan 0 kecocokan:

```powershell
rg -n 'Dio\(|openDatabase|FlutterSecureStorage|SharedPreferences|jsonDecode|FirebaseMessaging|Clipboard\.' lib/features/auth/presentation lib/features/announcements/presentation
rg -n 'package:(flutter|flutter_riverpod|dio|firebase|sqflite|flutter_secure_storage)' lib/core lib/features/auth/domain lib/features/announcements/domain
rg -n '(fromJson|toJson|fromMap|toMap)\s*\(' lib/features/auth/domain/entities lib/features/announcements/domain/entities
```

Test `test/architecture/dependency_rule_test.dart` juga menjaga agar data tidak mengimpor presentation/app, serta domain dan core hanya bergantung pada domain/core atau Dart.

## Pengujian manual setelah refaktor

| Skenario | Hasil yang diharapkan |
| --- | --- |
| Login, tutup-buka aplikasi, logout | Sesi pulih dan dihapus sesuai aksi |
| Foreground | Banner lokal muncul dan klik membuka tujuan |
| Background melalui tombol Home | Banner sistem muncul dan klik membuka tujuan |
| Terminated tanpa Force stop | Klik banner menjalankan aplikasi menuju tujuan, melalui login bila perlu |
| Dua pesan belum dibaca, buka salah satunya | Hanya pesan yang dibuka hilang dari inbox |
| Koneksi terputus | UI menampilkan pesan aman dan menyediakan percobaan ulang |
| Badge | Jumlah dalam aplikasi sesuai API; angka/titik ikon mengikuti launcher |

Pengujian HP setelah refaktor, build APK ulang, dan screenshot before/after belum dilakukan. Simpan bukti aktual di `screenshots/` tanpa token lengkap atau kredensial. Matriks ini adalah panduan pengujian, bukan klaim hasil perangkat.
