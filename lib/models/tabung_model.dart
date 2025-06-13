import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';

class Tabung {
  final int? idTabung;
  final String? kodeTabung;
  final int? idJenisTabung;
  final int? idStatusTabung;
  final String? namaJenis;
  final String? qrCode;

  JenisTabung? jenisTabung;

  StatusTabung? statusTabung;

  Tabung({
    this.idTabung,
    this.kodeTabung,
    this.idJenisTabung,
    this.idStatusTabung,
    this.namaJenis,
    this.qrCode,
    this.jenisTabung,
    this.statusTabung,
  });

  factory Tabung.fromJson(Map<String, dynamic> json) {
    return Tabung(
      idTabung: json['id_tabung'],
      kodeTabung: json['kode_tabung'],
      idJenisTabung: json['id_jenis_tabung'],
      idStatusTabung: json['id_status_tabung'],
      namaJenis: json['nama_jenis'],
      jenisTabung: json['jenis_tabung'] != null
          ? JenisTabung.fromJson(json['jenis_tabung'] as Map<String, dynamic>)
          : null,
      statusTabung: json['status_tabung'] != null
          ? StatusTabung.fromJson(json['status_tabung'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tabung': idTabung,
      'kode_tabung': kodeTabung,
      'id_jenis_tabung': idJenisTabung,
      'id_status_tabung': idStatusTabung,
      'nama_jenis': namaJenis,
    };
  }
}
