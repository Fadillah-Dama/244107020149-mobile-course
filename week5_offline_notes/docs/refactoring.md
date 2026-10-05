# Hasil Refactoring Challenge

## 1. Ekstrak NoteTile

Saya memindahkan tampilan satu catatan ke `lib/widgets/note_tile.dart`. Widget menerima `note`, `onTap`, dan `onDelete`. Catatan dirty menampilkan ikon awan oranye serta Chip **belum tersinkron**. Catatan bersih menampilkan ikon awan hijau tanpa Chip. `NotesPage` tetap mengatur navigasi dan memanggil aksi provider.

## 2. Pisahkan cache posts dan logika sync

Saya memeriksa batas tanggung jawab yang sudah dibuat pada praktikum:

- `NoteRepository`: operasi data lokal pada tabel `notes`, termasuk baca/hitung/update flag dirty. Tidak melakukan request HTTP atau mengelola cache posts.
- `PostRepository`: mengambil posts melalui Dio serta membaca/mengganti tabel `cached_posts` dalam transaksi. Tidak menyinkronkan catatan.
- `sync.dart`: menjalankan simulasi sinkronisasi dan memilih versi catatan melalui `resolveConflict()`.

Saya memindahkan `OfflineException` ke `lib/data/offline_exception.dart` karena dipakai bersama oleh cache posts dan sync. Dengan begitu, provider posts tidak perlu mengimpor file logika sinkronisasi catatan hanya untuk memakai tipe exception.

## 3. Halaman detail dengan GoRouter

Saya menambahkan `go_router` dan mengganti root aplikasi menjadi `MaterialApp.router`. Router dikelola melalui provider agar tidak dibuat ulang setiap tema berubah dan dapat di-dispose bersama container.

Rute `/note/:id` mengirim ID ke `NoteDetailPage`. Halaman ini memantau `noteByIdProvider(id)` yang memanggil `NoteRepository.getNoteById(id)`, sehingga detail tetap dapat dimuat meskipun daftar belum menyimpan catatan tersebut dalam state. Rute tambahan `/posts` dan `/settings` mempertahankan akses ke halaman sebelumnya.

Detail menangani loading, error dengan tombol coba lagi, catatan tidak ditemukan, dan data berhasil dibaca. ID yang tidak dapat dipakai ditampilkan sebagai pesan. Tombol **Ubah catatan** membuka dialog lama; setelah penyimpanan berhasil, daftar, badge dirty, dan provider detail di-invalidate bersama.

## Bukti pengujian

Enam widget test tambahan memeriksa badge/callback NoteTile, akses langsung detail, catatan yang tidak ada, retry setelah error, edit detail yang memperbarui daftar, dan ID rute tidak valid. Tujuh test praktikum sebelumnya tetap lulus. Rincian dan batas pengujian ada di [hasil-verifikasi.md](hasil-verifikasi.md).
