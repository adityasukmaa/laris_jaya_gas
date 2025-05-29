import 'package:json_annotation/json_annotation.dart';

part 'jenis_transaksi_model.g.dart';

@JsonSerializable()
class JenisTransaksi {
  final String idJenisTransaksi;
  final String namaJenisTransaksi;

  JenisTransaksi({
    required this.idJenisTransaksi,
    required this.namaJenisTransaksi,
  });

  factory JenisTransaksi.fromJson(Map<String, dynamic> json) =>
      _$JenisTransaksiFromJson(json);
  Map<String, dynamic> toJson() => _$JenisTransaksiToJson(this);
}
