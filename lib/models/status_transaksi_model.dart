class StatusTransaksi {
  final String? idStatusTransaksi;
  final String? status;

  StatusTransaksi({
    this.idStatusTransaksi,
    this.status,
  });

  factory StatusTransaksi.fromJson(Map<String, dynamic> json) {
    return StatusTransaksi(
      idStatusTransaksi: json['id_status_transaksi']?.toString(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_status_transaksi': idStatusTransaksi,
      'status': status,
    };
  }
}
