import 'package:laris_jaya_gas/models/jenis_transaksi_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';

class DetailTransaksi {
  final String? idDetailTransaksi;
  final String? idTransaksi;
  final String? idTabung;
  final String? idJenisTransaksi;
  final double? harga;
  final double? totalTransaksi;
  final DateTime? batasWaktuPeminjaman;
  final Tabung? tabung;
  final JenisTransaksi? jenisTransaksi;

  DetailTransaksi({
    this.idDetailTransaksi,
    this.idTransaksi,
    this.idTabung,
    this.idJenisTransaksi,
    this.harga,
    this.totalTransaksi,
    this.batasWaktuPeminjaman,
    this.tabung,
    this.jenisTransaksi,
  });

  factory DetailTransaksi.fromJson(Map<String, dynamic> json) {
    return DetailTransaksi(
      idDetailTransaksi: json['id_detail_transaksi']?.toString(),
      idTransaksi: json['id_transaksi']?.toString(),
      idTabung: json['id_tabung']?.toString(),
      idJenisTransaksi: json['id_jenis_transaksi']?.toString(),
      harga: (json['harga'] as num?)?.toDouble(),
      totalTransaksi: (json['total_transaksi'] as num?)?.toDouble(),
      batasWaktuPeminjaman: json['batas_waktu_peminjaman'] != null
          ? DateTime.tryParse(json['batas_waktu_peminjaman'])
          : null,
      tabung: json['tabung'] != null ? Tabung.fromJson(json['tabung']) : null,
      jenisTransaksi: json['jenis_transaksi'] != null
          ? JenisTransaksi.fromJson(json['jenis_transaksi'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_detail_transaksi': idDetailTransaksi,
      'id_transaksi': idTransaksi,
      'id_tabung': idTabung,
      'id_jenis_transaksi': idJenisTransaksi,
      'harga': harga,
      'total_transaksi': totalTransaksi,
      'batas_waktu_peminjaman': batasWaktuPeminjaman?.toIso8601String(),
      'tabung': tabung?.toJson(),
      'jenis_transaksi': jenisTransaksi?.toJson(),
    };
  }
}