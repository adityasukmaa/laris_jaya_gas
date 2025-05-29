import 'package:json_annotation/json_annotation.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';

part 'akun_model.g.dart';

@JsonSerializable()
class Akun {
  final String idAkun;
  final String? idPerorangan;
  final String email;
  final String password;
  final String role;
  final bool statusAktif;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Perorangan? perorangan;

  Akun({
    required this.idAkun,
    this.idPerorangan,
    required this.email,
    required this.password,
    this.role = 'pelanggan',
    this.statusAktif = false,
    this.perorangan,
  });

  factory Akun.fromJson(Map<String, dynamic> json) => _$AkunFromJson(json);
  Map<String, dynamic> toJson() => _$AkunToJson(this);
}