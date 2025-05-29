import 'package:json_annotation/json_annotation.dart';

part 'perusahaan_model.g.dart';

@JsonSerializable()
class Perusahaan {
  final String idPerusahaan;
  final String namaPerusahaan;
  final String alamatPerusahaan;
  final String emailPerusahaan;

  Perusahaan({
    required this.idPerusahaan,
    required this.namaPerusahaan,
    required this.alamatPerusahaan,
    required this.emailPerusahaan,
  });

  factory Perusahaan.fromJson(Map<String, dynamic> json) => _$PerusahaanFromJson(json);
  Map<String, dynamic> toJson() => _$PerusahaanToJson(this);
}