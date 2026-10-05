# Uji Offline-First — Praktikum 4, Langkah 10

Dokumen ini memuat langkah pengujian dan hasil yang diharapkan berdasarkan modul. Isi hasil aktual dan status setelah menjalankan setiap skenario pada perangkat.

## Persiapan

1. Jalankan aplikasi pada emulator Android atau perangkat Android yang terhubung. Gunakan target perangkat tersebut saat menjalankan `flutter run`.
2. Aktifkan koneksi internet dan matikan mode pesawat.
3. Buka **Pengaturan**, pastikan **Paksa mode offline** nonaktif, lalu kembali ke halaman catatan.
4. Jika ada catatan dirty dari praktikum sebelumnya, tekan **Sinkronkan** dan tunggu badge hilang. Dengan jumlah awal dirty = 0, penambahan tiga catatan pada skenario 3 akan menghasilkan badge = 3.
5. Pertahankan data aplikasi selama pengujian agar cache dan catatan tetap tersedia saat aplikasi dibuka kembali.

## 1. Isi cache

1. Pastikan internet aktif dan **Paksa mode offline** nonaktif.
2. Tekan tombol **Posts (cache-first)** pada AppBar halaman catatan.
3. Tunggu daftar posts selesai dimuat.

**Hasil yang diharapkan:** 100 posts ditampilkan dan disimpan pada tabel `cached_posts`. Jika belum ada cache, loading tampil selama permintaan jaringan berlangsung.

## 2. Cache saat offline

1. Setelah skenario 1 selesai, aktifkan mode pesawat pada perangkat. Pastikan Wi-Fi dan data seluler tidak tetap aktif.
2. Tutup aplikasi sepenuhnya, lalu buka kembali tanpa menghapus data aplikasi.
3. Buka halaman **Posts (cache-first)**.
4. Amati apakah daftar masih dapat dibaca. Simpan screenshot ke `screenshots/p4-posts-offline.png`, dengan indikator mode pesawat terlihat bila memungkinkan.

**Hasil yang diharapkan:** posts tetap tampil dari cache lokal meskipun jaringan tidak tersedia. Kegagalan refresh jaringan tidak mengganti daftar cache dengan halaman error.

## 3. Antrean dirty

1. Dalam kondisi perangkat masih offline, kembali ke halaman catatan.
2. Tekan **+ Catatan**, isi judul `Catatan offline 1` dan isi catatan, lalu tekan **Simpan**.
3. Ulangi untuk `Catatan offline 2` dan `Catatan offline 3`.
4. Amati badge di AppBar dan ikon awan pada setiap catatan baru.
5. Simpan screenshot ke `screenshots/p4-dirty-sebelum.png`.

**Hasil yang diharapkan:** ketiga catatan tersimpan, ikon awannya oranye, dan badge menunjukkan angka **3** jika jumlah dirty awal adalah 0.

## 4. Sync ditolak

1. Buka **Pengaturan** dan aktifkan **Paksa mode offline**.
2. Kembali ke halaman catatan, lalu tekan **Sinkronkan**.
3. Perhatikan snackbar serta angka badge.

**Hasil yang diharapkan:** snackbar menampilkan `Perangkat offline, sinkronisasi ditunda.` dan badge tetap **3**. Ketiga catatan tetap dirty.

**Catatan:** mode pesawat saja tidak menolak sync pada kode praktikum karena server masih disimulasikan dengan jeda waktu. Penolakan sync dikendalikan oleh saklar **Paksa mode offline**.

## 5. Sync berhasil

1. Buka **Pengaturan**, lalu matikan **Paksa mode offline**.
2. Kembali ke halaman catatan dan tekan **Sinkronkan** satu kali.
3. Tunggu sekitar satu detik sampai snackbar muncul.
4. Amati badge dan warna ikon awan. Simpan screenshot ke `screenshots/p4-dirty-sesudah.png`.

**Hasil yang diharapkan:** snackbar menampilkan `3 catatan berhasil disinkronkan`, badge hilang, dan ikon awan ketiga catatan menjadi hijau. Hasil ini membuktikan alur simulasi dan perubahan flag dirty; belum ada upload ke backend nyata.

## 6. Refresh background

1. Matikan mode pesawat dan aktifkan kembali koneksi internet. Pastikan **Paksa mode offline** nonaktif.
2. Tutup aplikasi sepenuhnya, lalu buka kembali agar provider Posts dimuat ulang. Cache dari skenario sebelumnya tetap tersimpan.
3. Buka **Posts (cache-first)**.
4. Amati daftar saat halaman dibuka dan setelah permintaan jaringan selesai.

**Hasil yang diharapkan:** cache ditampilkan segera setelah pembacaan lokal selesai, lalu aplikasi mengambil posts dari jaringan di background dan memperbarui cache serta tampilan. Isi daftar dapat terlihat sama jika data server tidak berubah; tampilan yang sama saja tidak membuktikan bahwa request telah selesai.

## Hasil observasi

Isi berdasarkan pengujian yang benar-benar dilakukan. Gunakan status **Lulus** atau **Gagal**, serta catat pesan error atau perbedaan dari hasil yang diharapkan.

| No. | Skenario | Hasil aktual | Status |
| --- | --- | --- | --- |
| 1 | Isi cache | Belum dicatat | Belum dinilai |
| 2 | Cache saat offline | Belum dicatat | Belum dinilai |
| 3 | Antrean dirty | Belum dicatat | Belum dinilai |
| 4 | Sync ditolak | Belum dicatat | Belum dinilai |
| 5 | Sync berhasil | Belum dicatat | Belum dinilai |
| 6 | Refresh background | Belum dicatat | Belum dinilai |

## Bukti screenshot

- [Badge sebelum sync](../screenshots/p4-dirty-sebelum.png)
- [Badge sesudah sync](../screenshots/p4-dirty-sesudah.png)
- [Posts saat offline](../screenshots/p4-posts-offline.png)
