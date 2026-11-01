# Campus Notify - Praktikum 1 sampai 3

Autentikasi mock, penyimpanan token aman, dan notifikasi FCM berdasarkan
[codelab Minggu 6](https://jti-polinema.github.io/flutter-codelab/06-minggu-6-authentication-security-fcm/index.html#2).

## Fitur

- Login mock: email mengandung `@`, kata sandi minimal 6 karakter.
- Access token dan refresh token disimpan melalui `flutter_secure_storage`.
- Riverpod memulihkan status login dari token saat aplikasi dibuka kembali.
- GoRouter melindungi `/` dan `/pengumuman/:id`; pengguna tanpa sesi diarahkan ke `/login`.
- Logout menghapus token dan mengembalikan pengguna ke halaman login.
- Dio menambahkan header Bearer, melakukan refresh dan retry maksimal sekali saat `401`, serta mengakhiri sesi jika refresh gagal atau retry tetap `401`.
- Backup Android dinonaktifkan untuk menghindari pemulihan data terenkripsi tanpa kunci perangkat asal.

## Menjalankan

```sh
flutter pub get
flutter run
```

Contoh login: `mahasiswa@kampus.ac.id` dengan kata sandi `123456`.
Login tetap simulasi tanpa membuat akun. Versi saat ini membutuhkan aplikasi
Android yang terdaftar di Firebase dan `android/app/google-services.json`
yang sesuai dengan `applicationId`.

Login dan refresh masih simulasi sesuai codelab. URL `https://example-campus-api.test`
di `lib/data/api_client.dart` adalah placeholder; pengujian respons API memakai
adapter lokal, bukan server sungguhan. Halaman pengumuman memakai data contoh.

## Verifikasi

```sh
dart analyze
flutter test --no-pub
```

Pengujian mencakup operasi
TokenStore, pemulihan sesi, logout, penolakan login invalid, validasi form,
guard route, navigasi detail, refresh sukses, batas retry, dan kegagalan refresh.
Secure storage dalam pengujian menggunakan mock platform.

Validasi implementasi Praktikum 3: 11 unit/widget test lulus; analisis Dart
tanpa error/warning dengan 3 info deprecated pada API token codelab.
Build Android debug dengan target Flutter ARM64 berhasil menggunakan cache lokal:

```powershell
.\android\gradlew.bat -p android assembleDebug -Ptarget-platform=android-arm64 --offline --console=plain
```

Build seluruh target melalui `flutter build apk --debug --no-pub` belum
terverifikasi karena unduhan artefak engine untuk arsitektur lain menunggu jaringan.

Untuk verifikasi di Android: login, buka pengumuman #3, tutup lalu buka kembali
aplikasi untuk memeriksa pemulihan sesi, kemudian logout. Pengujian pada perangkat
fisik/emulator belum dilakukan dalam pengerjaan ini.

## Praktikum 3: notifikasi dan deep link

- `lib/messaging/push_service.dart`: background handler top-level dengan
  `@pragma('vm:entry-point')`, local notification foreground, klik background,
  dan `getInitialMessage()` untuk peluncuran dari terminated.
- `main.dart`: inisialisasi service sekali sebelum UI dijalankan dan registrasi
  handler background. Tujuan klik ditahan selama pemulihan sesi atau login,
  lalu dikonsumsi sekali oleh GoRouter.
- Klik local notification juga langsung membuka tujuan. Jika aplikasi sudah
  mati saat notifikasi lokal diklik, gunakan `getNotificationAppLaunchDetails()`.
- Channel Android `pengumuman` memakai importance tinggi dan ikon notifikasi
  putih. Handler background tidak membuat banner tambahan agar tidak ganda.
- Beranda menyediakan tombol berlangganan/berhenti topik `pengumuman-kampus`.
  Status di UI menunjukkan hasil aksi terakhir, bukan pembacaan daftar
  langganan dari Firebase. Setelah membuka ulang halaman, status belum diketahui.

Perubahan API `initialize(settings: ...)` dan `show(id: ..., ...)` mengikuti
versi `flutter_local_notifications` yang terpasang. API `getToken()` dan
`onTokenRefresh` tetap mengikuti codelab; SDK saat ini menandainya deprecated.
Fungsi `initFcmToken` dari Praktikum 2 dipertahankan, tetapi integrasi endpoint
`POST /devices` belum tersedia. Tombol salin token bukan bukti sinkronisasi backend.

### Payload pengujian

Contoh request FCM HTTP v1 (dikirim dari backend dengan kredensial server):

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": {
      "route": "/pengumuman/3",
      "id": "3"
    }
  }
}
```

Untuk mengirim ke satu perangkat, ganti `topic` dengan `token` perangkat tujuan.
Jangan simpan kredensial server di aplikasi Flutter. Pada Firebase Console,
isi judul dan body, lalu tambahkan pasangan custom data `route=/pengumuman/3`
dan `id=3` pada opsi tambahan. Pastikan metode pengiriman Console yang dipilih
menyertakan custom data; bila pesan uji tidak membawa data, gunakan campaign
yang memuat custom data atau backend HTTP v1. Tanpa `data.route`, tujuan adalah `/`.

### Matriks pengujian manual

Jalankan ulang aplikasi sepenuhnya setelah perubahan plugin/manifest.
Izinkan notifikasi melalui tombol persiapan, lalu kirim payload gabungan yang
sama pada ketiga kondisi. Pengiriman ke topik memerlukan tombol Berlangganan.

| State | Cara uji | Hasil yang diharapkan | Hasil aktual / bukti |
| --- | --- | --- | --- |
| Foreground | Aplikasi terbuka, kirim pesan, klik banner lokal | Membuka `/pengumuman/3` | Belum diuji; isi setelah uji perangkat |
| Background | Tekan Home, kirim pesan, klik notifikasi sistem | Membuka `/pengumuman/3` | Belum diuji; isi setelah uji perangkat |
| Terminated | Tutup dari recent apps, kirim pesan, klik notifikasi | Aplikasi berjalan ke `/pengumuman/3` | Belum diuji; isi setelah uji perangkat |

Jangan gunakan Force stop untuk uji terminated. Beberapa perangkat membatasi
proses setelah swipe-close; catat perilaku perangkat sebenarnya jika demikian.
Jika belum login, klik notifikasi harus membuka login dahulu, kemudian menuju
pengumuman setelah login berhasil. Simpan screenshot banner dan halaman tujuan
di `screenshots/` tanpa token lengkap. Unit/widget test memverifikasi parsing
route, tujuan saat pemulihan sesi, login, dan konsumsi tujuan sekali; pengujian
itu tidak menggantikan bukti penerimaan FCM di perangkat.
