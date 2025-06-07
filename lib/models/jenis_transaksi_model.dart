class JenisTransaksi {
  final String? idJenisTransaksi;
  final String? namaJenisTransaksi;

  JenisTransaksi({
    this.idJenisTransaksi,
    this.namaJenisTransaksi,
  });

  factory JenisTransaksi.fromJson(Map<String, dynamic> json) {
    return JenisTransaksi(
      idJenisTransaksi: json['id_jenis_transaksi']?.toString(),
      namaJenisTransaksi: json['nama_jenis_transaksi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_jenis_transaksi': idJenisTransaksi,
      'nama_jenis_transaksi': namaJenisTransaksi,
    };
  }
}
