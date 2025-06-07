class Pengembalian {
  final int? idPengembalian;
  final int? idPeminjaman;
  final DateTime? tanggalKembali;
  final String? kondisiTabung;
  final String? keterangan;

  Pengembalian({
    this.idPengembalian,
    this.idPeminjaman,
    this.tanggalKembali,
    this.kondisiTabung,
    this.keterangan,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      idPengembalian: json['id_pengembalian'],
      idPeminjaman: json['id_peminjaman'],
      tanggalKembali: json['tanggal_kembali'] != null
          ? DateTime.tryParse(json['tanggal_kembali'])
          : null,
      kondisiTabung: json['kondisi_tabung'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengembalian': idPengembalian,
      'id_peminjaman': idPeminjaman,
      'tanggal_kembali': tanggalKembali?.toIso8601String(),
      'kondisi_tabung': kondisiTabung,
      'keterangan': keterangan,
    };
  }
}
