class CustomerProfile {
  final int idAkun;
  final String email;
  final String role;
  final String statusAktif;
  final String? namaLengkap;
  final String? nik;
  final String? noTelepon;
  final String? alamat;
  final String? namaPerusahaan;
  final String? alamatPerusahaan;

  CustomerProfile({
    required this.idAkun,
    required this.email,
    required this.role,
    required this.statusAktif,
    this.namaLengkap,
    this.nik,
    this.noTelepon,
    this.alamat,
    this.namaPerusahaan,
    this.alamatPerusahaan,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      idAkun: json['id_akun'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      statusAktif: json['status_aktif'] ? 'Aktif' : 'Non-Aktif',
      namaLengkap: json['nama_lengkap'],
      nik: json['nik'],
      noTelepon: json['no_telepon'],
      alamat: json['alamat'],
      namaPerusahaan: json['nama_perusahaan'],
      alamatPerusahaan: json['alamat_perusahaan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_akun': idAkun,
      'email': email,
      'role': role,
      'status_aktif': statusAktif == 'Aktif',
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'nama_perusahaan': namaPerusahaan,
      'alamat_perusahaan': alamatPerusahaan,
    };
  }
}
