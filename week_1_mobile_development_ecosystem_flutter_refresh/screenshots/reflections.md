1. Kapan native lebih tepat dipilih daripada cross-platform?

    Native lebih tepat dipilih ketika aplikasi membutuhkan performa yang tinggi dan cepat, karena memang lebih ringan.
    Sedangkan cross-platform lebih cocok kalau ingin menghemat waktu dan biaya, karena satu kode bisa digunakan untuk beberapa platform seperti Android dan iOS.

2. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?

    Dalam Flutter, state merupakan data atau kondisi yang dapat berubah dan perubahan tersebut bisa memengaruhi tampilan aplikasi. Ketika state berubah, Flutter akan melakukan rebuild pada bagian widget tree yang membutuhkan perubahan tersebut.
    Hal ini berhubungan dengan konsep UI deklaratif, yaitu kita tidak perlu mengatur satu per satu bagaimana tampilan harus berubah. Kita cukup menentukan "kalau state-nya seperti ini, maka UI-nya seperti ini", kemudian Flutter yang akan memperbarui tampilan sesuai state terbaru.

3. Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?

    Commit kecil dengan pesan yang jelas membuat perubahan kode menjadi lebih mudah dipahami, dilacak, dan diperbaiki. Dalam kerja tim, anggota lain juga bisa mengetahui apa yang sudah dikerjakan tanpa harus melihat semua perubahan kode.