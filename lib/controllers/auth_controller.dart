import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/akun_model.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var akunId = ''.obs;
  var userRole = 'pelanggan'.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var pendingAccounts = <Map<String, dynamic>>[].obs;
  var fieldErrors = <String, String>{}.obs;
  var akun = Rxn<Akun>();
  late SharedPreferences prefs;
  late ApiService apiService;

  @override
  void onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
    apiService = ApiService(prefs);
    await checkLoginStatus();
    _loadPendingAccounts();
  }

  Future<void> checkLoginStatus() async {
    try {
      final token = prefs.getString('auth_token');
      final role = prefs.getString('user_role') ?? 'pelanggan';
      final storedAkunId = prefs.getString('akun_id') ?? '';
      print('Stored akun_id: $storedAkunId'); // Debugging
      if (token != null && token.isNotEmpty && storedAkunId.isNotEmpty) {
        isLoggedIn.value = true;
        userRole.value = role;
        akunId.value = storedAkunId;
        // Hanya panggil getAkun jika akun_id adalah numerik
        if (RegExp(r'^\d+$').hasMatch(storedAkunId)) {
          akun.value = await apiService.getAkun(int.parse(storedAkunId));
        }
      } else {
        isLoggedIn.value = false;
        userRole.value = 'pelanggan';
        akunId.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Gagal memeriksa status login: $e';
      print('Check login error: $e'); // Debugging
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await apiService.login(email, password);
      if (data != null && data['success'] == true) {
        isLoggedIn.value = true;
        userRole.value = data['data']['role'];
        final akunIdValue = data['data']['akun_id'].toString();
        akunId.value = akunIdValue;
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['data']['role']);
        await prefs.setString('akun_id', akunIdValue);
        akun.value = Akun(
          idAkun: akunIdValue,
          idPerorangan: null,
          email: data['data']['email'],
          password: '',
          role: data['data']['role'],
          statusAktif: true,
          perorangan: null,
        );
        Get.offAllNamed(userRole.value == 'administrator'
            ? '/administrator/dashboard'
            : '/pelanggan/dashboard');
      } else {
        errorMessage.value = data?['message'] ?? 'Login gagal';
      }
    } catch (e) {
      errorMessage.value = '$e';
      print('Login error: $e'); // Debugging
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    isLoading.value = true;
    fieldErrors.clear();
    try {
      final response = await apiService.register(data);
      Get.snackbar(
        'Sukses',
        response?['message'] ??
            'Pendaftaran berhasil, menunggu konfirmasi admin',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.toNamed('/login');
    } catch (e) {
      if (e is Map<String, dynamic>) {
        // Map error dari API
        e.forEach((key, value) {
          fieldErrors[key] = value is List ? value.first : value.toString();
        });
      } else {
        fieldErrors['general'] = e.toString();
      }
      Get.snackbar(
        'Error',
        fieldErrors['general'] ?? 'Pendaftaran gagal',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Register error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await apiService.logout();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('akun_id');
      isLoggedIn.value = false;
      userRole.value = 'pelanggan';
      akunId.value = '';
      akun.value = null;
      Get.offAllNamed('/');
    } catch (e) {
      errorMessage.value = 'Gagal logout: $e';
      print('Logout error: $e'); // Debugging
    }
  }

  void _loadPendingAccounts() {
    pendingAccounts.clear();
  }

  Future<void> confirmAccount(String email) async {
    Get.snackbar('Sukses', 'Akun $email telah dikonfirmasi');
  }
}
