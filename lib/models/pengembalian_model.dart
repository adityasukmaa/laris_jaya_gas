import 'package:json_annotation/json_annotation.dart';

part 'pengembalian_model.g.dart';

@JsonSerializable()
class Pengembalian {
  final String idPengembalian;
  final String idPeminjaman;
  final DateTime tanggalKembali;
  final String kondisiTabung;
  final String keterangan;

  Pengembalian({
    required this.idPengembalian,
    required this.idPeminjaman,
    required this.tanggalKembali,
    required this.kondisiTabung,
    required this.keterangan,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) =>
      _$PengembalianFromJson(json);
  Map<String, dynamic> toJson() => _$PengembalianToJson(this);
}
