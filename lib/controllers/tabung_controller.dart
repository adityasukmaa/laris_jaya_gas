import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/services/api_service.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class TabungController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  var tabungList = <Tabung>[].obs;
  var filteredTabungList = <Tabung>[].obs;
  var isLoadingTabung = false.obs;
  var errorMessageTabung = ''.obs;

  var selectedTabung = Rxn<Tabung>();
  var isLoadingDetail = false.obs;
  var errorMessageDetail = ''.obs;

  var selectedJenis = 'Semua'.obs;
  var selectedStatus = 'Semua'.obs;
  var jenisTabungList = <JenisTabung>[].obs;
  var statusTabungList = <StatusTabung>[].obs;

  var fieldErrors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTabung();
    fetchJenisTabung();
    fetchStatusTabung();
  }

  Future<void> fetchAllTabung() async {
    try {
      isLoadingTabung.value = true;
      errorMessageTabung.value = '';
      final tabungs = await apiService.getAllTabung();
      tabungList.assignAll(tabungs);
      applyFilter();
      if (tabungs.isEmpty) {
        errorMessageTabung.value = 'Tidak ada tabung ditemukan';
      }
    } catch (e) {
      errorMessageTabung.value = 'Gagal memuat data tabung: ${e.toString()}';
      Get.snackbar('Error', errorMessageTabung.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redFlame,
          colorText: Colors.white);
    } finally {
      isLoadingTabung.value = false;
    }
  }

  Future<void> fetchJenisTabung() async {
    try {
      final response =
          await apiService.getRequest('administrator/jenis-tabung');
      if (response['success'] && response['data'] != null) {
        jenisTabungList.assignAll((response['data'] as List)
            .map((json) => JenisTabung.fromJson(json))
            .toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil jenis tabung: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redFlame,
          colorText: Colors.white);
    }
  }

  Future<void> fetchStatusTabung() async {
    try {
      final response =
          await apiService.getRequest('administrator/status-tabung');
      if (response['success'] && response['data'] != null) {
        statusTabungList.assignAll((response['data'] as List)
            .map((json) => StatusTabung.fromJson(json))
            .toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil status tabung: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redFlame,
          colorText: Colors.white);
    }
  }

  void applyFilter() {
    filteredTabungList.assignAll(tabungList.where((tabung) {
      final matchJenis = selectedJenis.value == 'Semua' ||
          tabung.jenisTabung?.namaJenis == selectedJenis.value;
      final matchStatus = selectedStatus.value == 'Semua' ||
          tabung.statusTabung?.statusTabung == selectedStatus.value;
      return matchJenis && matchStatus;
    }).toList());
  }

  Future<void> fetchTabungById(int id) async {
    try {
      isLoadingDetail.value = true;
      errorMessageDetail.value = '';
      selectedTabung.value = null;
      final tabung = await apiService.getTabungById(id);
      if (tabung != null) {
        selectedTabung.value = tabung;
      } else {
        errorMessageDetail.value = 'Tabung tidak ditemukan';
        Get.snackbar('Error', errorMessageDetail.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.redFlame,
            colorText: Colors.white);
      }
    } catch (e) {
      errorMessageDetail.value = 'Gagal memuat detail tabung: ${e.toString()}';
      Get.snackbar('Error', errorMessageDetail.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redFlame,
          colorText: Colors.white);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> createTabung({
    required String kodeTabung,
    required int idJenisTabung,
    required int idStatusTabung,
  }) async {
    try {
      isLoadingTabung.value = true;
      errorMessageTabung.value = '';
      fieldErrors.clear();
      final response = await apiService.createTabung(
        kodeTabung: kodeTabung,
        idJenisTabung: idJenisTabung,
        idStatusTabung: idStatusTabung,
      );

      if (response['success']) {
        Get.snackbar(
            'Sukses', response['message'] ?? 'Tabung berhasil ditambahkan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.greenSuccess,
            colorText: Colors.white);
        await fetchAllTabung();
        Get.offNamed('/administrator/stok-tabung');
      } else {
        errorMessageTabung.value =
            response['message'] ?? 'Gagal menambahkan tabung';
        if (response['data'] is Map) {
          (response['data'] as Map<String, dynamic>).forEach((key, value) {
            fieldErrors[key] = (value is List) ? value[0] : value.toString();
          });
        }
        Get.snackbar('Error', errorMessageTabung.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.redFlame,
            colorText: Colors.white);
      }
    } catch (e) {
      errorMessageTabung.value = 'Gagal menambahkan tabung: ${e.toString()}';
      Get.snackbar('Error', errorMessageTabung.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redFlame,
          colorText: Colors.white);
    } finally {
      isLoadingTabung.value = false;
    }
  }

  Future<void> updateTabung({
    required int id,
    required String kodeTabung,
    required int idJenisTabung,
    required int idStatusTabung,
  }) async {
    try {
      isLoadingTabung.value = true;
      errorMessageTabung.value = '';
      fieldErrors.clear();
      final response = await apiService.updateTabung(
        id: id,
        kodeTabung: kodeTabung,
        idJenisTabung: idJenisTabung,
        idStatusTabung: idStatusTabung,
      );

      if (response['success']) {
        Get.snackbar(
            'Sukses', response['message'] ?? 'Tabung berhasil diperbarui',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.greenSuccess,
            colorText: Colors.white);
        await fetchTabungById(id);
        Get.offNamed('/administrator/detail-tabung', arguments: id);
      } else {
        errorMessageTabung.value =
            response['message'] ?? 'Gagal memperbarui tabung';
        if (response['data'] is Map) {
          (response['data'] as Map<String, dynamic>).forEach((key, value) {
            fieldErrors[key] = (value is List) ? value[0] : value.toString();
          });
        }
        Get.snackbar('Error', errorMessageTabung.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.redFlame,
            colorText: Colors.white);
      }
    } catch (e) {
      errorMessageTabung.value = 'Gagal memperbarui tabung: ${e.toString()}';
      Get.snackbar('Error', errorMessageTabung.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redFlame,
          colorText: Colors.white);
    } finally {
      isLoadingTabung.value = false;
    }
  }

  Future<void> deleteTabung(int id) async {
    try {
      isLoadingTabung.value = true;
      errorMessageTabung.value = '';
      final response = await apiService.deleteTabung(id);

      if (response['success']) {
        Get.snackbar('Sukses', response['message'] ?? 'Tabung berhasil dihapus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.greenSuccess,
            colorText: Colors.white);
        selectedTabung.value = null;
        Get.offNamed('/administrator/stok-tabung');
      } else {
        errorMessageTabung.value =
            response['message'] ?? 'Gagal menghapus tabung';
        Get.snackbar('Error', errorMessageTabung.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.redFlame,
            colorText: Colors.white);
      }
    } catch (e) {
      errorMessageTabung.value = 'Gagal menghapus tabung: ${e.toString()}';
      Get.snackbar('Error', errorMessageTabung.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redFlame,
          colorText: Colors.white);
    } finally {
      isLoadingTabung.value = false;
    }
  }
}
