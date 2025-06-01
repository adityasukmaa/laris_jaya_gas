import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

class TransaksiController extends GetxController {
  var selectedJenisTransaksi = 'Semua'.obs;
  var selectedStatusTransaksi = 'Semua'.obs;
  var filteredTransaksiList = <Transaksi>[].obs;
  var transaksiList = <Transaksi>[].obs;
  var selectedTransaksi = Rx<Transaksi?>(null);

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi dengan semua transaksi dari dummy data
    filteredTransaksiList.value = DummyData.transaksiList;
  }

  void applyFilter() {
    List<Transaksi> tempList = List.from(DummyData.transaksiList);

    if (selectedJenisTransaksi.value != 'Semua') {
      tempList = tempList.where((transaksi) {
        return transaksi.detailTransaksis?.firstOrNull?.jenisTransaksi
                ?.namaJenisTransaksi ==
            selectedJenisTransaksi.value;
      }).toList();
    }

    if (selectedStatusTransaksi.value != 'Semua') {
      tempList = tempList.where((transaksi) {
        return transaksi.statusTransaksi?.status ==
            selectedStatusTransaksi.value;
      }).toList();
    }

    filteredTransaksiList.value = tempList;
  }

  // Metode untuk menyegarkan data dari DummyData dan menerapkan filter ulang
  void refreshTransaksiList() {
    applyFilter();
  }

  // Hitung total transaksi berjalan (status != 'success' atau memiliki tanggalJatuhTempo di masa depan)
  int get totalTransaksiBerjalan {
    final now = DateTime.now();
    return filteredTransaksiList
        .where((transaksi) =>
            transaksi.statusTransaksi?.status != 'success' ||
            (transaksi.tanggalJatuhTempo != null &&
                transaksi.tanggalJatuhTempo!.isAfter(now)))
        .length;
  }

  // Hitung total transaksi bulan ini (berdasarkan tanggalTransaksi)
  int get totalTransaksiBulanIni {
    final now = DateTime.now();
    return filteredTransaksiList
        .where((transaksi) =>
            transaksi.tanggalTransaksi.month == now.month &&
            transaksi.tanggalTransaksi.year == now.year)
        .length;
  }

  // void loadTransaksi() {
  //   transaksiList.value = DummyData.transaksiList
  //       .where((t) => t.idStatusTransaksi == 'STS002')
  //       .toList();
  // }

  // void selectTransaksi(Transaksi transaksi) {
  //   selectedTransaksi.value = transaksi;
  // }

  // void updateTransaksiStatus(
  //     String transaksiId, String statusId, double jumlahDibayar) {
  //   final index =
  //       DummyData.transaksiList.indexWhere((t) => t.idTransaksi == transaksiId);
  //   if (index != -1) {
  //     final transaksi = DummyData.transaksiList[index];
  //     transaksi.idStatusTransaksi = statusId;
  //     transaksi.jumlahDibayar = jumlahDibayar;
  //     transaksi.statusTransaksi = DummyData.statusTransaksiList
  //         .firstWhere((s) => s.idStatusTransaksi == statusId);
  //     DummyData.transaksiList[index] = transaksi;

  //     // Update tagihan menjadi lunas
  //     final tagihan =
  //         DummyData.tagihanList.firstWhere((t) => t.idTransaksi == transaksiId);
  //     tagihan.jumlahDibayar = jumlahDibayar;
  //     tagihan.sisa = 0;
  //     tagihan.status = 'lunas';

  //     loadTransaksi(); // Refresh daftar transaksi
  //   }
  // }
}
