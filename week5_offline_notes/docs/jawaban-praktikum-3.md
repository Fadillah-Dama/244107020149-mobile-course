# Jawaban Pertanyaan Praktikum 3

## 1. Mengapa setelah setiap mutasi perlu meng-invalidate `notesProvider` dan `dirtyCountProvider`? Apa yang terjadi jika hanya salah satu?

Operasi tambah, ubah, dan hapus mengubah data di SQLite, sedangkan provider masih dapat menyimpan hasil pembacaan sebelumnya. `ref.invalidate()` membuang hasil lama agar provider yang sedang dipantau UI membaca ulang data. `notesProvider` memperbarui daftar catatan, sementara `dirtyCountProvider` memperbarui jumlah catatan yang belum tersinkron.

Jika hanya `notesProvider` yang di-invalidate, daftar catatan diperbarui tetapi angka badge bisa tetap memakai jumlah lama. Jika hanya `dirtyCountProvider` yang di-invalidate, angka badge diperbarui tetapi daftar catatan bisa tetap menampilkan data lama. Karena itu, method `_refresh()` pada `NoteActions` meng-invalidate keduanya setelah mutasi berhasil.

## 2. Bagaimana cara memicu state error secara sengaja untuk menguji tampilan `_ErrorView`?

Salah satu caranya adalah membuat repository palsu yang method `fetchNotes()`-nya melempar `Exception('Simulasi gagal membaca database')`, lalu mengganti `noteRepositoryProvider` menggunakan override pada `ProviderScope` saat pengujian. Ketika `notesProvider` masuk ke state error, cabang `error` pada `notesAsync.when()` menampilkan `_ErrorView`.

Hal yang diperiksa adalah munculnya ikon error, pesan kegagalan, dan tombol **Coba lagi**. Untuk menguji pemulihan, repository palsu dapat dibuat gagal pada pembacaan awal lalu berhasil pada pembacaan berikutnya. Tombol **Coba lagi** memanggil `ref.invalidate(notesProvider)` sehingga data diminta ulang. Skenario ini adalah cara pengujian yang dapat dilakukan, bukan hasil pengujian yang sudah dijalankan.

## 3. Mengapa aplikasi tetap berfungsi dalam mode pesawat walaupun tidak ada kode khusus untuk mode offline?

Seluruh operasi catatan pada Praktikum 3 membaca dan menulis database SQLite lokal di perangkat melalui `NoteRepository`. Operasi tersebut tidak mengirim permintaan ke server dan tidak memerlukan koneksi internet. Mode pesawat memutus koneksi jaringan, tetapi tidak menghalangi akses aplikasi ke penyimpanan lokal. Karena itu, tambah, baca, ubah, dan hapus catatan tetap dapat dilakukan pada perangkat yang mendukung database aplikasi.
