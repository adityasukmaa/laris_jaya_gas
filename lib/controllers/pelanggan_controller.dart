import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/auth_controller.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

class PelangganController extends GetxController {
  var namaPelanggan = ''.obs;
  var emailPelanggan = ''.obs;
  var accountStatus = 'Aktif'.obs;
  var activeCylinders = <Map<String, dynamic>>[].obs;
  var transactionHistory = <Map<String, dynamic>>[].obs;

  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    loadCustomerData();
  }

  void loadCustomerData() {
    print('PelangganController: Loading customer data'); // Debugging
    final pelangganData = DummyData.pelangganData;
    namaPelanggan.value = pelangganData['name'] ?? 'Unknown';
    emailPelanggan.value = pelangganData['email'] ?? 'Unknown';
    accountStatus.value =
        authController.isLoggedIn.value ? 'Aktif' : 'Non-Aktif';

    activeCylinders.clear();
    for (var peminjaman in DummyData.peminjamanList) {
      final detailTransaksi = DummyData.detailTransaksiList.firstWhere(
          (dt) => dt.idDetailTransaksi == peminjaman.idDetailTransaksi);
      final tabung = DummyData.tabungList
          .firstWhere((t) => t.idTabung == detailTransaksi.idTabung);
      final jenisTabung = DummyData.jenisTabungList
          .firstWhere((jt) => jt.idJenisTabung == tabung.idJenisTabung);
      if (peminjaman.statusPinjam == 'aktif') {
        activeCylinders.add({
          'idTabung': tabung.idTabung,
          'kodeTabung': tabung.kodeTabung,
          'namaJenis': jenisTabung.namaJenis,
          'statusTabung': tabung.statusTabung?.statusTabung ?? 'Unknown',
        });
      }
    }

    transactionHistory.clear();
    for (var transaksi in DummyData.transaksiList.where(
        (t) => t.idPerorangan == DummyData.pelangganData['idPerorangan'])) {
      final detailTransaksi = DummyData.detailTransaksiList
          .where((dt) => dt.idTransaksi == transaksi.idTransaksi)
          .toList();
      for (var dt in detailTransaksi) {
        final jenisTransaksi = DummyData.jenisTransaksiList
            .firstWhere((jt) => jt.idJenisTransaksi == dt.idJenisTransaksi);
        transactionHistory.add({
          'idTransaksi': transaksi.idTransaksi,
          'namaJenisTransaksi': jenisTransaksi.namaJenisTransaksi,
          'tanggalTransaksi':
              transaksi.tanggalTransaksi.toString().substring(0, 10),
          'status': transaksi.statusTransaksi?.status ?? 'Unknown',
        });
      }
    }
    print(
        'PelangganController: Data loaded, activeCylinders=${activeCylinders.length}, '
        'transactionHistory=${transactionHistory.length}'); // Debugging
  }

  String getNearestDueDate() {
    DateTime? nearestDueDate;
    for (var peminjaman in DummyData.peminjamanList) {
      final detailTransaksi = DummyData.detailTransaksiList.firstWhere(
          (dt) => dt.idDetailTransaksi == peminjaman.idDetailTransaksi);
      if (detailTransaksi.batasWaktuPeminjaman != null &&
          peminjaman.statusPinjam == 'aktif') {
        if (nearestDueDate == null ||
            detailTransaksi.batasWaktuPeminjaman!.isBefore(nearestDueDate)) {
          nearestDueDate = detailTransaksi.batasWaktuPeminjaman;
        }
      }
    }
    return nearestDueDate != null
        ? nearestDueDate.toString().substring(0, 10)
        : 'Tidak ada';
  }

  void viewCylinderDetails(String cylinderId) {
    Get.snackbar('Detail Tabung', 'Menampilkan detail tabung $cylinderId.');
    Get.toNamed(AppRoutes.detailTabung, arguments: cylinderId);
  }

  void viewTransactionDetails(String transactionId) {
    Get.snackbar(
        'Detail Transaksi', 'Menampilkan detail transaksi $transactionId.');
    final transaksi = DummyData.transaksiList
        .firstWhere((t) => t.idTransaksi == transactionId);
    Get.toNamed(AppRoutes.detailTransaksiAdministrator, arguments: transaksi);
  }
}
