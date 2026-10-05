# Jawaban Pertanyaan Praktikum 1

## 1. Mengapa `SharedPreferences.getInstance()` tidak dipanggil di dalam `build()` widget?

Method `build()` dapat berjalan berulang kali ketika state atau tema berubah. Sementara itu, `SharedPreferences.getInstance()` menghasilkan `Future` dan harus ditunggu. Jika dipanggil langsung di `build()`, pembacaan preferensi bisa dimulai berulang kali, tampilan sementara dapat berkedip saat menunggu hasil, dan widget menjadi sulit diuji. Dalam aplikasi ini, akses penyimpanan ditempatkan di `PrefsRepository`, lalu hasilnya dikelola oleh provider. Widget cukup membaca state provider melalui `ref.watch()`.

## 2. Bagaimana alur data sejak switch ditekan sampai tema berubah dan nilainya tersimpan?

1. Pengguna menekan switch **Tema gelap** di `SettingsPage`.
2. `onChanged` memanggil `ref.read(darkModeProvider.notifier).toggle()`.
3. `toggle()` menghitung nilai kebalikan dari tema sebelumnya, lalu langsung mengubah state menjadi `AsyncData(next)`.
4. `OfflineNotesApp` yang memantau `darkModeProvider` dibangun ulang. Nilai `themeMode` pada `MaterialApp` berubah sehingga tema langsung terlihat.
5. `toggle()` memanggil `PrefsRepository.setDarkMode(next)`. Repository menyimpan nilai `bool` dengan key `dark_mode` melalui `SharedPreferences`.
6. Saat aplikasi dibuka lagi, `DarkModeNotifier.build()` membaca nilai yang tersimpan melalui `PrefsRepository.getDarkMode()`, sehingga pilihan tema dipulihkan.

## 3. Apa kelebihan dan risiko *optimistic update* pada `toggle()`?

Kelebihannya, tema berubah segera setelah switch ditekan tanpa menunggu operasi penyimpanan selesai. UI terasa responsif dan tidak perlu menampilkan loading setiap kali tema diganti.

Risikonya, tema yang sempat tampil mungkin belum berhasil disimpan. Jika `setDarkMode()` gagal, blok `catch` pada `toggle()` mengembalikan state ke nilai sebelumnya (*rollback*) dan meneruskan error agar kegagalan dapat ditangani oleh pemanggil.
