import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdministratorController extends GetxController {
  var pendingAccounts = <Map<String, dynamic>>[].obs;
  var administratorProfile = <String, dynamic>{}.obs;
  var statistics = <String, dynamic>{}.obs;
  var isLoading = false.obs;

  late SharedPreferences prefs;
  late ApiService apiService;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    apiService = ApiService(prefs);
    await fetchAdministratorData();
  }

  Future<void> fetchAdministratorData() async {
    try {
      isLoading.value = true;
      final profile = await apiService.getAdministratorProfile();
      administratorProfile.value = profile['data'];
      final stats = await apiService.getStatistics();
      statistics.value = stats['data'];
      final pending = await apiService.getPendingAccounts();
      pendingAccounts.assignAll(pending.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmAccount(String email) async {
    try {
      isLoading.value = true;
      await apiService.confirmAccount(email);
      pendingAccounts.removeWhere((account) => account['email'] == email);
      Get.snackbar('Sukses', 'Akun berhasil dikonfirmasi',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
