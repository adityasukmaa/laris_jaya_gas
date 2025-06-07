class RiwayatTransaksi {
  final int? idRiwayatTransaksi;
  final int? idTransaksi;
  final int? idAkun;
  final int? idPerorangan;
  final int? idPerusahaan;
  final String? tanggalTransaksi;
  final int? totalTransaksi;
  final int? jumlahDibayar;
  final String? metodePembayaran;
  final String? tanggalJatuhTempo;
  final String? tanggalSelesai;
  final String? statusAkhir;
  final int? totalPembayaran;
  final int? denda;
  final int? durasiPeminjaman;
  final String? keterangan;

  RiwayatTransaksi({
    this.idRiwayatTransaksi,
    this.idTransaksi,
    this.idAkun,
    this.idPerorangan,
    this.idPerusahaan,
    this.tanggalTransaksi,
    this.totalTransaksi,
    this.jumlahDibayar,
    this.metodePembayaran,
    this.tanggalJatuhTempo,
    this.tanggalSelesai,
    this.statusAkhir,
    this.totalPembayaran,
    this.denda,
    this.durasiPeminjaman,
    this.keterangan,
  });

  factory RiwayatTransaksi.fromJson(Map<String, dynamic> json) {
    return RiwayatTransaksi(
      idRiwayatTransaksi: json['id_riwayat_transaksi'],
      idTransaksi: json['id_transaksi'],
      idAkun: json['id_akun'],
      idPerorangan: json['id_perorangan'],
      idPerusahaan: json['id_perusahaan'],
      tanggalTransaksi: json['tanggal_transaksi'],
      totalTransaksi: json['total_transaksi'],
      jumlahDibayar: json['jumlah_dibayar'],
      metodePembayaran: json['metode_pembayaran'],
      tanggalJatuhTempo: json['tanggal_jatuh_tempo'],
      tanggalSelesai: json['tanggal_selesai'],
      statusAkhir: json['status_akhir'],
      totalPembayaran: json['total_pembayaran'],
      denda: json['denda'],
      durasiPeminjaman: json['durasi_peminjaman'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_riwayat_transaksi': idRiwayatTransaksi,
      'id_transaksi': idTransaksi,
      'id_akun': idAkun,
      'id_perorangan': idPerorangan,
      'id_perusahaan': idPerusahaan,
      'tanggal_transaksi': tanggalTransaksi,
      'total_transaksi': totalTransaksi,
      'jumlah_dibayar': jumlahDibayar,
      'metode_pembayaran': metodePembayaran,
      'tanggal_jatuh_tempo': tanggalJatuhTempo,
      'tanggal_selesai': tanggalSelesai,
      'status_akhir': statusAkhir,
      'total_pembayaran': totalPembayaran,
      'denda': denda,
      'durasi_peminjaman': durasiPeminjaman,
      'keterangan': keterangan,
    };
  }
}
