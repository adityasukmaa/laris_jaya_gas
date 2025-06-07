class StatusTabung {
  final int? idStatusTabung;
  final String? statusTabung;

  StatusTabung({
    this.idStatusTabung,
    this.statusTabung,
  });

  factory StatusTabung.fromJson(Map<String, dynamic> json) {
    return StatusTabung(
      idStatusTabung: json['id_status_tabung'],
      statusTabung: json['status_tabung'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_status_tabung': idStatusTabung,
      'status_tabung': statusTabung,
    };
  }
}
