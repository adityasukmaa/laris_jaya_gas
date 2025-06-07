class Notifikasi {
  final int? idNotifikasi;
  final int? idTagihan;
  final int? idTemplate;
  final String? tanggalTerjadwal;
  final bool? statusBaca;
  final String? waktuDikirim;

  Notifikasi({
    this.idNotifikasi,
    this.idTagihan,
    this.idTemplate,
    this.tanggalTerjadwal,
    this.statusBaca,
    this.waktuDikirim,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      idNotifikasi: json['id_notifikasi'],
      idTagihan: json['id_tagihan'],
      idTemplate: json['id_template'],
      tanggalTerjadwal: json['tanggal_terjadwal'],
      statusBaca: json['status_baca'],
      waktuDikirim: json['waktu_dikirim'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_notifikasi': idNotifikasi,
      'id_tagihan': idTagihan,
      'id_template': idTemplate,
      'tanggal_terjadwal': tanggalTerjadwal,
      'status_baca': statusBaca,
      'waktu_dikirim': waktuDikirim,
    };
  }
}
