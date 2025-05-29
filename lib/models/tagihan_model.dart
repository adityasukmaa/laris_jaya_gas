import 'package:json_annotation/json_annotation.dart';

part 'tagihan_model.g.dart';

@JsonSerializable()
class Tagihan {
  final String idTagihan;
  final String idTransaksi;
  final double jumlahDibayar;
  final double sisa;
  final String status;
  final DateTime? tanggalBayarTagihan;
  final int hariKeterlambatan;
  final int periodeKe;
  final String keterangan;

  Tagihan({
    required this.idTagihan,
    required this.idTransaksi,
    required this.jumlahDibayar,
    required this.sisa,
    required this.status,
    this.tanggalBayarTagihan,
    required this.hariKeterlambatan,
    required this.periodeKe,
    required this.keterangan,
  });

  factory Tagihan.fromJson(Map<String, dynamic> json) =>
      _$TagihanFromJson(json);
  Map<String, dynamic> toJson() => _$TagihanToJson(this);
}
