class Akun {
  final int? idAkun;
  final int? idPerorangan;
  final String? email;
  final String? password;
  final String? role;
  final bool? statusAktif;

  Akun({
    this.idAkun,
    this.idPerorangan,
    this.email,
    this.password,
    this.role,
    this.statusAktif,
  });

  factory Akun.fromJson(Map<String, dynamic> json) {
    return Akun(
      idAkun: json['id_akun'],
      idPerorangan: json['id_perorangan'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      statusAktif: json['status_aktif'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_akun': idAkun,
      'id_perorangan': idPerorangan,
      'email': email,
      'password': password,
      'role': role,
      'status_aktif': statusAktif,
    };
  }
}
