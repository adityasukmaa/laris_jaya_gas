import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/akun_model.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
import 'package:laris_jaya_gas/services/api_service.dart';

class ManagePelangganController extends GetxController {
  // Dependencies
  final ApiService apiService = Get.find<ApiService>();

  // Observables for state management
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final pelangganList = <Perorangan>[].obs;
  final selectedPelanggan = Rx<Perorangan?>(null);
  final selectedAkun = Rx<Akun?>(null);
  final selectedPerusahaan = Rx<Perusahaan?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchPelangganList();
  }

  // Fetch list of pelanggan
  Future<void> fetchPelangganList() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final pelanggans = await apiService.getAllPelanggan();
      pelangganList.assignAll(pelanggans);
    } catch (e) {
      errorMessage.value = e.toString();
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

  // Fetch detail of a pelanggan
  Future<void> fetchPelangganDetail(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final pelanggan = await apiService.getPelangganById(id);
      if (pelanggan != null) {
        selectedPelanggan.value = pelanggan;

        // Fetch related akun and perusahaan from response
        final response =
            await apiService.getRequest('administrator/pelanggan/$id');
        if (response['status'] && response['data'] != null) {
          final data = response['data'];
          if (data['akun'] != null) {
            selectedAkun.value = Akun.fromJson(data['akun']);
          } else {
            selectedAkun.value = null;
          }
          if (data['perusahaan'] != null) {
            selectedPerusahaan.value = Perusahaan.fromJson(data['perusahaan']);
          } else {
            selectedPerusahaan.value = null;
          }
        }
      } else {
        errorMessage.value = 'Pelanggan tidak ditemukan';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
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

  // Create a new pelanggan
  Future<void> createPelanggan({
    required String namaLengkap,
    required String nik,
    required String noTelepon,
    required String alamat,
    int? idPerusahaan,
    required String email,
    required String password,
    required bool isAuthenticated,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.createPelanggan(
        namaLengkap: namaLengkap,
        nik: nik,
        noTelepon: noTelepon,
        alamat: alamat,
        idPerusahaan: idPerusahaan,
        email: email,
        password: password,
        isAuthenticated: isAuthenticated,
      );

      if (response['status']) {
        Get.snackbar(
          'Sukses',
          response['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchPelangganList(); // Refresh list
      } else {
        errorMessage.value =
            response['message'] ?? 'Gagal menambahkan pelanggan';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
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

  // Update an existing pelanggan
  Future<void> updatePelanggan({
    required int id,
    String? namaLengkap,
    String? nik,
    String? noTelepon,
    String? alamat,
    int? idPerusahaan,
    String? email,
    String? password,
    bool? statusAktif,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.updatePelanggan(
        id: id,
        namaLengkap: namaLengkap,
        nik: nik,
        noTelepon: noTelepon,
        alamat: alamat,
        idPerusahaan: idPerusahaan,
        email: email,
        password: password,
        statusAktif: statusAktif,
      );

      if (response['status']) {
        Get.snackbar(
          'Sukses',
          response['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchPelangganList(); // Refresh list
        await fetchPelangganDetail(id); // Refresh detail
      } else {
        errorMessage.value =
            response['message'] ?? 'Gagal memperbarui pelanggan';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
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

  // Delete a pelanggan
  Future<void> deletePelanggan(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.deletePelanggan(id);

      if (response['status']) {
        Get.snackbar(
          'Sukses',
          response['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        pelangganList.removeWhere((pelanggan) => pelanggan.idPerorangan == id);
        selectedPelanggan.value = null;
        selectedAkun.value = null;
        selectedPerusahaan.value = null;
      } else {
        errorMessage.value = response['message'] ?? 'Gagal menghapus pelanggan';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
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

  // Clear selected pelanggan data
  void clearSelectedPelanggan() {
    selectedPelanggan.value = null;
    selectedAkun.value = null;
    selectedPerusahaan.value = null;
  }
}
