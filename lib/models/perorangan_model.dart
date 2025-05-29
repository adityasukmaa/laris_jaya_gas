import 'package:json_annotation/json_annotation.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';

part 'perorangan_model.g.dart';

@JsonSerializable()
class Perorangan {
  final String idPerorangan;
  final String namaLengkap;
  final String nik;
  final String noTelepon;
  final String alamat;
  final String? idPerusahaan;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Perusahaan? perusahaan;

  Perorangan({
    required this.idPerorangan,
    required this.namaLengkap,
    required this.nik,
    required this.noTelepon,
    required this.alamat,
    this.idPerusahaan,
    this.perusahaan,
  });

  factory Perorangan.fromJson(Map<String, dynamic> json) => _$PeroranganFromJson(json);
  Map<String, dynamic> toJson() => _$PeroranganToJson(this);
}