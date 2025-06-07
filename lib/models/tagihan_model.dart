class Tagihan {
  final int? idTagihan;
  final int? idTransaksi;
  final double? jumlahDibayar;
  final double? sisa;
  final String? status;
  final DateTime? tanggalBayarTagihan;
  final int? hariKeterlambatan;
  final int? periodeKe;
  final String? keterangan;

  Tagihan({
    this.idTagihan,
    this.idTransaksi,
    this.jumlahDibayar,
    this.sisa,
    this.status,
    this.tanggalBayarTagihan,
    this.hariKeterlambatan,
    this.periodeKe,
    this.keterangan,
  });

  factory Tagihan.fromJson(Map<String, dynamic> json) {
    return Tagihan(
      idTagihan: json['id_tagihan'],
      idTransaksi: json['id_transaksi'],
      jumlahDibayar: (json['jumlah_dibayar'] as num?)?.toDouble(),
      sisa: (json['sisa'] as num?)?.toDouble(),
      status: json['status'],
      tanggalBayarTagihan: json['tanggal_bayar_tagihan'] != null ? DateTime.tryParse(json['tanggal_bayar_tagihan']) : null,
      hariKeterlambatan: json['hari_keterlambatan'],
      periodeKe: json['periode_ke'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tagihan': idTagihan,
      'id_transaksi': idTransaksi,
      'jumlah_dibayar': jumlahDibayar,
      'sisa': sisa,
      'status': status,
      'tanggal_bayar_tagihan': tanggalBayarTagihan?.toIso8601String(),
      'hari_keterlambatan': hariKeterlambatan,
      'periode_ke': periodeKe,
      'keterangan': keterangan,
    };
  }
}