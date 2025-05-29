import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import '../../utils/dummy_data.dart';

class StokTabungController extends GetxController {
  var selectedJenis = 'Semua'.obs;
  var selectedStatus = 'Semua'.obs;
  var filteredTabungList = <Tabung>[].obs;

  @override
  void onInit() {
    super.onInit();
    applyFilter(); // Terapkan filter awal saat inisialisasi
  }

  void applyFilter() {
    var tempList = List<Tabung>.from(DummyData.tabungList);

    if (selectedJenis.value.isNotEmpty && selectedJenis.value != 'Semua') {
      tempList = tempList
          .where(
              (tabung) => tabung.jenisTabung?.namaJenis == selectedJenis.value)
          .toList();
    }

    if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'Semua') {
      tempList = tempList
          .where((tabung) =>
              tabung.statusTabung?.statusTabung == selectedStatus.value)
          .toList();
    }

    filteredTabungList.value = tempList;
  }
}
