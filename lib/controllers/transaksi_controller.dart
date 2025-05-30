import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

class TransaksiController extends GetxController {
  var selectedJenisTransaksi = 'Semua'.obs;
  var selectedStatusTransaksi = 'Semua'.obs;
  var filteredTransaksiList = <Transaksi>[].obs;

  // Tambahkan variabel reaktif untuk total transaksi
  var _totalTransaksiBerjalan = 0.obs;
  var _totalTransaksiBulanIni = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi dengan semua transaksi dari dummy data
    filteredTransaksiList.value = DummyData.transaksiList;
    // Hitung awal untuk total transaksi
    updateTotals();
  }

  void applyFilter() {
    List<Transaksi> tempList = List.from(DummyData.transaksiList);

    if (selectedJenisTransaksi.value != 'Semua') {
      tempList = tempList.where((transaksi) {
        return transaksi.detailTransaksis?.isNotEmpty ?? false
            ? transaksi.detailTransaksis!.first.jenisTransaksi
                    ?.namaJenisTransaksi ==
                selectedJenisTransaksi.value
            : false;
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

  // Metode untuk memperbarui total transaksi secara reaktif
  void updateTotals() {
    final now = DateTime.now();
    _totalTransaksiBerjalan.value = DummyData.transaksiList
        .where((transaksi) =>
            transaksi.statusTransaksi?.status != 'success' ||
            (transaksi.tanggalJatuhTempo != null &&
                transaksi.tanggalJatuhTempo!.isAfter(now)))
        .length;
    _totalTransaksiBulanIni.value = DummyData.transaksiList
        .where((transaksi) =>
            transaksi.tanggalTransaksi.month == now.month &&
            transaksi.tanggalTransaksi.year == now.year)
        .length;
  }

  // Getter reaktif untuk total transaksi
  int get totalTransaksiBerjalan => _totalTransaksiBerjalan.value;
  int get totalTransaksiBulanIni => _totalTransaksiBulanIni.value;
}
