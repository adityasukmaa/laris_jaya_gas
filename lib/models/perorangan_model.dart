class Perorangan {
  final int? idPerorangan;
  final String? namaLengkap;
  final String? nik;
  final String? noTelepon;
  final String? alamat;
  final int? idPerusahaan;

  Perorangan({
    this.idPerorangan,
    this.namaLengkap,
    this.nik,
    this.noTelepon,
    this.alamat,
    this.idPerusahaan,
  });

  factory Perorangan.fromJson(Map<String, dynamic> json) {
    return Perorangan(
      idPerorangan: json['id_perorangan'],
      namaLengkap: json['nama_lengkap'],
      nik: json['nik'],
      noTelepon: json['no_telepon'],
      alamat: json['alamat'],
      idPerusahaan: json['id_perusahaan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_perorangan': idPerorangan,
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'id_perusahaan': idPerusahaan,
    };
  }
}
