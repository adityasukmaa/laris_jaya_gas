// controllers/admin_controller.dart
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/peminjaman_model.dart';
import 'package:laris_jaya_gas/models/pengembalian_model.dart';
import 'package:laris_jaya_gas/models/riwayat_transaksi_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

class AdministratorController extends GetxController {
  // Confirm tabung pickup
  void konfirmasiPengambilan(String transaksiId, List<String> tabungIds) {
    for (var tabungId in tabungIds) {
      final tabungIndex =
          DummyData.tabungList.indexWhere((t) => t.idTabung == tabungId);
      DummyData.tabungList[tabungIndex] = Tabung(
        idTabung: tabungId,
        kodeTabung: DummyData.tabungList[tabungIndex].kodeTabung,
        idJenisTabung: DummyData.tabungList[tabungIndex].idJenisTabung,
        idStatusTabung: 'STG002', // dipinjam
      );
    }

    final transaksiIndex =
        DummyData.transaksiList.indexWhere((t) => t.idTransaksi == transaksiId);
    final transaksi = DummyData.transaksiList[transaksiIndex];
    DummyData.transaksiList[transaksiIndex] = Transaksi(
      idTransaksi: transaksiId,
      idAkun: transaksi.idAkun,
      idPerorangan: transaksi.idPerorangan,
      idPerusahaan: transaksi.idPerusahaan,
      tanggalTransaksi: transaksi.tanggalTransaksi,
      waktuTransaksi: transaksi.waktuTransaksi,
      jumlahDibayar: transaksi.jumlahDibayar,
      metodePembayaran: transaksi.metodePembayaran,
      idStatusTransaksi: 'STS001', // success
      tanggalJatuhTempo: transaksi.tanggalJatuhTempo,
      detailTransaksis: transaksi.detailTransaksis,
    );

    final riwayatId =
        'RIW${DummyData.riwayatTransaksiList.length + 1}'.padLeft(6, '0');
    DummyData.riwayatTransaksiList.add(
      RiwayatTransaksi(
        idRiwayatTransaksi: riwayatId,
        idTransaksi: transaksiId,
        idAkun: transaksi.idAkun,
        idPerorangan: transaksi.idPerorangan,
        idPerusahaan: transaksi.idPerusahaan,
        tanggalTransaksi: transaksi.tanggalTransaksi,
        totalTransaksi: transaksi.detailTransaksis!
            .fold(0.0, (sum, d) => sum + d.totalTransaksi),
        jumlahDibayar: transaksi.jumlahDibayar,
        metodePembayaran: transaksi.metodePembayaran,
        tanggalJatuhTempo: transaksi.tanggalJatuhTempo,
        tanggalSelesai: DateTime.now(),
        statusAkhir: 'success',
        totalPembayaran: transaksi.jumlahDibayar,
        denda: calculateDenda(transaksi.tanggalJatuhTempo ?? DateTime.now()),
        durasiPeminjaman: transaksi.detailTransaksis!
                .any((d) => d.idJenisTransaksi == 'JTR001')
            ? 30
            : null,
        keterangan: 'Pengambilan tabung dikonfirmasi',
      ),
    );

    Get.snackbar('Sukses', 'Pengambilan tabung dikonfirmasi.');
  }

  // Confirm tabung return
  void konfirmasiPengembalian(
      String peminjamanId, String kondisiTabung, String keterangan) {
    final pengembalianId =
        'PGL${DummyData.pengembalianList.length + 1}'.padLeft(6, '0');
    DummyData.pengembalianList.add(
      Pengembalian(
        idPengembalian: pengembalianId,
        idPeminjaman: peminjamanId,
        tanggalKembali: DateTime.now(),
        kondisiTabung: kondisiTabung,
        keterangan: keterangan,
      ),
    );

    final peminjamanIndex = DummyData.peminjamanList
        .indexWhere((p) => p.idPeminjaman == peminjamanId);
    DummyData.peminjamanList[peminjamanIndex] = Peminjaman(
      idPeminjaman: peminjamanId,
      idDetailTransaksi:
          DummyData.peminjamanList[peminjamanIndex].idDetailTransaksi,
      tanggalPinjam: DummyData.peminjamanList[peminjamanIndex].tanggalPinjam,
      statusPinjam: 'selesai',
    );

    final detailTransaksi = DummyData.detailTransaksiList.firstWhere(
      (d) =>
          d.idDetailTransaksi ==
          DummyData.peminjamanList[peminjamanIndex].idDetailTransaksi,
    );
    final tabungIndex = DummyData.tabungList
        .indexWhere((t) => t.idTabung == detailTransaksi.idTabung);
    DummyData.tabungList[tabungIndex] = Tabung(
      idTabung: DummyData.tabungList[tabungIndex].idTabung,
      kodeTabung: DummyData.tabungList[tabungIndex].kodeTabung,
      idJenisTabung: DummyData.tabungList[tabungIndex].idJenisTabung,
      idStatusTabung: kondisiTabung == 'baik' ? 'STG001' : 'STG003',
    );

    final riwayatId =
        'RIW${DummyData.riwayatTransaksiList.length + 1}'.padLeft(6, '0');
    final transaksi = DummyData.transaksiList
        .firstWhere((t) => t.idTransaksi == detailTransaksi.idTransaksi);
    DummyData.riwayatTransaksiList.add(
      RiwayatTransaksi(
        idRiwayatTransaksi: riwayatId,
        idTransaksi: detailTransaksi.idTransaksi,
        idAkun: transaksi.idAkun,
        idPerorangan: transaksi.idPerorangan,
        idPerusahaan: transaksi.idPerusahaan,
        tanggalTransaksi: transaksi.tanggalTransaksi,
        totalTransaksi: transaksi.detailTransaksis!
            .fold(0.0, (sum, d) => sum + d.totalTransaksi),
        jumlahDibayar: transaksi.jumlahDibayar,
        metodePembayaran: transaksi.metodePembayaran,
        tanggalJatuhTempo: transaksi.tanggalJatuhTempo,
        tanggalSelesai: DateTime.now(),
        statusAkhir: 'success',
        totalPembayaran: transaksi.jumlahDibayar,
        denda: calculateDenda(transaksi.tanggalJatuhTempo ?? DateTime.now()),
        durasiPeminjaman: 30,
        keterangan: 'Pengembalian tabung: $kondisiTabung',
      ),
    );

    Get.snackbar('Sukses', 'Pengembalian tabung berhasil.');
  }

  // Calculate fine
  double calculateDenda(DateTime tanggalJatuhTempo) {
    final now = DateTime.now();
    final daysLate = now.difference(tanggalJatuhTempo).inDays;
    final monthsLate = daysLate ~/ 30;
    return monthsLate > 0 ? monthsLate * 70000.0 : 0;
  }
}
