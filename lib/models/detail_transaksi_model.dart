import 'package:laris_jaya_gas/models/jenis_transaksi_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';

class DetailTransaksi {
  final String? idDetailTransaksi;
  final String? idTransaksi;
  final String? idTabung;
  final String? idJenisTransaksi;
  final String? kodeTabung;
  final String? namaJenisTransaksi;
  final double? harga;
  final DateTime? batasWaktuPeminjaman;
  final Map<String, dynamic>? peminjaman;
  final Tabung? tabung;
  final JenisTransaksi? jenisTransaksi;

  DetailTransaksi({
    this.idDetailTransaksi,
    this.idTransaksi,
    this.idTabung,
    this.idJenisTransaksi,
    this.kodeTabung,
    this.namaJenisTransaksi,
    this.harga,
    this.batasWaktuPeminjaman,
    this.peminjaman,
    this.tabung,
    this.jenisTransaksi,
  });

  factory DetailTransaksi.fromJson(Map<String, dynamic> json) {
    return DetailTransaksi(
      idDetailTransaksi: json['id_detail_transaksi']?.toString(),
      idTransaksi: json['id_transaksi']?.toString(),
      idTabung: json['id_tabung']?.toString(),
      idJenisTransaksi: json['id_jenis_transaksi']?.toString(),
      kodeTabung: json['kode_tabung'] as String?,
      namaJenisTransaksi: json['jenis_transaksi'] as String?,
      harga: (json['harga'] != null)
          ? double.tryParse(json['harga'].toString())
          : null,
      batasWaktuPeminjaman: json['batas_waktu_peminjaman'] != null
          ? DateTime.tryParse(json['batas_waktu_peminjaman'] as String)
          : null,
      peminjaman: json['peminjaman'] as Map<String, dynamic>?,
      tabung: json['tabung'] != null
          ? Tabung.fromJson(json['tabung'] as Map<String, dynamic>)
          : null,
      jenisTransaksi: json['jenis_transaksi'] is Map<String, dynamic>
          ? JenisTransaksi.fromJson(
              json['jenis_transaksi'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_detail_transaksi': idDetailTransaksi,
      'id_transaksi': idTransaksi,
      'id_tabung': idTabung,
      'id_jenis_transaksi': idJenisTransaksi,
      'kode_tabung': kodeTabung,
      'nama_jenis_transaksi': namaJenisTransaksi,
      'harga': harga,
      'batas_waktu_peminjaman': batasWaktuPeminjaman?.toIso8601String(),
      'peminjaman': peminjaman,
      'tabung': tabung?.toJson(),
      'jenis_transaksi': jenisTransaksi?.toJson(),
    };
  }
}
