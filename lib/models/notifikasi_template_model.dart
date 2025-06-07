class NotifikasiTemplate {
  final int? idTemplate;
  final String? namaTemplate;
  final int? hariSet;
  final String? judul;
  final String? isi;

  NotifikasiTemplate({
    this.idTemplate,
    this.namaTemplate,
    this.hariSet,
    this.judul,
    this.isi,
  });

  factory NotifikasiTemplate.fromJson(Map<String, dynamic> json) {
    return NotifikasiTemplate(
      idTemplate: json['id_template'],
      namaTemplate: json['nama_template'],
      hariSet: json['hari_set'],
      judul: json['judul'],
      isi: json['isi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_template': idTemplate,
      'nama_template': namaTemplate,
      'hari_set': hariSet,
      'judul': judul,
      'isi': isi,
    };
  }
}
