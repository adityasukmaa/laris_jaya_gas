import 'package:get/get.dart';
import '../models/transaksi_model.dart';
import '../utils/dummy_data.dart';

class TransaksiController extends GetxController {
  var transaksiList = <Transaksi>[].obs;

  @override
  void onInit() {
    super.onInit();
    transaksiList.value = DummyData.transaksiList;
  }
}
