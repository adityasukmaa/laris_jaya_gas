import 'package:json_annotation/json_annotation.dart';

part 'status_transaksi_model.g.dart';

@JsonSerializable()
class StatusTransaksi {
  final String idStatusTransaksi;
  final String status;

  StatusTransaksi({
    required this.idStatusTransaksi,
    required this.status,
  });

  factory StatusTransaksi.fromJson(Map<String, dynamic> json) =>
      _$StatusTransaksiFromJson(json);
  Map<String, dynamic> toJson() => _$StatusTransaksiToJson(this);
}
