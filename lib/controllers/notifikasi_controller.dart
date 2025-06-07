// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart';
// import '../models/notifikasi_model.dart';

// class NotifikasiController extends GetxController {
//   var notifikasiList = <Notifikasi>[].obs;
//   var isLoading = false.obs;

//   late SharedPreferences prefs;
//   late ApiService apiService;

//   @override
//   void onInit() async {
//     super.onInit();
//     prefs = await SharedPreferences.getInstance();
//     apiService = ApiService(prefs);
//     await loadNotifikasi();
//   }

//   Future<void> loadNotifikasi() async {
//     isLoading.value = true;
//     try {
//       final akunId = prefs.getString('id_akun') ?? '';
//       if (akunId.isNotEmpty) {
//         final notifikasis = await apiService.getNotifikasi(akunId);
//         notifikasiList.assignAll(notifikasis.cast<Notifikasi>());
//       }
//     } catch (e) {
//       print('Error loading notifikasi: $e');
//       Get.snackbar('Error', 'Gagal memuat notifikasi',
//           backgroundColor: Colors.red, colorText: Colors.white);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> markAsRead(String notifikasiId) async {
//     try {
//       await apiService.markNotifikasiAsRead(notifikasiId);
//       final index =
//           notifikasiList.indexWhere((n) => n.idNotifikasi == notifikasiId);
//       if (index != -1) {
//         notifikasiList[index].statusBaca = true;
//         notifikasiList.refresh();
//       }
//     } catch (e) {
//       print('Error marking notifikasi as read: $e');
//       Get.snackbar('Error', 'Gagal memperbarui status notifikasi',
//           backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }
// }
