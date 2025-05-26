import 'package:flutter/material.dart';

import '../models/tabung_model.dart';
import '../models/transaksi_model.dart';
import '../models/riwayat_transaksi_model.dart';

class DummyData {
  static final Map<String, dynamic> administratorData = {
    'name': 'Apriliady Rahman',
    'email': 'aprilia@gmail.com',
    'phone': '081355189363',
    'role': 'Administrator',
    'transaction_count': 16,
  };

  static final Map<String, dynamic> pelangganData = {
    'name': 'Budi Santoso',
    'email': 'budi@pelanggan.com',
    'phone': '081987654321',
    'role': 'Pelanggan',
    'transaction_count': 5,
  };

  static List<Tabung> tabungList = [
    Tabung(
        kodeTabung: 'TB001',
        jenisTabung: 'Oksigen',
        status: 'Tersedia',
        qrCode: 'base64string'),
    Tabung(
        kodeTabung: 'TB002',
        jenisTabung: 'Nitrogen',
        status: 'Dipinjam',
        qrCode: 'base64string'),
    Tabung(
        kodeTabung: 'TB003',
        jenisTabung: 'Argon',
        status: 'Tersedia',
        qrCode: 'base64string'),
  ];

  static final List<Transaksi> transaksiList = [
    Transaksi(
      idTransaksi: 'TR001',
      idAkun: null,
      idPerorangan: 'PL001',
      idPerusahaan: null,
      tanggalTransaksi: DateTime.now().subtract(const Duration(days: 5)),
      waktuTransaksi: TimeOfDay.now(),
      jumlahDibayar: 0,
      metodePembayaran: 'transfer',
      idStatusTransaksi: '1',
      tanggalJatuhTempo: DateTime.now().add(const Duration(days: 25)),
      status: 'pending',
      tanggalPeminjaman: DateTime.now(),
    ),
    Transaksi(
      idTransaksi: 'TR002',
      idAkun: null,
      idPerorangan: 'PL001',
      idPerusahaan: null,
      tanggalTransaksi: DateTime.now().subtract(const Duration(days: 10)),
      waktuTransaksi: TimeOfDay.now(),
      jumlahDibayar: 100000,
      metodePembayaran: 'tunai',
      idStatusTransaksi: '2',
      tanggalJatuhTempo: DateTime.now().subtract(const Duration(days: 3)),
      status: 'success',
      tanggalPeminjaman: DateTime.now(),
    ),
  ];

  static final List<RiwayatTransaksi> riwayatTransaksiList = [
    RiwayatTransaksi(
      idTransaksi: 'TR001',
      idAkun: null,
      idPerorangan: 'PL001',
      idPerusahaan: null,
      tanggalTransaksi: DateTime.now().subtract(const Duration(days: 5)),
      totalTransaksi: 200000,
      jumlahDibayar: 0,
      metodePembayaran: 'transfer',
      tanggalJatuhTempo: DateTime.now().add(const Duration(days: 25)),
      tanggalSelesai: null,
      statusAkhir: 'success',
      totalPembayaran: 0,
      denda: 0,
      durasiPeminjaman: null,
      keterangan: 'Peminjaman tabung',
    ),
  ];
}
