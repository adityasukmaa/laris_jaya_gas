import 'package:json_annotation/json_annotation.dart';
import 'package:laris_jaya_gas/models/notifikasi_template_model.dart';

part 'notifikasi_model.g.dart';

@JsonSerializable()
class Notifikasi {
  final String idNotifikasi;
  final String idTagihan;
  final String idTemplate;
  final DateTime tanggalTerjadwal;
  final bool statusBaca;
  final String waktuDikirim;
  @JsonKey(includeFromJson: false, includeToJson: false)
  NotifikasiTemplate? template;

  Notifikasi({
    required this.idNotifikasi,
    required this.idTagihan,
    required this.idTemplate,
    required this.tanggalTerjadwal,
    required this.statusBaca,
    required this.waktuDikirim,
    this.template,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) =>
      _$NotifikasiFromJson(json);
  Map<String, dynamic> toJson() => _$NotifikasiToJson(this);
}
