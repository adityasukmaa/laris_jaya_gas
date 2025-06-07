class JenisTabung {
  final int? idJenisTabung;
  final String? kodeJenis;
  final String? namaJenis;
  final double? harga;

  JenisTabung({
    this.idJenisTabung,
    this.kodeJenis,
    this.namaJenis,
    this.harga,
  });

  factory JenisTabung.fromJson(Map<String, dynamic> json) {
    return JenisTabung(
      idJenisTabung: json['id_jenis_tabung'],
      kodeJenis: json['kode_jenis'],
      namaJenis: json['nama_jenis'],
      harga: (json['harga'] != null)
          ? double.tryParse(json['harga'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_jenis_tabung': idJenisTabung,
      'kode_jenis': kodeJenis,
      'nama_jenis': namaJenis,
      'harga': harga,
    };
  }
}
