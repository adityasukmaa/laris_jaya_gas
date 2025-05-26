import 'package:get/get.dart';
import '../models/tabung_model.dart';
import '../utils/dummy_data.dart';

class TabungController extends GetxController {
  var tabungList = <Tabung>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabungList.value = DummyData.tabungList;
  }
}

class TambahTabungController extends GetxController {
  final RxString selectedJenis = ''.obs;
  final RxString selectedStatus = 'Tersedia'.obs;

  void updateSelectedJenis(String value) => selectedJenis.value = value;
  void updateSelectedStatus(String value) => selectedStatus.value = value;
}
