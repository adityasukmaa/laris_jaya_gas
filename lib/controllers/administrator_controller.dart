import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/services/api_service.dart';

class AdministratorController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final administratorProfile = <String, dynamic>{}.obs;
  final statistics = <String, dynamic>{}.obs;
  final pendingAccounts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchStatistics();
    fetchPendingAccounts();
  }

  // Fetch admin profile
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getAdministratorProfile();

      if (response['success']) {
        administratorProfile.value = response['data'] ?? {};
      } else {
        errorMessage.value = response['message'] ?? 'Gagal mengambil profil';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch statistics
  Future<void> fetchStatistics() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getStatistics();

      if (response['success']) {
        statistics.value = response['data'] ?? {};
      } else {
        errorMessage.value = response['message'] ?? 'Gagal mengambil statistik';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch pending accounts
  Future<void> fetchPendingAccounts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getPendingAccounts();

      if (response['success']) {
        pendingAccounts.value =
            List<Map<String, dynamic>>.from(response['data'] ?? []);
      } else {
        errorMessage.value =
            response['message'] ?? 'Gagal mengambil daftar akun pending';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Confirm account
  Future<void> confirmAccount(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.confirmAccount(email);

      if (response['success']) {
        Get.snackbar(
          'Sukses',
          response['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh daftar akun pending
        await fetchPendingAccounts();
      } else {
        errorMessage.value = response['message'] ?? 'Gagal mengkonfirmasi akun';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
