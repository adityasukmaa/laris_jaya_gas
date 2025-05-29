import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';

class TransaksiController extends GetxController {
  var transaksiList = <Transaksi>[].obs;

  @override
  void onInit() {
    // Inisialisasi data jika diperlukan
    super.onInit();
  }
}