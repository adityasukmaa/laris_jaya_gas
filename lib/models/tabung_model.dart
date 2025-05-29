import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';

class Tabung {
  String? idTabung;
  String kodeTabung;
  String? idJenisTabung;
  String? idStatusTabung;
  JenisTabung? jenisTabung;
  StatusTabung? statusTabung;
  String? qrCode; // Tambahkan properti ini

  Tabung({
    this.idTabung,
    required this.kodeTabung,
    this.idJenisTabung,
    this.idStatusTabung,
    this.jenisTabung,
    this.statusTabung,
    this.qrCode,
  });
  // Tambahkan metode fromJson
  factory Tabung.fromJson(Map<String, dynamic> json) {
    return Tabung(
      idTabung: json['id_tabung'] as String?,
      kodeTabung: json['kode_tabung'] as String,
      idJenisTabung: json['id_jenis_tabung'] as String?,
      idStatusTabung: json['id_status_tabung'] as String?,
    );
  }
}
