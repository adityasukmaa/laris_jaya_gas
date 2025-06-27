import 'package:laris_jaya_gas/models/akun_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';

class Perorangan {
  final int? idPerorangan;
  final String? idAkun;
  final String? namaLengkap;
  final String? nik;
  final String? noTelepon;
  final String? alamat;
  final int? idPerusahaan;
  final String? namaPerusahaan;
  final Akun? akun;
  final Perusahaan? perusahaan;

  Perorangan({
    this.idPerorangan,
    this.idAkun,
    this.namaLengkap,
    this.nik,
    this.noTelepon,
    this.alamat,
    this.idPerusahaan,
    this.namaPerusahaan,
    this.akun,
    this.perusahaan,
  });

  factory Perorangan.fromJson(Map<String, dynamic> json) {
    return Perorangan(
      idPerorangan: json['id_perorangan'],
      idAkun: json['id_akun']?.toString(),
      namaLengkap: json['nama_lengkap'],
      nik: json['nik'],
      noTelepon: json['no_telepon'],
      alamat: json['alamat'],
      idPerusahaan: json['id_perusahaan'],
      akun: json['akun'] != null ? Akun.fromJson(json['akun']) : null,
      perusahaan: json['perusahaan'] != null
          ? Perusahaan.fromJson(json['perusahaan'])
          : null,
    );
  }

  get email => null;

  Map<String, dynamic> toJson() {
    return {
      'id_perorangan': idPerorangan,
      'id_akun': idAkun,
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'id_perusahaan': idPerusahaan,
      'akun': akun?.toJson(),
      'perusahaan': perusahaan?.toJson(),
    };
  }
}
