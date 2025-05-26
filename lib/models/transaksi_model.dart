import 'package:flutter/material.dart';

class Transaksi {
  final String idTransaksi;
  final String? idAkun;
  final String? idPerorangan;
  final String? idPerusahaan;
  final DateTime tanggalTransaksi;
  final TimeOfDay waktuTransaksi;
  final double jumlahDibayar;
  final String metodePembayaran;
  final String idStatusTransaksi;
  final DateTime? tanggalJatuhTempo;
  final String status;

  var kodeTabung;

  final DateTime tanggalPeminjaman;

  Transaksi({
    required this.idTransaksi,
    this.idAkun,
    this.idPerorangan,
    this.idPerusahaan,
    required this.tanggalTransaksi,
    required this.waktuTransaksi,
    required this.jumlahDibayar,
    required this.metodePembayaran,
    required this.idStatusTransaksi,
    this.tanggalJatuhTempo,
    required this.status,
    required this.tanggalPeminjaman,
  });
}
