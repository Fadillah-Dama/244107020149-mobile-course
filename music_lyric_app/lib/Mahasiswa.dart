class Mahasiswa {
  String? nama;
  String? nim;
  String? jurusan;

  Mahasiswa({this.nama, this.nim, this.jurusan});

  void tampilkanInfo() {
    print('Nama: $nama');
    print('NIM: $nim');
    print('Jurusan: $jurusan');
  }
}