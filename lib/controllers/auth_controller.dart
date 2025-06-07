import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final fieldErrors = <String, String>{}.obs;
  final isLoggedIn = false.obs;
  final userRole = ''.obs;
  late SharedPreferences prefs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');
    if (token != null && role != null) {
      isLoggedIn.value = true;
      userRole.value = role;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      fieldErrors.clear();

      print('Mengirim login request: email=$email'); // Tambahkan log
      final response = await apiService.login(email, password);
      print('Respons login: $response'); // Tambahkan log

      if (response['success']) {
        isLoggedIn.value = true;
        userRole.value = response['data']['role'];
        print('Login sukses, role: ${userRole.value}'); // Tambahkan log
        Get.offAllNamed(
          userRole.value == 'administrator'
              ? '/administrator/dashboard'
              : '/pelanggan/dashboard',
        );
      } else {
        errorMessage.value = response['message'] ?? 'Login gagal';
        if (response['errors'] != null) {
          response['errors'].forEach((key, value) {
            fieldErrors[key] = value[0];
          });
        }
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
      print('Login error: ${errorMessage.value}'); // Tambahkan log
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

  Future<void> register(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      fieldErrors.clear();

      final response = await apiService.register(
        email: data['email'],
        password: data['password'],
        passwordConfirmation: data['password_confirmation'],
      );

      if (response['success']) {
        Get.snackbar(
          'Sukses',
          response['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed('/login');
      } else {
        // Ambil hanya message untuk ditampilkan
        errorMessage.value = response['message'] ?? 'Registrasi gagal';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        if (response['errors'] != null) {
          response['errors'].forEach((key, value) {
            fieldErrors[key] = value[0];
          });
        }
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().contains('Validation errors')) {
        final errors =
            (e as dynamic).response['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          errors.forEach((key, value) {
            fieldErrors[key] = (value as List).first;
          });
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await apiService.logout();
      isLoggedIn.value = false;
      userRole.value = '';
      Get.offAllNamed('/');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
