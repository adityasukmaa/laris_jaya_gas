import 'package:json_annotation/json_annotation.dart';

part 'jenis_tabung_model.g.dart';

@JsonSerializable()
class JenisTabung {
  final String idJenisTabung;
  final String kodeJenis;
  final String namaJenis;
  final double harga;

  JenisTabung({
    required this.idJenisTabung,
    required this.kodeJenis,
    required this.namaJenis,
    required this.harga,
  });

  factory JenisTabung.fromJson(Map<String, dynamic> json) =>
      _$JenisTabungFromJson(json);
  Map<String, dynamic> toJson() => _$JenisTabungToJson(this);
}
