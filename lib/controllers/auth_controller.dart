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
  var fieldErrors = <String, String>{}.obs;
  var akun = Rxn<Akun>();
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
    await checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      final token = prefs.getString('auth_token');
      final role = prefs.getString('user_role') ?? 'pelanggan';
      final storedAkunId = prefs.getString('id_akun') ?? '';
      if (token != null && token.isNotEmpty && storedAkunId.isNotEmpty) {
        // akun.value = await apiService.getAkun(storedAkunId);
        if (akun.value != null) {
          isLoggedIn.value = true;
          userRole.value = role;
          akunId.value = storedAkunId;
        } else {
          await logout();
        }
      }
    } catch (e) {
      print('Check login error: $e');
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    fieldErrors.clear();

    try {
      final response = await apiService.login(email, password);
      print('Login response: $response');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final akunIdValue = data['id_akun']?.toString();
        if (akunIdValue == null || akunIdValue.isEmpty) {
          throw 'ID akun tidak ditemukan dalam respons login';
        }
        final token = response['token'] ?? '';
        if (token.isEmpty) {
          throw 'Token tidak ditemukan dalam respons login';
        }
        isLoggedIn.value = true;
        userRole.value = data['role'] ?? 'pelanggan';
        akunId.value = akunIdValue;
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', userRole.value);
        await prefs.setString('id_akun', akunIdValue);
        print('Token after login: $token');
        akun.value = Akun(
          idAkun: akunIdValue,
          idPerorangan: null,
          email: data['email'] ?? email,
          password: '',
          role: userRole.value,
          statusAktif: true,
          perorangan: null,
        );
        print('Login successful: id_akun=$akunIdValue, role=${userRole.value}');
        Get.offAllNamed(userRole.value == 'administrator'
            ? '/administrator/dashboard'
            : '/pelanggan/dashboard');
      } else {
        errorMessage.value = response['message'] ?? 'Login gagal';
        Get.snackbar('Error', errorMessage.value,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Login error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = '';
    fieldErrors.clear();

    try {
      final response = await apiService.register(data);
      if (response['success'] == true) {
        Get.snackbar('Sukses', response['message'] ?? 'Pendaftaran berhasil',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.toNamed('/login');
      } else {
        throw response['message'] ?? 'Pendaftaran gagal';
      }
    } catch (e) {
      print('Register error: $e');
      if (e is Map<String, dynamic>) {
        e.forEach((key, value) {
          fieldErrors[key] = value is List ? value.first : value.toString();
        });
      } else {
        errorMessage.value = e.toString();
      }
      Get.snackbar('Error', fieldErrors['general'] ?? errorMessage.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await apiService.logout();
      isLoggedIn.value = false;
      userRole.value = '';
      akunId.value = '';
      Get.offAllNamed('/');
      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      errorMessage.value = 'Gagal logout: $e';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
