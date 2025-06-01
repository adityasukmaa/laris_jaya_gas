import 'package:json_annotation/json_annotation.dart';

part 'peminjaman_model.g.dart';

@JsonSerializable()
class Peminjaman {
  final String idPeminjaman;
  final String idDetailTransaksi;
  final DateTime tanggalPinjam;
  String statusPinjam;
  DateTime? tanggalKembali;

  Peminjaman({
    required this.idPeminjaman,
    required this.idDetailTransaksi,
    required this.tanggalPinjam,
    required this.statusPinjam,
    this.tanggalKembali,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) =>
      _$PeminjamanFromJson(json);
  Map<String, dynamic> toJson() => _$PeminjamanToJson(this);
}   
