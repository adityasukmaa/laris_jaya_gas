class Peminjaman {
  final int? idPeminjaman;
  final int? idDetailTransaksi;
  final DateTime? tanggalPinjam;
  final String? statusPinjam;

  Peminjaman({
    this.idPeminjaman,
    this.idDetailTransaksi,
    this.tanggalPinjam,
    this.statusPinjam,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      idPeminjaman: json['id_peminjaman'],
      idDetailTransaksi: json['id_detail_transaksi'],
      tanggalPinjam: json['tanggal_pinjam'] != null ? DateTime.tryParse(json['tanggal_pinjam']) : null,
      statusPinjam: json['status_pinjam'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_peminjaman': idPeminjaman,
      'id_detail_transaksi': idDetailTransaksi,
      'tanggal_pinjam': tanggalPinjam?.toIso8601String(),
      'status_pinjam': statusPinjam,
    };
  }
}