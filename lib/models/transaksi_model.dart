import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
import 'package:laris_jaya_gas/models/detail_transaksi_model.dart';
import 'package:laris_jaya_gas/models/tagihan_model.dart';

class Transaksi {
  final String? idTransaksi;
  final String? idAkun;
  final String? idPerorangan;
  final String? idPerusahaan;
  final String? tanggalTransaksi;
  final String? waktuTransaksi;
  final double? totalTransaksi;
  final double? jumlahDibayar;
  final String? metodePembayaran;
  final String? idStatusTransaksi;
  final String? tanggalJatuhTempo;
  final String? statusTransaksi;
  final List<DetailTransaksi>? detailTransaksis;
  final List<Tagihan>? tagihans;
  final List<Perusahaan>? perusahaan;
  final List<Perorangan>? perorangan;
  final Perorangan? pelanggan;
  final Perorangan? namaLengkap;

  Transaksi({
    this.idTransaksi,
    this.idAkun,
    this.idPerorangan,
    this.idPerusahaan,
    this.tanggalTransaksi,
    this.waktuTransaksi,
    this.totalTransaksi,
    this.jumlahDibayar,
    this.metodePembayaran,
    this.idStatusTransaksi,
    this.tanggalJatuhTempo,
    this.statusTransaksi,
    this.detailTransaksis,
    this.tagihans,
    this.perusahaan,
    this.perorangan,
    this.pelanggan,
    this.namaLengkap,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    print(
        'Parsing Transaksi: id_transaksi=${json['id_transaksi']} (${json['id_transaksi']?.runtimeType})');
    return Transaksi(
      idTransaksi: json['id_transaksi']?.toString(),
      idAkun: json['id_akun']?.toString(),
      idPerorangan: json['id_perorangan']?.toString(),
      idPerusahaan: json['id_perusahaan']?.toString(),
      tanggalTransaksi: json['tanggal_transaksi'] as String?,
      waktuTransaksi: json['waktu_transaksi'] as String?,
      totalTransaksi: (json['total_transaksi'] != null)
          ? double.tryParse(json['total_transaksi'].toString())
          : null,
      jumlahDibayar: (json['jumlah_dibayar'] != null)
          ? double.tryParse(json['jumlah_dibayar'].toString())
          : null,
      metodePembayaran: json['metode_pembayaran'] as String?,
      idStatusTransaksi: json['id_status_transaksi']?.toString(),
      tanggalJatuhTempo: json['tanggal_jatuh_tempo'] as String?,
      statusTransaksi: json['status_transaksi']?.toString(),
      detailTransaksis: json['detail_transaksis'] != null
          ? (json['detail_transaksis'] as List<dynamic>)
              .map((item) =>
                  DetailTransaksi.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      tagihans: json['tagihans'] != null
          ? (json['tagihans'] as List<dynamic>)
              .map((item) => Tagihan.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      // Mem-parsing objek 'pelanggan' yang bersarang (nested)
      pelanggan: json['pelanggan'] != null
          ? Perorangan.fromJson(json['pelanggan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transaksi': idTransaksi,
      'id_akun': idAkun,
      'id_perorangan': idPerorangan,
      'id_perusahaan': idPerusahaan,
      'tanggal_transaksi': tanggalTransaksi,
      'waktu_transaksi': waktuTransaksi,
      'total_transaksi': totalTransaksi,
      'jumlah_dibayar': jumlahDibayar,
      'metode_pembayaran': metodePembayaran,
      'id_status_transaksi': idStatusTransaksi,
      'tanggal_jatuh_tempo': tanggalJatuhTempo,
      'status_transaksi': statusTransaksi,
      'detail_transaksis': detailTransaksis?.map((e) => e.toJson()).toList(),
      'tagihans': tagihans?.map((e) => e.toJson()).toList(),
      'pelanggan': pelanggan?.toJson(),
    };
  }
}
