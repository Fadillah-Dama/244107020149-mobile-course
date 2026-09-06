# week_2_declarative_ui_responsive_design

---

# Tujuan Pembelajaran

    1. Menjelaskan prinsip declarative UI dan hubungan antara widget, konfigurasi, serta state.
    2. Menggunakan StatelessWidget, StatefulWidget, Container, Row, Column, dan Expanded.
    3. Membedakan komponen Material 3 dan Cupertino untuk kebutuhan platform yang berbeda.
    4. Membangun layout responsif untuk ukuran layar mobile dan tablet.
    5. Menerapkan theme, dark mode, styling, dan aksesibilitas dasar.

# AI prompt challenge

## 1. Perbandingan Tata Letak Dashboard Akademik Flutter: GridView vs. LayoutBuilder + Column

Berikut adalah perbandingan teknis antara penggunaan **GridView Mandiri** dan kombinasi **LayoutBuilder + Column** untuk kebutuhan dashboard akademik:

| Aspek | Versi GridView Mandiri | Versi LayoutBuilder + Column / Flex |
| :--- | :--- | :--- |
| **Kontrol Aspek Rasio** | Terikat pada `childAspectRatio` yang statis di setiap sel. | Bebas, tinggi elemen menyesuaikan isi konten (*intrinsic height*). |
| **Fleksibilitas Responsif** | Terbatas pada jumlah kolom dan rasio lebar-ke-tinggi. | Dinamis, dapat merestrukturisasi hierarki komponen secara utuh. |
| **Risiko Text Scaling (A11y)** | Tinggi (rawan *overflow* jika font sistem diperbesar). | Rendah (konten memanjang ke bawah secara alami). |
| **Screen Reader Flow** | Membaca petak sel berurutan sesuai indeks grid. | Membaca hierarki vertikal/struktural secara logis dari atas ke bawah. |
| **Efisiensi Memori** | Tinggi dengan `GridView.builder` (*lazy loading* aktif). | Standar, `Column` me-*render* seluruh *child* sekaligus tanpa daur ulang memori. |

### Trade-off Responsif

### Versi GridView Mandiri
* **Kelebihan:** Sangat konsisten dan rapi untuk menyajikan banyak kartu metrik yang memiliki dimensi seragam.
* **Kekurangan:** Penggunaan `childAspectRatio` bersifat kaku. Saat terjadi rotasi layar (*portrait* ke *landscape*) atau dijalankan pada layar tablet/desktop, kartu rentan terlihat terlalu pipih atau melebar tidak proporsional jika rasio tidak dikalkulasi ulang secara dinamis.

### Versi LayoutBuilder + Column
* **Kelebihan:** Memberikan kendali penuh terhadap `constraints.maxWidth`. Memungkinkan perubahan layout secara adaptif (misal: beralih dari 1 kolom di ponsel menjadi multi-kolom di tablet/desktop) tanpa membatasi tinggi kartu.
* **Kekurangan:** Saat mengombinasikan *grid* di dalam `Column` bersusun `SingleChildScrollView`, penggunaan `shrinkWrap: true` wajib digunakan. Hal ini mematikan mekanisme *virtualization* (daur ulang memori) bawaan Flutter.

### Trade-off Aksesibilitas (Accessibility / A11y)

### Dukungan Dynamic Type & Large Text Scaling
* **GridView:** Sangat rentan memicu *render overflow* (garis kuning-hitam) saat pengguna mengaktifkan fitur pembesaran font pada pengaturan sistem operasi, karena batas tinggi sel terkunci oleh rasio aspek.
* **LayoutBuilder + Column:** Kartu dapat memanjang secara fleksibel ke bawah mengikuti pertambahan ukuran teks tanpa merusak struktur visual antarmuka.

### Urutan Fokus Screen Reader (Semantics Flow)
* **GridView:** *Screen reader* membaca elemen berbasis petak horizontal-ke-vertikal murni sesuai indeks sel. Hal ini berpotensi membingungkan pengguna jika terdapat data yang memiliki dependensi relasional antar-kartu.
* **LayoutBuilder + Column:** Memungkinkan pengelompokan semantik (`Semantics`) dan urutan fokus visual yang lebih logis, sehingga pembacaan informasi akademik (seperti profil, ringkasan nilai, dan metrik mingguan) mengalir runtut dari atas ke bawah.6

## 2. Kapan Penggunaan `Expanded` di Dalam `Row` Menyebabkan Error/Overflow?

Penggunaan `Expanded` di dalam `Row` menyebabkan *error layout* ketika `Row` tersebut berada di dalam *parent widget* yang memberikan **lebar tanpa batas (*unbounded width*)**. 

Contoh *parent* dengan *unbounded width*:
* `SingleChildScrollView` dengan `scrollDirection: Axis.horizontal`
* `ListView` horizontal
* `Row` yang berada di dalam `Row` lain tanpa batasan lebar

### Penyebab Teknis
`Expanded` berfungsi memaksa *child* mengisi seluruh sisa ruang horizontal yang tersedia (`maxWidth`). Jika *parent*-nya tidak memiliki batas maksimal (`maxWidth = double.infinity`), Flutter tidak dapat mengkalkulasi dimensi ruang yang harus diambil, sehingga memicu *crash* / *assertion error*:
> `BoxConstraints forces an infinite width.`

### Contoh Kode yang Gagal

```dart
// ❌ GAGAL: SingleChildScrollView horizontal memberikan lebar tak terbatas.
// Expanded tidak dapat menghitung sisa lebar yang harus diambil.
Widget buildBrokenRow() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: const [
        Text('Status: '),
        Expanded(
          child: Text('Mahasiswa Aktif Jurusan Teknologi Informasi POLINEMA'),
        ),
      ],
    ),
  );
}
```
### Solusi dan perbaikan

### Jika Ingin Konten Bisa Di-scroll Horizontal
Hapus Expanded agar setiap widget menggunakan ukuran aslinya (intrinsic width):

```dart
// PERBAIKAN 1: Teks memanjang ke samping dan dapat digeser
Widget buildScrollableRow() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: const [
        Text('Status: '),
        Text('Mahasiswa Aktif Jurusan Teknologi Informasi POLINEMA'),
      ],
    ),
  );
}
```
### Jika Ingin Teks Turun ke Baris Baru (Wrap Teks)
Hapus SingleChildScrollView horizontal agar Row dibatasi oleh lebar layar perangkat, sehingga Expanded dapat bekerja normal:
```dart
// PERBAIKAN 2: Teks otomatis turun ke baris baru saat mencapai batas layar
Widget buildResponsiveRow() {
  return Row(
    children: const [
      Text('Status: '),
      Expanded(
        child: Text(
          'Mahasiswa Aktif Jurusan Teknologi Informasi POLINEMA',
          softWrap: true,
        ),
      ),
    ],
  );
}
```

## 3. Evaluasi dan Verifikasi Rekomendasi Layout Flutter

Berikut adalah hasil pemeriksaan terhadap rekomendasi layout yang telah dibahas:

### Responsivitas di Bawah 600px
* **Status:** **Aman dan Responsif.**
* **Analisis:** 
  * Pada breakpoint `kWideBreakpoint = 700.0`, logika `constraints.maxWidth >= 700 ? 2 : 1` memastikan layout beralih otomatis menjadi **1 kolom** saat dibuka pada layar ponsel (< 600px).
  * Penggunaan `SingleChildScrollView` sebagai wrapper utama mencegah terjadinya *vertical overflow error* (*bottom overflowed by pixels*) ketika tinggi layar terbatas atau saat keyboard virtual muncul.


### Dampak terhadap Aksesibilitas (A11y)
* **Status:** **Mendukung Aksesibilitas dengan Baik (Tidak Mengurangi A11y).**
* **Analisis:**
  * **Screen Reader:** Label semantik (`Semantics(label: ...)`) dipasang secara eksplisit pada komponen switch dan kartu data, sehingga *TalkBack* (Android) maupun *VoiceOver* (iOS) dapat membaca informasi secara runtut dan bermakna.
  * **Font Scaling & Dynamic Type:** Pada mode 1 kolom (< 700px), kartu informasi menggunakan `Expanded` pada label judul dan teks nilai secara horizontal di dalam `Card`. Teks tetap aman membesar mengikuti preferensi ukuran font sistem operasi tanpa memotong informasi penting.


### Ketersediaan Widget di Flutter Stabil Saat Ini
* **Status:** **100% Menggunakan API dan Widget Stabil.**
* **Analisis:**
  * Semua widget yang digunakan (`LayoutBuilder`, `SingleChildScrollView`, `GridView`, `Card`, `CupertinoSwitch`, `Semantics`) merupakan widget bawaan (*built-in*) yang sepenuhnya stabil dan backward-compatible.
  * Pewarnaan dan tipografi telah menggunakan standar modern Material 3 (`Theme.of(context).colorScheme` dan `Theme.of(context).textTheme`), serta `withValues(alpha: ...)` yang merupakan API resmi pengganti `withOpacity` di rilis Flutter stabil saat ini.

---

# Refeksi

## 1. Perbedaan Cara Berpikir Imperative dan Declarative dalam Membangun UI
* **Imperative:** Pola pikirnya berfokus pada *bagaimana mengubah UI secara manual langkah demi langkah* saat terjadi perubahan data. Kita harus mengontrol alur, memanggil instance widget/elemen tertentu, lalu memutasi propertinya (misal: `setText()`, `hideElement()`).
* **Declarative (Flutter):** Pola pikirnya berfokus pada *UI adalah representasi langsung dari state saat ini* ($UI = f(state)$). Kita hanya mendefinisikan bentuk antarmuka untuk tiap kondisi state. Ketika state berubah lewat `setState()`, Flutter secara otomatis me-*rebuild* dan menyesuaikan tampilannya tanpa perlu kita manipulasi elemennya satu per satu.

## 2. Kapan `Expanded` Membantu dan Kapan Menyebabkan Layout Error?
* **Membantu:** Saat kita ingin elemen di dalam `Row` atau `Column` mengisi seluruh sisa ruang kosong yang tersedia secara fleksibel, mencegah teks atau widget panjang terpotong (*overflow*), serta membuat pembagian porsi layout yang proporsional antar-widget.
* **Menyebabkan Error:** Ketika `Expanded` diletakkan di dalam container yang memiliki ukuran tanpa batas (*unbounded constraints*), misalnya di dalam `SingleChildScrollView` atau `ListView` yang searah dengan flex-nya (seperti `Row` di dalam scroll horizontal). Karena parent tidak punya batas dimensi maksimal (`maxWidth = double.infinity`), `Expanded` tidak bisa menghitung ruang yang harus diisi dan memicu error `BoxConstraints forces an infinite width`.

## 3. Pengaruh Breakpoint dan Theme terhadap Pengalaman Pengguna (UX)
* **Breakpoint:** Memastikan antarmuka tetap adaptif dan ergonomis di berbagai ukuran perangkat. Aplikasi tidak sekadar mengecilkan elemen di layar HP atau membiarkan ruang kosong mubazir di layar tablet/desktop, melainkan merestrukturisasi layout (misal: beralih dari 1 kolom ke multi-kolom) agar informasi tetap mudah dibaca dan diakses.
* **Theme:** Memberikan kenyamanan visual, konsistensi hierarki warna/tipografi, dan fleksibilitas bagi preferensi pengguna melalui adaptasi light mode dan dark mode. Penggunaan warna dinamis yang berbasis `colorScheme` juga menjaga keterbacaan (*contrast ratio*) tanpa menyilaukan mata saat kondisi minim cahaya.

## 4. Hal yang Diverifikasi dari Rekomendasi AI setelah Tugas Selesai
* **Kesesuaian Constraint & Layout:** Mengecek apakah struktur widget berpotensi memicu *overflow error* di berbagai resolusi layar ekstrem (terutama layar sempit < 600px).
* **Validitas API & Standar Versi:** Memastikan kode yang disarankan menggunakan API stabil terbaru (misal: penulisan Material 3 dan `withValues` alih-alih method yang sudah *deprecated*) serta tidak ada *syntax error* atau *empty statement* pada linter.
* **Aksesibilitas dan Kerapian Arsitektur:** Memastikan implementasi semantik (`Semantics`), struktur ekstraksi widget (reusable component), dan pemisahan konstanta benar-benar membuat kode lebih bersih (*maintainable*) tanpa merusak fungsionalitas aslinya.

