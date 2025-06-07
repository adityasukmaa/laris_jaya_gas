// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:laris_jaya_gas/models/tabung_model.dart';
// import 'package:laris_jaya_gas/services/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class StokTabungController extends GetxController {
//   var selectedJenis = 'Semua'.obs;
//   var selectedStatus = 'Semua'.obs;
//   var filteredTabungList = <Tabung>[].obs;
//   var isLoading = false.obs;

//   late ApiService apiService;

//   @override
//   void onInit() {
//     super.onInit();
//     initializeApiService();
//   }

//   Future<void> initializeApiService() async {
//     final prefs = await SharedPreferences.getInstance();
//     apiService = ApiService(prefs);
//     await fetchTabungList();
//   }

//   Future<void> fetchTabungList() async {
//     try {
//       isLoading.value = true;
//       final tabungData = await apiService.getTabungs();
//       filteredTabungList.value =
//           tabungData.map((json) => Tabung.fromJson(json)).toList();
//       applyFilter();
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Gagal mengambil data tabung: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void applyFilter() {
//     var tempList = List<Tabung>.from(filteredTabungList);

//     print(
//         'Applying filter: Jenis=${selectedJenis.value}, Status=${selectedStatus.value}');
//     print('Initial tabung count: ${tempList.length}');

//     if (selectedJenis.value.isNotEmpty && selectedJenis.value != 'Semua') {
//       tempList = tempList
//           .where((tabung) =>
//               tabung.jenisTabung?.namaJenis == selectedJenis.value &&
//               tabung.jenisTabung != null)
//           .toList();
//       print('After jenis filter: ${tempList.length}');
//     }

//     if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'Semua') {
//       tempList = tempList
//           .where((tabung) =>
//               tabung.statusTabung?.statusTabung == selectedStatus.value &&
//               tabung.statusTabung != null)
//           .toList();
//       print('After status filter: ${tempList.length}');
//     }

//     filteredTabungList.value = tempList;
//     print('Final filtered tabung count: ${filteredTabungList.length}');

//     if (filteredTabungList.isEmpty) {
//       Get.snackbar(
//         'Info',
//         'Tidak ada tabung yang sesuai dengan filter.',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//     }
//   }

//   void refreshTabungList() {
//     fetchTabungList();
//   }

//   int get totalTabungByStatus {
//     return filteredTabungList.length;
//   }

//   int get totalTabungByJenis {
//     if (selectedJenis.value == 'Semua') {
//       return filteredTabungList.length;
//     }
//     return filteredTabungList
//         .where((tabung) =>
//             tabung.jenisTabung?.namaJenis == selectedJenis.value &&
//             tabung.jenisTabung != null)
//         .length;
//   }
// }
