class Tagihan {
  final String? idTagihan;
  final String? idTransaksi;
  final double? jumlahDibayar;
  final double? sisa;
  final String? status;
  final String? tanggalBayarTagihan;
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
      idTagihan: json['id_tagihan']?.toString(),
      idTransaksi: json['id_transaksi']?.toString(),
      jumlahDibayar: (json['jumlah_dibayar'] != null)
          ? double.tryParse(json['jumlah_dibayar'].toString())
          : null,
      sisa: (json['sisa'] != null)
          ? double.tryParse(json['sisa'].toString())
          : null,
      status: json['status'],
      tanggalBayarTagihan: json['tanggal_bayar_tagihan'],
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
      'tanggal_bayar_tagihan': tanggalBayarTagihan,
      'hari_keterlambatan': hariKeterlambatan,
      'periode_ke': periodeKe,
      'keterangan': keterangan,
    };
  }
}
