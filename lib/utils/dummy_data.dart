import 'package:laris_jaya_gas/models/akun_model.dart';
import 'package:laris_jaya_gas/models/detail_transaksi_model.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/jenis_transaksi_model.dart';
import 'package:laris_jaya_gas/models/notifikasi_model.dart';
import 'package:laris_jaya_gas/models/notifikasi_template_model.dart';
import 'package:laris_jaya_gas/models/peminjaman_model.dart';
import 'package:laris_jaya_gas/models/pengembalian_model.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
import 'package:laris_jaya_gas/models/riwayat_transaksi_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_transaksi_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/models/tagihan_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';

class DummyData {
  // Data Akun (Administrator dan Pelanggan)
  static final List<Akun> akunList = [
    Akun(
      idAkun: 'AKN001',
      idPerorangan: 'P001',
      email: 'administrator@gmail.com',
      password: 'administrator123',
      role: 'administrator',
      statusAktif: true,
      // perorangan: Perorangan(
      //   idPerorangan: 'P001',
      //   namaLengkap: 'Surendra',
      //   nik: '1234567890123456',
      //   noTelepon: '081355189363',
      //   alamat: 'Jl. Sudirman No. 1',
      // ),
    ),
    Akun(
      idAkun: 'AKN002',
      idPerorangan: 'P002',
      email: 'budi@pelanggan.com',
      password: 'pass123',
      role: 'pelanggan',
      statusAktif: true,
      perorangan: Perorangan(
        idPerorangan: 'P002',
        namaLengkap: 'Budi Santoso',
        nik: '9876543210987654',
        noTelepon: '081987654321',
        alamat: 'Jl. Merdeka No. 10',
      ),
    ),
  ];

  // Data Perorangan (Pelanggan)
  static final List<Perorangan> peroranganList = [
    Perorangan(
      idPerorangan: 'P001',
      namaLengkap: 'Apriliady Rahman',
      nik: '1234567890123456',
      noTelepon: '081355189363',
      alamat: 'Jl. Sudirman No. 1',
    ),
    Perorangan(
      idPerorangan: 'P002',
      namaLengkap: 'Budi Santoso',
      nik: '9876543210987654',
      noTelepon: '081987654321',
      alamat: 'Jl. Merdeka No. 10',
    ),
  ];

  // Data Perusahaan
  static final List<Perusahaan> perusahaanList = [
    Perusahaan(
      idPerusahaan: 'PR001',
      namaPerusahaan: 'PT Laris Jaya',
      alamatPerusahaan: 'Jl. Sudirman No. 1',
      emailPerusahaan: 'contact@larisjaya.com',
    ),
  ];

  // Data Jenis Tabung
  static final List<JenisTabung> jenisTabungList = [
    JenisTabung(
      idJenisTabung: 'JTG001',
      kodeJenis: 'OXY',
      namaJenis: 'oksigen',
      harga: 100000.0,
    ),
    JenisTabung(
      idJenisTabung: 'JTG002',
      kodeJenis: 'NT',
      namaJenis: 'nitrogen',
      harga: 120000.0,
    ),
    JenisTabung(
      idJenisTabung: 'JTG003',
      kodeJenis: 'AR',
      namaJenis: 'argon',
      harga: 150000.0,
    ),
  ];

  // Data Status Tabung
  static final List<StatusTabung> statusTabungList = [
    StatusTabung(
      idStatusTabung: 'STG001',
      statusTabung: 'tersedia',
    ),
    StatusTabung(
      idStatusTabung: 'STG002',
      statusTabung: 'dipinjam',
    ),
    StatusTabung(
      idStatusTabung: 'STG003',
      statusTabung: 'rusak',
    ),
  ];

  // Data Tabung
  static final List<Tabung> tabungList = [
    Tabung(
      idTabung: 'TBG001',
      kodeTabung: 'OXY001',
      idJenisTabung: 'JTG001',
      idStatusTabung: 'STG001',
      jenisTabung: jenisTabungList
          .firstWhere((jenis) => jenis.idJenisTabung == 'JTG001'),
      statusTabung: statusTabungList
          .firstWhere((status) => status.idStatusTabung == 'STG001'),
    ),
    Tabung(
      idTabung: 'TBG002',
      kodeTabung: 'NT001',
      idJenisTabung: 'JTG002',
      idStatusTabung: 'STG002',
      jenisTabung: jenisTabungList
          .firstWhere((jenis) => jenis.idJenisTabung == 'JTG002'),
      statusTabung: statusTabungList
          .firstWhere((status) => status.idStatusTabung == 'STG002'),
    ),
    Tabung(
      idTabung: 'TBG003',
      kodeTabung: 'AR001',
      idJenisTabung: 'JTG003',
      idStatusTabung: 'STG001',
      jenisTabung: jenisTabungList
          .firstWhere((jenis) => jenis.idJenisTabung == 'JTG003'),
      statusTabung: statusTabungList
          .firstWhere((status) => status.idStatusTabung == 'STG001'),
    ),
  ];

  // Data Status Transaksi
  static final List<StatusTransaksi> statusTransaksiList = [
    StatusTransaksi(
      idStatusTransaksi: 'STS001',
      status: 'success',
    ),
    StatusTransaksi(
      idStatusTransaksi: 'STS002',
      status: 'pending',
    ),
    StatusTransaksi(
      idStatusTransaksi: 'STS003',
      status: 'failed',
    ),
  ];

  // Data Jenis Transaksi
  static final List<JenisTransaksi> jenisTransaksiList = [
    JenisTransaksi(
      idJenisTransaksi: 'JTR001',
      namaJenisTransaksi: 'peminjaman',
    ),
    JenisTransaksi(
      idJenisTransaksi: 'JTR002',
      namaJenisTransaksi: 'isi ulang',
    ),
  ];

  // Data Detail Transaksi
  static final List<DetailTransaksi> detailTransaksiList = [
    DetailTransaksi(
      idDetailTransaksi: 'DTL001',
      idTransaksi: 'TR001',
      idTabung: 'TBG002',
      idJenisTransaksi: 'JTR001',
      harga: 120000.0,
      totalTransaksi: 120000.0,
      batasWaktuPeminjaman: DateTime.now().add(const Duration(days: 30)),
      tabung: tabungList.firstWhere((t) => t.idTabung == 'TBG002'),
      jenisTransaksi:
          jenisTransaksiList.firstWhere((j) => j.idJenisTransaksi == 'JTR001'),
    ),
    DetailTransaksi(
      idDetailTransaksi: 'DTL002',
      idTransaksi: 'TR002',
      idTabung: 'TBG003',
      idJenisTransaksi: 'JTR002',
      harga: 150000.0,
      totalTransaksi: 150000.0,
      batasWaktuPeminjaman: null,
      tabung: tabungList.firstWhere((t) => t.idTabung == 'TBG003'),
      jenisTransaksi:
          jenisTransaksiList.firstWhere((j) => j.idJenisTransaksi == 'JTR002'),
    ),
    DetailTransaksi(
      idDetailTransaksi: 'DTL003',
      idTransaksi: 'TRX001',
      idTabung: 'TBG001',
      idJenisTransaksi: 'JTR002',
      harga: 100000.0,
      totalTransaksi: 100000.0,
      batasWaktuPeminjaman: null,
      tabung: tabungList.firstWhere((t) => t.idTabung == 'TBG001'),
      jenisTransaksi:
          jenisTransaksiList.firstWhere((j) => j.idJenisTransaksi == 'JTR002'),
    ),
  ];

  // Data Transaksi
  static final List<Transaksi> transaksiList = [
    Transaksi(
      idTransaksi: 'TR001',
      idAkun: null,
      idPerorangan: 'P002',
      idPerusahaan: null,
      tanggalTransaksi: DateTime.now().subtract(const Duration(days: 5)),
      waktuTransaksi: '18:36:00',
      jumlahDibayar: 0,
      metodePembayaran: 'transfer',
      idStatusTransaksi: 'STS002',
      tanggalJatuhTempo: DateTime.now().add(const Duration(days: 25)),
      perorangan: peroranganList.firstWhere((p) => p.idPerorangan == 'P002'),
      statusTransaksi: statusTransaksiList
          .firstWhere((s) => s.idStatusTransaksi == 'STS002'),
      detailTransaksis: detailTransaksiList
          .where((detail) => detail.idTransaksi == 'TR001')
          .toList(),
    ),
    Transaksi(
      idTransaksi: 'TR002',
      idAkun: null,
      idPerorangan: 'P002',
      idPerusahaan: null,
      tanggalTransaksi: DateTime.now().subtract(const Duration(days: 10)),
      waktuTransaksi: '09:15:00',
      jumlahDibayar: 100000,
      metodePembayaran: 'tunai',
      idStatusTransaksi: 'STS001',
      tanggalJatuhTempo: DateTime.now().subtract(const Duration(days: 3)),
      perorangan: peroranganList.firstWhere((p) => p.idPerorangan == 'P002'),
      statusTransaksi: statusTransaksiList
          .firstWhere((s) => s.idStatusTransaksi == 'STS001'),
      detailTransaksis: detailTransaksiList
          .where((detail) => detail.idTransaksi == 'TR002')
          .toList(),
    ),
    Transaksi(
      idTransaksi: 'TRX001',
      idAkun: 'AKN001',
      idPerorangan: null,
      idPerusahaan: 'PR001',
      tanggalTransaksi: DateTime(2025, 5, 27),
      waktuTransaksi: '18:36:00',
      jumlahDibayar: 500000.0,
      metodePembayaran: 'transfer',
      idStatusTransaksi: 'STS001',
      tanggalJatuhTempo: null,
      akun: akunList.firstWhere((a) => a.idAkun == 'AKN001'),
      perusahaan: perusahaanList.firstWhere((p) => p.idPerusahaan == 'PR001'),
      statusTransaksi: statusTransaksiList
          .firstWhere((s) => s.idStatusTransaksi == 'STS001'),
      detailTransaksis: detailTransaksiList
          .where((detail) => detail.idTransaksi == 'TRX001')
          .toList(),
    ),
  ];

  // Data Peminjaman
  static final List<Peminjaman> peminjamanList = [
    Peminjaman(
      idPeminjaman: 'PIN001',
      idDetailTransaksi: 'DTL001',
      tanggalPinjam: DateTime.now().subtract(const Duration(days: 5)),
      statusPinjam: 'aktif',
      tanggalKembali: null,
    ),
  ];

  // Data Pengembalian
  static final List<Pengembalian> pengembalianList = [];

  // Data Tagihan
  static final List<Tagihan> tagihanList = [
    Tagihan(
      idTagihan: 'TAG001',
      idTransaksi: 'TR001',
      jumlahDibayar: 0,
      sisa: 120000.0,
      status: 'belum_lunas',
      tanggalBayarTagihan: null,
      hariKeterlambatan: 0,
      periodeKe: 0,
      keterangan: 'Belum dibayar',
    ),
    Tagihan(
      idTagihan: 'TAG002',
      idTransaksi: 'TR002',
      jumlahDibayar: 100000.0,
      sisa: 50000.0,
      status: 'belum_lunas',
      tanggalBayarTagihan: null,
      hariKeterlambatan: 3,
      periodeKe: 1,
      keterangan: 'Terlambat 3 hari',
    ),
  ];

  // Data Notifikasi Template
  static final List<NotifikasiTemplate> notifikasiTemplateList = [
    NotifikasiTemplate(
      idTemplate: 'TMP001',
      namaTemplate: 'Peringatan Jatuh Tempo',
      hariSet: -3,
      judul: 'Peringatan: Jatuh Tempo Peminjaman',
      isi:
          'Tabung Anda akan jatuh tempo dalam 3 hari. Harap segera kembalikan.',
    ),
  ];

  // Data Notifikasi
  static final List<Notifikasi> notifikasiList = [
    Notifikasi(
      idNotifikasi: 'NOT001',
      idTagihan: 'TAG001',
      idTemplate: 'TMP001',
      tanggalTerjadwal: DateTime.now().add(const Duration(days: 22)),
      statusBaca: false,
      waktuDikirim: '09:00:00',
      template:
          notifikasiTemplateList.firstWhere((t) => t.idTemplate == 'TMP001'),
    ),
  ];

  // Data Riwayat Transaksi
  static final List<RiwayatTransaksi> riwayatTransaksiList = [
    RiwayatTransaksi(
      idRiwayatTransaksi: 'RWT001',
      idTransaksi: 'TR002',
      idAkun: 'AKN002',
      idPerorangan: 'P002',
      idPerusahaan: '',
      tanggalTransaksi: DateTime.now().subtract(const Duration(days: 10)),
      totalTransaksi: 150000.0,
      jumlahDibayar: 100000.0,
      metodePembayaran: 'tunai',
      tanggalJatuhTempo: DateTime.now().subtract(const Duration(days: 3)),
      tanggalSelesai: DateTime.now().subtract(const Duration(days: 1)),
      statusAkhir: 'success',
      totalPembayaran: 100000.0,
      denda: 5000.0,
      durasiPeminjaman: null,
      keterangan: 'Transaksi selesai dengan denda keterlambatan',
    ),
  ];

  // Data untuk Dashboard (Administrator dan Pelanggan)
  static final Map<String, dynamic> administratorData = {
    'name': akunList
        .firstWhere((a) => a.role == 'administrator')
        .perorangan
        ?.namaLengkap,
    'email': akunList.firstWhere((a) => a.role == 'administrator').email,
    'phone': akunList
        .firstWhere((a) => a.role == 'administrator')
        .perorangan
        ?.noTelepon,
    'role': 'Administrator',
    'transaction_count': transaksiList.length,
  };

  static final Map<String, dynamic> pelangganData = {
    'name': akunList
        .firstWhere((a) => a.role == 'pelanggan')
        .perorangan
        ?.namaLengkap,
    'email': akunList.firstWhere((a) => a.role == 'pelanggan').email,
    'phone':
        akunList.firstWhere((a) => a.role == 'pelanggan').perorangan?.noTelepon,
    'role': 'Pelanggan',
    'transaction_count':
        transaksiList.where((t) => t.idPerorangan == 'P002').length,
  };

  static var transaksi;
}
