import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/services/api_service.dart';

class TabungController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

// State untuk daftar tabung (Admin)
  var tabungList = <Tabung>[].obs;
  var filteredTabungList = <Tabung>[].obs;
  var isLoadingTabung = false.obs;
  var errorMessageTabung = ''.obs;

// State untuk tabung tersedia (Pelanggan)
  var tabungTersediaList = <Map<String, dynamic>>[].obs;
  var isLoadingTabungTersedia = false.obs;
  var errorMessageTabungTersedia = ''.obs;

// State untuk tabung aktif (Pelanggan)
  var tabungAktifList = <Tabung>[].obs;
  var isLoadingTabungAktif = false.obs;
  var errorMessageTabungAktif = ''.obs;

// State untuk detail tabung
  var selectedTabung = Rxn<Tabung>();
  var isLoadingDetail = false.obs;
  var errorMessageDetail = ''.obs;

// State untuk filter
  var selectedJenis = 'Semua'.obs;
  var selectedStatus = 'Semua'.obs;
  var jenisTabungList = <JenisTabung>[].obs;
  var statusTabungList = <StatusTabung>[].obs;

// State untuk field errors
  var fieldErrors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTabung();
    fetchTabungTersedia();
    fetchTabungAktif();
    fetchJenisTabung();
    fetchStatusTabung();
    filteredTabungList.assignAll(tabungList);
  }

// Fetch semua tabung (Admin)
  Future<void> fetchAllTabung() async {
    try {
      isLoadingTabung.value = true;
      errorMessageTabung.value = '';
      tabungList.clear();
      filteredTabungList.clear();

      final tabungs = await apiService.getAllTabung();
      tabungList.assignAll(tabungs);
      applyFilter();

      if (tabungs.isEmpty) {
        errorMessageTabung.value = 'Tidak ada tabung ditemukan';
      }
    } catch (e) {
      errorMessageTabung.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessageTabung.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingTabung.value = false;
    }
  }

// Fetch jenis tabung untuk Dropdown
  Future<void> fetchJenisTabung() async {
    try {
      final response =
          await apiService.getRequest('administrator/jenis-tabung');
      if (response['success'] && response['data'] != null) {
        jenisTabungList.assignAll(
          (response['data'] as List)
              .map((json) => JenisTabung.fromJson(json))
              .toList(),
        );
        if (jenisTabungList.isNotEmpty) {
          selectedJenis.value = jenisTabungList.first.namaJenis ?? 'Semua';
        }
      }
    } catch (e) {
      print('Gagal mengambil jenis tabung: $e');
    }
  }

// Fetch status tabung untuk Dropdown
  Future<void> fetchStatusTabung() async {
    try {
      final response =
          await apiService.getRequest('administrator/status-tabung');
      if (response['success'] && response['data'] != null) {
        statusTabungList.assignAll(
          (response['data'] as List)
              .map((json) => StatusTabung.fromJson(json))
              .toList(),
        );
        if (statusTabungList.isNotEmpty) {
          selectedStatus.value = statusTabungList.first.statusTabung ?? 'Semua';
        }
      }
    } catch (e) {
      print('Gagal mengambil status tabung: $e');
    }
  }

// Apply filter berdasarkan jenis dan status
  void applyFilter() {
    filteredTabungList.assignAll(tabungList.where((tabung) {
      final matchJenis = selectedJenis.value == 'Semua' ||
          tabung.jenisTabung?.namaJenis == selectedJenis.value;
      final matchStatus = selectedStatus.value == 'Semua' ||
          tabung.statusTabung?.statusTabung == selectedStatus.value;
      return matchJenis && matchStatus;
    }).toList());
  }

  // Fetch tabung berdasarkan ID (Admin)
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
        Get.snackbar(
          'Error',
          errorMessageDetail.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessageDetail.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessageDetail.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // Fetch tabung berdasarkan kode (Admin, untuk QR scan)
  Future<void> fetchTabungByKode(String kodeTabung) async {
    try {
      isLoadingDetail.value = true;
      errorMessageDetail.value = '';
      selectedTabung.value = null;

      final tabung = await apiService.getTabungByKode(kodeTabung);
      if (tabung != null) {
        selectedTabung.value = tabung;
        Get.toNamed(
          '/administrator/detail-tabung',
          arguments: tabung.kodeTabung,
        );
      } else {
        errorMessageDetail.value =
            'Tabung dengan kode $kodeTabung tidak ditemukan';
        Get.snackbar(
          'Error',
          errorMessageDetail.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessageDetail.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessageDetail.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // Tambah tabung baru (Admin)
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
          'Sukses',
          response['message'] ?? 'Tabung berhasil ditambahkan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchAllTabung();
        Get.back();
      } else {
        errorMessageTabung.value =
            response['message'] ?? 'Gagal menambahkan tabung';
        if (response['data'] != null && response['data'] is Map) {
          (response['data'] as Map<String, dynamic>).forEach((key, value) {
            fieldErrors[key] = (value is List) ? value[0] : value.toString();
          });
        }
        Get.snackbar(
          'Error',
          errorMessageTabung.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessageTabung.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessageTabung.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingTabung.value = false;
    }
  }

  // Update tabung (Admin)
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
          'Sukses',
          response['message'] ?? 'Tabung berhasil diperbarui',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchAllTabung();
        Get.back();
      } else {
        errorMessageTabung.value =
            response['message'] ?? 'Gagal memperbarui tabung';
        if (response['data'] != null && response['data'] is Map) {
          (response['data'] as Map<String, dynamic>).forEach((key, value) {
            fieldErrors[key] = (value is List) ? value[0] : value.toString();
          });
        }
        Get.snackbar(
          'Error',
          errorMessageTabung.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessageTabung.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessageTabung.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingTabung.value = false;
    }
  }

// Hapus tabung (Admin)
  Future<void> deleteTabung(int id) async {
    try {
      isLoadingTabung.value = true;
      errorMessageTabung.value = '';

      final response = await apiService.deleteTabung(id);

      if (response['success']) {
        Get.snackbar(
          'Sukses',
          response['message'] ?? 'Tabung berhasil dihapus',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchAllTabung();
      } else {
        errorMessageTabung.value =
            response['message'] ?? 'Gagal menghapus tabung';
        Get.snackbar(
          'Error',
          errorMessageTabung.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessageTabung.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessageTabung.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingTabung.value = false;
    }
  }

// Fetch tabung tersedia (Pelanggan)
  Future<void> fetchTabungTersedia() async {
    try {
      isLoadingTabungTersedia.value = true;
      errorMessageTabungTersedia.value = '';
      tabungTersediaList.clear();

      final tabungs = await apiService.getTabungTersedia();
      tabungTersediaList.assignAll(tabungs);

      if (tabungs.isEmpty) {
        errorMessageTabungTersedia.value = 'Tidak ada tabung tersedia';
      }
    } catch (e) {
      errorMessageTabungTersedia.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessageTabungTersedia.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingTabungTersedia.value = false;
    }
  }

// Fetch tabung aktif (Pelanggan)
  Future<void> fetchTabungAktif() async {
    try {
      isLoadingTabungAktif.value = true;
      errorMessageTabungAktif.value = '';
      tabungAktifList.clear();

      final tabungs = await apiService.getTabungAktif();
      tabungAktifList.assignAll(tabungs);

      if (tabungs.isEmpty) {
        errorMessageTabungAktif.value = 'Tidak ada tabung aktif';
      }
    } catch (e) {
      errorMessageTabungAktif.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessageTabungAktif.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingTabungAktif.value = false;
    }
  }
}
