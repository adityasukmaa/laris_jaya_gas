import 'package:json_annotation/json_annotation.dart';

part 'riwayat_transaksi_model.g.dart';

@JsonSerializable()
class RiwayatTransaksi {
  final String idRiwayatTransaksi;
  final String idTransaksi;
  final String idAkun;
  final String idPerorangan;
  final String idPerusahaan;
  final DateTime tanggalTransaksi;
  final double totalTransaksi;
  final double jumlahDibayar;
  final String metodePembayaran;
  final DateTime? tanggalJatuhTempo;
  final DateTime tanggalSelesai;
  final String statusAkhir;
  final double totalPembayaran;
  final double denda;
  final int? durasiPeminjaman;
  final String keterangan;

  RiwayatTransaksi({
    required this.idRiwayatTransaksi,
    required this.idTransaksi,
    required this.idAkun,
    required this.idPerorangan,
    required this.idPerusahaan,
    required this.tanggalTransaksi,
    required this.totalTransaksi,
    required this.jumlahDibayar,
    required this.metodePembayaran,
    this.tanggalJatuhTempo,
    required this.tanggalSelesai,
    this.statusAkhir = 'success',
    required this.totalPembayaran,
    required this.denda,
    this.durasiPeminjaman,
    required this.keterangan,
  });

  factory RiwayatTransaksi.fromJson(Map<String, dynamic> json) => _$RiwayatTransaksiFromJson(json);
  Map<String, dynamic> toJson() => _$RiwayatTransaksiToJson(this);
}