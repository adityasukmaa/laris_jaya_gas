import 'package:get/get.dart';
import '../models/tabung_model.dart';
import 'tabung_controller.dart';

class StokTabungController extends GetxController {
  final TabungController tabungController = Get.find<TabungController>();

  var filteredTabungList = <Tabung>[].obs;

  var selectedJenis = 'Semua'.obs;
  var selectedStatus = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    filteredTabungList.assignAll(tabungController.tabungList);
  }

  void applyFilter() {
    var filtered = tabungController.tabungList.toList();

    if (selectedJenis.value != 'Semua') {
      filtered = filtered
          .where((tabung) => tabung.jenisTabung == selectedJenis.value)
          .toList();
    }

    if (selectedStatus.value != 'Semua') {
      filtered = filtered
          .where((tabung) => tabung.status.toLowerCase() == selectedStatus.value.toLowerCase())
          .toList();
    }

    filteredTabungList.assignAll(filtered);
  }
}