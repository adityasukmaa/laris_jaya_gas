import 'package:json_annotation/json_annotation.dart';

part 'status_tabung_model.g.dart';

@JsonSerializable()
class StatusTabung {
  final String idStatusTabung;
  final String statusTabung;

  StatusTabung({
    required this.idStatusTabung,
    required this.statusTabung,
  });

  factory StatusTabung.fromJson(Map<String, dynamic> json) =>
      _$StatusTabungFromJson(json);
  Map<String, dynamic> toJson() => _$StatusTabungToJson(this);
}
