import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaksi_model.dart';
import '../services/api_service.dart';

class TransaksiController extends GetxController {
  var transaksiList = <Transaksi>[].obs;
  var selectedTransaksi = Rx<Transaksi?>(null);
  var selectedJenisTransaksi = 'Semua'.obs;
  var selectedStatusTransaksi = 'Semua'.obs;
  var filteredTransaksiList = <Transaksi>[].obs;
  late ApiService apiService;
  late SharedPreferences prefs;

  @override
  void onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
    apiService = ApiService(prefs);
    await loadTransaksi();
    applyFilter();
  }

  Future<void> loadTransaksi() async {
    final akunIdString = prefs.getString('akun_id') ?? '';
    if (akunIdString.isEmpty) return;
    try {
      final akunId = int.parse(akunIdString);
      transaksiList.value = await apiService.getTransaksis(akunId);
      filteredTransaksiList.value = transaksiList;
    } catch (e) {
      print('Error parsing akun_id or fetching transaksis: $e');
    }
  }

  void selectTransaksi(Transaksi transaksi) {
    selectedTransaksi.value = transaksi;
  }

  Future<void> updateTransaksiStatus(String transaksiId, String statusId, double jumlahDibayar) async {
    // Implementasi update status via API
    await loadTransaksi();
    applyFilter();
  }

  void applyFilter() {
    List<Transaksi> tempList = List.from(transaksiList);

    if (selectedJenisTransaksi.value != 'Semua') {
      tempList = tempList.where((transaksi) {
        return transaksi.detailTransaksis?.firstOrNull?.jenisTransaksi?.namaJenisTransaksi == selectedJenisTransaksi.value;
      }).toList();
    }

    if (selectedStatusTransaksi.value != 'Semua') {
      tempList = tempList.where((transaksi) {
        return transaksi.statusTransaksi?.status == selectedStatusTransaksi.value;
      }).toList();
    }

    filteredTransaksiList.value = tempList;
  }

  int get totalTransaksiBerjalan {
    final now = DateTime.now();
    return filteredTransaksiList.where((transaksi) =>
        transaksi.statusTransaksi?.status != 'success' ||
        (transaksi.tanggalJatuhTempo != null && transaksi.tanggalJatuhTempo!.isAfter(now))).length;
  }

  int get totalTransaksiBulanIni {
    final now = DateTime.now();
    return filteredTransaksiList.where((transaksi) =>
        transaksi.tanggalTransaksi.month == now.month &&
        transaksi.tanggalTransaksi.year == now.year).length;
  }
}