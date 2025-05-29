import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/akun_model.dart';
import 'package:laris_jaya_gas/models/detail_transaksi_model.dart';
import 'package:laris_jaya_gas/models/jenis_transaksi_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
import 'package:laris_jaya_gas/models/status_transaksi_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';

class DatabaseService {
  // Simulasi pengambilan data dari database
  Future<List<Transaksi>> fetchTransaksiWithRelations() async {
    // Misalnya, data diambil dari API atau database
    final List<Map<String, dynamic>> transaksiJsonList = [
      {
        'id_transaksi': 'TRX001',
        'id_akun': 'AKN001',
        'id_perorangan': null,
        'id_perusahaan': 'PR001',
        'tanggal_transaksi':
            '2025-05-27T01:11:00.000Z', // Sesuaikan dengan waktu saat ini
        'waktu_transaksi': '18:36:00',
        'jumlah_dibayar': 500000.0,
        'metode_pembayaran': 'transfer',
        'id_status_transaksi': 'STS001',
        'tanggal_jatuh_tempo': null,
      },
    ];

    final List<Map<String, dynamic>> akunJsonList = [
      {
        'id_akun': 'AKN001',
        'email': 'admin@larisjaya.com',
        'password': 'pass123',
        'role': 'administrator',
        'status_aktif': true,
      },
    ];

    final List<Map<String, dynamic>> perusahaanJsonList = [
      {
        'id_perusahaan': 'PR001',
        'nama_perusahaan': 'PT Laris Jaya',
        'alamat_perusahaan': 'Jl. Sudirman No. 1',
        'email_perusahaan': 'contact@larisjaya.com',
      },
    ];

    final List<Map<String, dynamic>> statusTransaksiJsonList = [
      {'id_status_transaksi': 'STS001', 'status': 'success'},
    ];

    final List<Map<String, dynamic>> detailTransaksiJsonList = [
      {
        'id_detail_transaksi': 'DTL001',
        'id_transaksi': 'TRX001',
        'id_tabung': 'TBG001',
        'id_jenis_transaksi': 'JTR001',
        'harga': 100000.0,
        'total_transaksi': 100000.0,
        'batas_waktu_peminjaman': null,
      },
    ];

    final List<Map<String, dynamic>> tabungJsonList = [
      {
        'id_tabung': 'TBG001',
        'kode_tabung': 'OXY001',
        'id_jenis_tabung': 'JTG001',
        'id_status_tabung': 'STG001',
      },
    ];

    final List<Map<String, dynamic>> jenisTabungJsonList = [
      {
        'id_jenis_tabung': 'JTG001',
        'kode_jenis': 'OXY',
        'nama_jenis': 'Oksigen', // Konsisten dengan DummyData
        'harga': 100000.0,
      },
    ];

    final List<Map<String, dynamic>> statusTabungJsonList = [
      {'id_status_tabung': 'STG001', 'status_tabung': 'tersedia'},
    ];

    final List<Map<String, dynamic>> jenisTransaksiJsonList = [
      {
        'id_jenis_transaksi': 'JTR001',
        'nama_jenis_transaksi': 'peminjaman'
      }, // Sesuaikan dengan DummyData
    ];

    // Parsing data ke model
    final List<Akun> akuns =
        akunJsonList.map((json) => Akun.fromJson(json)).toList();
    final List<Perusahaan> perusahaans =
        perusahaanJsonList.map((json) => Perusahaan.fromJson(json)).toList();
    final List<StatusTransaksi> statusTransaksis = statusTransaksiJsonList
        .map((json) => StatusTransaksi.fromJson(json))
        .toList();
    final List<DetailTransaksi> detailTransaksis = detailTransaksiJsonList
        .map((json) => DetailTransaksi.fromJson(json))
        .toList();
    final List<Tabung> tabungs =
        tabungJsonList.map((json) => Tabung.fromJson(json)).toList();
    final List<JenisTabung> jenisTabungs =
        jenisTabungJsonList.map((json) => JenisTabung.fromJson(json)).toList();
    final List<StatusTabung> statusTabungs = statusTabungJsonList
        .map((json) => StatusTabung.fromJson(json))
        .toList();
    final List<JenisTransaksi> jenisTransaksis = jenisTransaksiJsonList
        .map((json) => JenisTransaksi.fromJson(json))
        .toList();

    // Mapping relasi
    final List<Transaksi> transaksis = transaksiJsonList.map((json) {
      final transaksi = Transaksi.fromJson(json);
      transaksi.akun =
          akuns.firstWhereOrNull((akun) => akun.idAkun == transaksi.idAkun);
      transaksi.perusahaan = perusahaans.firstWhereOrNull(
          (perusahaan) => perusahaan.idPerusahaan == transaksi.idPerusahaan);
      transaksi.statusTransaksi = statusTransaksis.firstWhereOrNull(
          (status) => status.idStatusTransaksi == transaksi.idStatusTransaksi);
      return transaksi;
    }).toList();

    for (var detail in detailTransaksis) {
      detail.tabung = tabungs
          .firstWhereOrNull((tabung) => tabung.idTabung == detail.idTabung);
      detail.jenisTransaksi = jenisTransaksis.firstWhereOrNull(
          (jenis) => jenis.idJenisTransaksi == detail.idJenisTransaksi);
      detail.tabung?.jenisTabung = jenisTabungs.firstWhereOrNull(
          (jenis) => jenis.idJenisTabung == detail.tabung?.idJenisTabung);
      detail.tabung?.statusTabung = statusTabungs.firstWhereOrNull(
          (status) => status.idStatusTabung == detail.tabung?.idStatusTabung);
    }

    // Relasi transaksi ke detail transaksi
    for (var transaksi in transaksis) {
      transaksi.detailTransaksis = detailTransaksis
          .where((detail) => detail.idTransaksi == transaksi.idTransaksi)
          .toList();
    }

    return transaksis;
  }
}
