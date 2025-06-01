import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

class TransaksiController extends GetxController {
  var selectedJenisTransaksi = 'Semua'.obs;
  var selectedStatusTransaksi = 'Semua'.obs;
  var filteredTransaksiList = <Transaksi>[].obs;

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
}
