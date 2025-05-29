import 'package:json_annotation/json_annotation.dart';
import 'package:laris_jaya_gas/models/akun_model.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
import 'package:laris_jaya_gas/models/status_transaksi_model.dart';

import 'detail_transaksi_model.dart';

part 'transaksi_model.g.dart';

@JsonSerializable()
class Transaksi {
  final String idTransaksi;
  final String? idAkun;
  final String? idPerorangan;
  final String? idPerusahaan;
  final DateTime tanggalTransaksi;
  final String waktuTransaksi;
  final double jumlahDibayar;
  final String metodePembayaran;
  final String idStatusTransaksi;
  final DateTime? tanggalJatuhTempo;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Akun? akun;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Perorangan? perorangan;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Perusahaan? perusahaan;
  @JsonKey(includeFromJson: false, includeToJson: false)
  StatusTransaksi? statusTransaksi;
  List<DetailTransaksi>? detailTransaksis; // Pastikan properti ini ada

  Transaksi({
    required this.idTransaksi,
    this.idAkun,
    this.idPerorangan,
    this.idPerusahaan,
    required this.tanggalTransaksi,
    required this.waktuTransaksi,
    required this.jumlahDibayar,
    required this.metodePembayaran,
    required this.idStatusTransaksi,
    this.tanggalJatuhTempo,
    this.akun,
    this.perorangan,
    this.perusahaan,
    this.statusTransaksi, required List<DetailTransaksi> detailTransaksis,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) =>
      _$TransaksiFromJson(json);
  Map<String, dynamic> toJson() => _$TransaksiToJson(this);
}
