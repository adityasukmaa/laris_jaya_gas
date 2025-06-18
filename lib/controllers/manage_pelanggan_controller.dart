import 'package:get/get.dart';

import '../models/perorangan_model.dart';
import '../services/api_service.dart';

class ManagePelangganController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observables
  final pelangganList = <Perorangan>[].obs;
  final filteredPelangganList = <Perorangan>[].obs;
  final selectedPelanggan = Rx<Perorangan?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedJenisPelanggan = 'Semua'.obs;

  @override
  void onInit() {
    fetchAllPelanggan();
    super.onInit();
  }

  Future<void> fetchAllPelanggan() async {
    try {
      isLoading(true);
      errorMessage('');
      final pelanggans = await _apiService.getAllPelanggan();
      pelangganList.assignAll(pelanggans);
      applyFilter();
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPelangganById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final pelanggan = await _apiService.getPelangganById(id);
      selectedPelanggan(pelanggan);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> createPelanggan({
    required String namaLengkap,
    required String nik,
    required String noTelepon,
    required String alamat,
    String? namaPerusahaan,
    String? alamatPerusahaan,
    String? emailPerusahaan,
    String? email,
    String? password,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'nama_lengkap': namaLengkap,
        'nik': nik,
        'no_telepon': noTelepon,
        'alamat': alamat,
        if (namaPerusahaan != null && namaPerusahaan.isNotEmpty)
          'nama_perusahaan': namaPerusahaan,
        if (alamatPerusahaan != null && alamatPerusahaan.isNotEmpty)
          'alamat_perusahaan': alamatPerusahaan,
        if (emailPerusahaan != null && emailPerusahaan.isNotEmpty)
          'email_perusahaan': emailPerusahaan,
        if (email != null && email.isNotEmpty) 'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
      };
      final pelanggan = await _apiService.createPelanggan(data);
      pelangganList.add(pelanggan);
      applyFilter();
      Get.snackbar('Sukses', 'Pelanggan berhasil ditambahkan');
      Get.toNamed('/administrator/data-pelanggan');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updatePelanggan({
    required int id,
    required String namaLengkap,
    required String nik,
    required String noTelepon,
    required String alamat,
    String? namaPerusahaan,
    String? alamatPerusahaan,
    String? emailPerusahaan,
    String? email,
    String? password,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      final data = {
        'nama_lengkap': namaLengkap,
        'nik': nik,
        'no_telepon': noTelepon,
        'alamat': alamat,
        if (namaPerusahaan != null) 'nama_perusahaan': namaPerusahaan,
        if (alamatPerusahaan != null) 'alamat_perusahaan': alamatPerusahaan,
        if (emailPerusahaan != null) 'email_perusahaan': emailPerusahaan,
        if (email != null) 'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
      };
      final updatedPelanggan = await _apiService.updatePelanggan(id, data);
      final index = pelangganList
          .indexWhere((p) => p.idPerorangan == updatedPelanggan.idPerorangan);
      if (index != -1) {
        pelangganList[index] = updatedPelanggan;
      }
      applyFilter();
      Get.back();
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> deletePelanggan(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _apiService.deletePelanggan(id);
      pelangganList.removeWhere((p) => p.idPerorangan == id);
      applyFilter();
      Get.snackbar('Sukses', 'Pelanggan berhasil dihapus');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void applyFilter() {
    if (selectedJenisPelanggan.value == 'Semua') {
      filteredPelangganList.assignAll(pelangganList);
    } else if (selectedJenisPelanggan.value == 'Perorangan') {
      filteredPelangganList
          .assignAll(pelangganList.where((p) => p.perusahaan == null).toList());
    } else if (selectedJenisPelanggan.value == 'Perusahaan') {
      filteredPelangganList
          .assignAll(pelangganList.where((p) => p.perusahaan != null).toList());
    }
  }

  void clearSelectedPelanggan() {
    selectedPelanggan(null);
  }
}
