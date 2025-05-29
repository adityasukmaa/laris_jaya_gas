import 'package:json_annotation/json_annotation.dart';

part 'notifikasi_template_model.g.dart';

@JsonSerializable()
class NotifikasiTemplate {
  final String idTemplate;
  final String namaTemplate;
  final int hariSet;
  final String judul;
  final String isi;

  NotifikasiTemplate({
    required this.idTemplate,
    required this.namaTemplate,
    required this.hariSet,
    required this.judul,
    required this.isi,
  });

  factory NotifikasiTemplate.fromJson(Map<String, dynamic> json) =>
      _$NotifikasiTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$NotifikasiTemplateToJson(this);
}
