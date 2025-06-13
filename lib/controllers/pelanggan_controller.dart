import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/akun_model.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/services/api_service.dart';

class PelangganController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final akun = Rx<Akun?>(null);
  final perorangan = Rx<Perorangan?>(null);
  final perusahaan = Rx<Perusahaan?>(null);
  final activeCylinders = <Tabung>[].obs;
  final transactionHistory = <Transaksi>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchActiveCylinders();
    fetchTransactionHistory();
  }

  // Fetch pelanggan profile
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getPelangganProfile();

      if (response['success']) {
        final data = response['data'];
        akun.value = Akun(
          idAkun: int.tryParse(data['id_akun']?.toString() ?? ''),
          email: data['email'],
          role: data['role'],
          statusAktif: data['status_aktif'] ?? false,
        );
        perorangan.value = Perorangan(
          namaLengkap: data['nama_lengkap'],
          nik: data['nik'],
          noTelepon: data['no_telepon'],
          alamat: data['alamat'],
          idPerusahaan: int.tryParse(data['id_perusahaan']?.toString() ?? ''),
        );
        if (data['nama_perusahaan'] != null) {
          perusahaan.value = Perusahaan(
            idPerusahaan: int.tryParse(data['id_perusahaan']?.toString() ?? ''),
            namaPerusahaan: data['nama_perusahaan'],
            alamatPerusahaan: data['alamat_perusahaan'],
          );
        }
      } else {
        errorMessage.value = response['message'] ?? 'Gagal mengambil profil';
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

  // Fetch active cylinders
  Future<void> fetchActiveCylinders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getTabungAktifPelanggan();

      if (response['success']) {
        activeCylinders.value = (response['data'] as List<dynamic>)
            .map((item) => Tabung.fromJson(item))
            .toList();
      } else {
        errorMessage.value =
            response['message'] ?? 'Gagal mengambil tabung aktif';
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

  // Fetch transaction history
  Future<void> fetchTransactionHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getTransaksi();

      if (response['success']) {
        transactionHistory.value = (response['data'] as List<dynamic>)
            .map((item) => Transaksi.fromJson(item))
            .toList();
      } else {
        errorMessage.value =
            response['message'] ?? 'Gagal mengambil riwayat transaksi';
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

  // View cylinder details
  void viewCylinderDetails(String idTabung) {
    Get.toNamed('/pelanggan/tabung/$idTabung');
  }

  // View transaction details
  void viewTransactionDetails(String idTransaksi) {
    Get.toNamed('/pelanggan/transaksi/$idTransaksi');
  }
}
