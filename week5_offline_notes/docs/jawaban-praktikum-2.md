# Jawaban Pertanyaan Praktikum 2

## 1. Mengapa kolom `dirty` bertipe `INTEGER` dan bukan `BOOLEAN`?

SQLite tidak memiliki kelas penyimpanan `BOOLEAN` tersendiri. Nilai benar dan salah disimpan sebagai angka `1` dan `0`. Karena itu, skema `notes` memakai `dirty INTEGER`, lalu model `Note` mengubah `bool` menjadi `1` atau `0` di `toMap()` dan mengubahnya kembali menjadi `bool` di `fromMap()`.

## 2. Apa fungsi parameter `openDb` pada constructor `NoteRepository`?

Parameter `openDb` memungkinkan fungsi pembuka database disuntikkan ke repository. Dalam aplikasi, nilai bawaannya adalah `openNotesDb`. Dalam pengujian, kita dapat menggantinya dengan fungsi yang membuka database pengujian atau fungsi palsu. Dengan begitu, logika repository dapat diuji tanpa bergantung pada berkas database aplikasi yang sebenarnya.

## 3. Mengapa query memakai `where: 'id = ?'` dan `whereArgs`, bukan interpolasi string?

Tanda `?` adalah placeholder untuk nilai yang dikirim secara terpisah melalui `whereArgs`. SQLite menangani nilai tersebut sebagai data, bukan sebagai bagian dari perintah SQL. Cara ini mencegah SQL injection dan menghindari kesalahan penulisan query saat nilai mengandung karakter khusus, seperti tanda kutip.

## 4. Apa yang terjadi jika kolom baru ditambahkan di `onCreate` tanpa menaikkan `version`?

`onCreate` hanya berjalan saat berkas database pertama kali dibuat. Pada perangkat yang sudah memiliki database versi lama, perubahan di `onCreate` tidak dijalankan, sehingga kolom baru tidak ada. Query yang memakai kolom itu dapat gagal dengan error seperti `no such column`. Solusinya adalah menaikkan `version` dan menambahkan perubahan skema di `onUpgrade`; `onCreate` tetap berisi skema lengkap untuk pemasangan baru.
