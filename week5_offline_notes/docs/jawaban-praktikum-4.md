# Jawaban Pertanyaan Praktikum 4

## 1. Apa perbedaan cache-first dan network-first? Berikan satu contoh data yang lebih cocok memakai network-first.

Cache-first membaca data lokal terlebih dahulu agar tampilan cepat muncul dan tetap dapat digunakan saat offline. Pada implementasi Praktikum 4, jika cache tersedia, daftar posts langsung ditampilkan, lalu aplikasi mencoba mengambil data terbaru di background. Jika belum ada cache, aplikasi menunggu hasil jaringan.

Network-first mencoba mengambil data terbaru dari jaringan terlebih dahulu. Cache digunakan sebagai cadangan ketika jaringan gagal. Contohnya adalah data stok barang yang sering berubah: aplikasi perlu mengutamakan stok terbaru dari server. Jika menampilkan cache saat offline, aplikasi perlu menjelaskan bahwa jumlah stok tersebut mungkin sudah tidak terbaru.

## 2. Jelaskan skenario kehilangan data yang dapat terjadi akibat `markAllSynced()`, lalu usulkan perbaikannya.

Misalnya, catatan A masih berstatus dirty ketika sinkronisasi dimulai. Saat versi awal catatan sedang dikirim, pengguna mengubah isinya sehingga terbentuk versi baru yang belum terkirim. Setelah upload versi awal selesai, `markAllSynced()` menandai semua catatan dirty sebagai bersih, termasuk versi baru tersebut. Akibatnya, perubahan terbaru masih ada di perangkat tetapi tidak lagi masuk antrean sinkronisasi, sehingga server dapat tertinggal dan perubahan berisiko hilang saat data kemudian ditimpa.

Perbaikannya adalah mencatat pasangan `id` dan `updated_at` setiap catatan yang benar-benar dikirim. Setelah server menyatakan berhasil, tandai bersih hanya baris yang masih memiliki pasangan nilai tersebut. Jika catatan berubah selama upload, `updated_at` berbeda sehingga status dirty tetap dipertahankan untuk sinkronisasi berikutnya. Alternatif lain adalah menyimpan operasi tertunda dalam tabel outbox. Pada praktikum ini, upload masih berupa simulasi jeda waktu.

## 3. Mengapa diperlukan saklar `forceOffline` padahal sudah ada mode pesawat?

Saklar `forceOffline` membuat kondisi offline dapat diuji secara terkontrol melalui aplikasi, tanpa bergantung pada koneksi Wi-Fi atau pengaturan perangkat. Kondisinya juga dapat diatur dalam pengujian otomatis. Saat saklar aktif, sinkronisasi ditolak dan halaman Posts hanya membaca cache lokal.

Dalam kode praktikum, sinkronisasi hanya menggunakan `Future.delayed()` untuk mensimulasikan server sehingga tidak mendeteksi koneksi internet yang sebenarnya. Mode pesawat saja tidak otomatis membuat simulasi itu gagal. Saklar `forceOffline` menyediakan kondisi yang secara eksplisit memicu `OfflineException`, sehingga penolakan sync dan keutuhan antrean dirty dapat diuji.

## 4. Mengapa `fetchAndCache()` menulis cache di dalam transaksi?

Penggantian cache terdiri atas penghapusan data lama dan penyisipan seluruh posts yang baru. Transaksi membuat rangkaian tersebut menjadi satu kesatuan: semua perubahan berhasil disimpan atau semuanya dibatalkan. Jika terjadi kegagalan di tengah penyisipan, penghapusan juga dibatalkan sehingga cache lama tetap tersedia. Tanpa transaksi, aplikasi dapat kehilangan cache lama atau menyimpan hanya sebagian data baru.