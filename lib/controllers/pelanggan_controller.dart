import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../services/api_service.dart';
import '../models/akun_model.dart';
import '../models/tabung_model.dart';
import '../models/transaksi_model.dart';

class PelangganController extends GetxController {
  var akun = Rxn<Akun>();
  var activeCylinders = <Tabung>[].obs;
  var transactionHistory = <Transaksi>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final AuthController authController = Get.find<AuthController>();
  late ApiService apiService;
  late SharedPreferences prefs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    apiService = ApiService(prefs);
    if (authController.isLoggedIn.value &&
        authController.akunId.value.isNotEmpty) {
      loadCustomerData();
    } else {
      print('PelangganController: Skipping data load, user not logged in');
      errorMessage.value = 'Silakan login untuk melihat data pelanggan';
      Get.offAllNamed('/login');
    }
  }

  Future<void> loadCustomerData() async {
    print(
        'PelangganController: Loading customer data for akunId=${authController.akunId.value}');
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final profile = await apiService.getCustomerProfile();
      akun.value = profile;

      final cylinders = await apiService.getActiveCylinders();
      activeCylinders.assignAll(cylinders);

      final transactions = await apiService.getTransactionHistory();
      transactionHistory.assignAll(transactions);

      print(
          'PelangganController: Data loaded, activeCylinders=${activeCylinders.length}, '
          'transactionHistory=${transactionHistory.length}');
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: ${e.toString()}';
      print('PelangganController: Error loading data: $e');
      if (e.toString().contains('Unauthorized')) {
        errorMessage.value = 'Sesi habis, silakan login kembali';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Error',
            errorMessage.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          authController.logout();
          Get.offAllNamed('/login');
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Error',
            errorMessage.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getNearestDueDate() async {
    try {
      if (!authController.isLoggedIn.value ||
          authController.akunId.value.isEmpty) {
        return 'Tidak ada';
      }
      final response = await apiService.getNearestDueDate();
      return response['due_date'] ?? 'Tidak ada';
    } catch (e) {
      print('Error fetching nearest due date: $e');
      return 'Tidak ada';
    }
  }

  void viewCylinderDetails(String idTabung) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Detail Tabung',
        'Menampilkan detail tabung $idTabung.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    });
    Get.toNamed('/detail_tabung', arguments: idTabung);
  }

  void viewTransactionDetails(String idTransaksi) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Detail Transaksi',
        'Menampilkan detail transaksi $idTransaksi.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    });
    Get.toNamed('/detail_transaksi', arguments: idTransaksi);
  }
}
