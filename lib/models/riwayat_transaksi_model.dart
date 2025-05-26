class RiwayatTransaksi {
  final String idTransaksi;
  final String? idAkun;
  final String? idPerorangan;
  final String? idPerusahaan;
  final DateTime tanggalTransaksi;
  final double totalTransaksi;
  final double jumlahDibayar;
  final String metodePembayaran;
  final DateTime? tanggalJatuhTempo;
  final DateTime? tanggalSelesai;
  final String statusAkhir;
  final double totalPembayaran;
  final double denda;
  final int? durasiPeminjaman;
  final String keterangan;

  RiwayatTransaksi({
    required this.idTransaksi,
    this.idAkun,
    this.idPerorangan,
    this.idPerusahaan,
    required this.tanggalTransaksi,
    required this.totalTransaksi,
    required this.jumlahDibayar,
    required this.metodePembayaran,
    this.tanggalJatuhTempo,
    this.tanggalSelesai,
    required this.statusAkhir,
    required this.totalPembayaran,
    required this.denda,
    this.durasiPeminjaman,
    required this.keterangan,
  });
}
