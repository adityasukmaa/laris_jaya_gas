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
  final filteredPelangganList = <Perorangan>[].obs;
  final selectedPelanggan = Rx<Perorangan?>(null);
  final selectedAkun = Rx<Akun?>(null);
  final selectedPerusahaan = Rx<Perusahaan?>(null);
  final selectedJenisPelanggan = 'Semua'.obs;

  // Form controllers for TambahEditPelangganScreen
  final namaLengkapController = TextEditingController();
  final nikController = TextEditingController();
  final noTeleponController = TextEditingController();
  final alamatController = TextEditingController();
  final namaPerusahaanController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPelangganList();
    ever(
        pelangganList, (_) => applyFilter()); // Update filter saat list berubah
  }

  // Fetch list of pelanggan
  Future<void> fetchPelangganList() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final pelanggans = await apiService.getAllPelanggan();
      pelangganList.assignAll(pelanggans);
      applyFilter(); // Terapkan filter setelah fetch
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
  Future<bool> createPelanggan({
    String? namaLengkap,
    String? nik,
    String? noTelepon,
    String? alamat,
    int? idPerusahaan,
    String? email,
    String? password,
    bool? isAuthenticated,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.createPelanggan(
        namaLengkap: namaLengkap ?? namaLengkapController.text,
        nik: nik ?? nikController.text,
        noTelepon: noTelepon ?? noTeleponController.text,
        alamat: alamat ?? alamatController.text,
        idPerusahaan: idPerusahaan ?? selectedPerusahaan.value?.idPerusahaan,
        email:
            email ?? (emailController.text.isEmpty ? '' : emailController.text),
        password: password ??
            (passwordController.text.isEmpty ? '' : passwordController.text),
        isAuthenticated: isAuthenticated ?? emailController.text.isNotEmpty,
      );

      if (response['status']) {
        Get.snackbar(
          'Sukses',
          response['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchPelangganList();
        return true;
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
        return false;
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
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing pelanggan
  Future<bool> updatePelanggan({
    required String id,
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
        id: int.parse(id),
        namaLengkap: namaLengkap ?? namaLengkapController.text,
        nik: nik ?? nikController.text,
        noTelepon: noTelepon ?? noTeleponController.text,
        alamat: alamat ?? alamatController.text,
        idPerusahaan: idPerusahaan ?? selectedPerusahaan.value?.idPerusahaan,
        email: email ??
            (emailController.text.isEmpty ? null : emailController.text),
        password: password ??
            (passwordController.text.isEmpty ? null : passwordController.text),
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
        await fetchPelangganList();
        await fetchPelangganDetail(int.parse(id));
        return true;
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
        return false;
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
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing pelanggan with int id (for compatibility with other screens)
  Future<bool> updatePelangganWithIntId({
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
    return updatePelanggan(
      id: id.toString(),
      namaLengkap: namaLengkap,
      nik: nik,
      noTelepon: noTelepon,
      alamat: alamat,
      idPerusahaan: idPerusahaan,
      email: email,
      password: password,
      statusAktif: statusAktif,
    );
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
        applyFilter();
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

  // Apply filter based on selected jenis pelanggan
  void applyFilter() {
    if (selectedJenisPelanggan.value == 'Semua') {
      filteredPelangganList.assignAll(pelangganList);
    } else if (selectedJenisPelanggan.value == 'Perorangan') {
      filteredPelangganList.assignAll(
        pelangganList.where((p) => p.idPerusahaan == null).toList(),
      );
    } else if (selectedJenisPelanggan.value == 'Perusahaan') {
      filteredPelangganList.assignAll(
        pelangganList.where((p) => p.idPerusahaan != null).toList(),
      );
    }
  }

  // Load pelanggan data into form
  void loadPelangganData(String id) {
    final pelanggan = pelangganList.firstWhereOrNull(
      (p) => p.idPerorangan.toString() == id,
    );
    if (pelanggan != null) {
      selectedPelanggan.value = pelanggan;
      namaLengkapController.text = pelanggan.namaLengkap ?? '';
      nikController.text = pelanggan.nik ?? '';
      noTeleponController.text = pelanggan.noTelepon ?? '';
      alamatController.text = pelanggan.alamat ?? '';
      namaPerusahaanController.text =
          selectedPerusahaan.value?.namaPerusahaan ?? '';
      emailController.text = selectedAkun.value?.email ?? '';
      passwordController.text = '';
      fetchPelangganDetail(int.parse(id)); // Ensure latest data
    }
  }

  // Clear form data
  void clearForm() {
    namaLengkapController.clear();
    nikController.clear();
    noTeleponController.clear();
    alamatController.clear();
    namaPerusahaanController.clear();
    emailController.clear();
    passwordController.clear();
    selectedPelanggan.value = null;
    selectedAkun.value = null;
    selectedPerusahaan.value = null;
  }

  // Clear selected pelanggan data
  void clearSelectedPelanggan() {
    selectedPelanggan.value = null;
    selectedAkun.value = null;
    selectedPerusahaan.value = null;
  }

  @override
  void onClose() {
    namaLengkapController.dispose();
    nikController.dispose();
    noTeleponController.dispose();
    alamatController.dispose();
    namaPerusahaanController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
