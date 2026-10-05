# Jawaban Pertanyaan Praktikum 5

## 1. Mengapa kita menguji provider dengan `ProviderContainer` + `overrideWithValue` dan bukan dengan membuka database asli?

`ProviderContainer` memungkinkan provider dijalankan tanpa membangun tampilan aplikasi. Melalui `overrideWithValue`, `noteRepositoryProvider` diganti dengan `FakeNoteRepository` yang menyimpan data di memori. Data awal dan kondisi error dapat ditentukan langsung sehingga hasil pengujian konsisten dan mudah diulang.

Cara ini membuat test cepat dan dapat dijalankan melalui `flutter test` tanpa emulator atau plugin SQLite yang aktif. Fokus pengujian adalah memastikan provider meneruskan data dan error dari repository. Test tersebut belum membuktikan bahwa query atau skema SQLite bekerja pada perangkat; bagian itu memerlukan pengujian database atau integrasi secara terpisah.

## 2. Apa manfaat parameter `latency` pada `syncNotes` bagi pengujian?

Parameter `latency` mengatur jeda simulasi upload. Dalam aplikasi, nilai bawaannya satu detik agar proses sinkronisasi dapat diamati. Dalam test, nilainya dapat diubah menjadi `Duration.zero` sehingga pengujian tidak perlu menunggu satu detik pada setiap pemanggilan. Logika menghitung catatan dirty, menandainya bersih, dan mengembalikan jumlah yang tersinkron tetap dijalankan.

## 3. Tuliskan satu test tambahan yang menurut Anda penting namun belum ada, beserta alasannya.

Test tambahan yang penting adalah memeriksa hasil `resolveConflict()` ketika catatan lokal dan remote memiliki waktu pembaruan yang sama. Test yang ada baru membandingkan dua waktu yang berbeda. Kasus waktu sama perlu diuji agar aturan pemilihan tetap jelas dan konsisten. Berdasarkan kode saat ini, versi lokal dipertahankan karena waktu remote tidak lebih baru.

Contoh berikut dapat ditambahkan ke dalam grup `Offline-first` pada `test/note_test.dart`, menggunakan helper `_note()` yang sudah tersedia:

```dart
test('resolveConflict mempertahankan lokal saat waktu sama', () {
  final waktu = DateTime(2026, 9, 18, 10);
  final local = _note('Isi lokal', at: waktu);
  final remote = _note('Isi remote', at: waktu);

  final result = resolveConflict(local, remote);

  expect(result, same(local));
});
```

Contoh ini merupakan usulan test tambahan dan belum ditambahkan ke berkas test. Hasil pengujian Praktikum 5 yang telah dijalankan adalah tujuh test lulus, dengan `flutter analyze` tanpa masalah.
