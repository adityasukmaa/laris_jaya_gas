class Perusahaan {
  final int? idPerusahaan;
  final String? namaPerusahaan;
  final String? alamatPerusahaan;
  final String? emailPerusahaan;

  Perusahaan({
    this.idPerusahaan,
    this.namaPerusahaan,
    this.alamatPerusahaan,
    this.emailPerusahaan,
  });

  factory Perusahaan.fromJson(Map<String, dynamic> json) {
    return Perusahaan(
      idPerusahaan: json['id_perusahaan'],
      namaPerusahaan: json['nama_perusahaan'],
      alamatPerusahaan: json['alamat_perusahaan'],
      emailPerusahaan: json['email_perusahaan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_perusahaan': idPerusahaan,
      'nama_perusahaan': namaPerusahaan,
      'alamat_perusahaan': alamatPerusahaan,
      'email_perusahaan': emailPerusahaan,
    };
  }
}
