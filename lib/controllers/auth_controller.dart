import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var userRole = 'pelanggan'.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var pendingAccounts = <Map<String, dynamic>>[].obs;
  late SharedPreferences prefs;

  @override
  void onInit() async {
    super.onInit();
    // Ubah onInit menjadi async dan gunakan await untuk memastikan prefs diinisialisasi
    await _initPrefs();
    await checkLoginStatus();
    _loadPendingAccounts();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> checkLoginStatus() async {
    try {
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        isLoggedIn.value = true;
        userRole.value = prefs.getString('user_role') ?? 'pelanggan';
      }
    } catch (e) {
      errorMessage.value = 'Gagal memeriksa status login';
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final registeredEmails = prefs.getStringList('registered_emails') ?? [];
      bool accountExists = false;
      bool isActive = false;

      for (var registeredEmail in registeredEmails) {
        if (registeredEmail == email) {
          accountExists = true;
          final storedPassword = prefs.getString('pending_${email}_password');
          isActive = prefs.getBool('pending_${email}_status_aktif') ?? false;

          if (storedPassword == password && isActive) {
            await prefs.setString('auth_token',
                'pelanggan_token_${DateTime.now().millisecondsSinceEpoch}');
            await prefs.setString('user_role', 'pelanggan');
            isLoggedIn.value = true;
            userRole.value = 'pelanggan';
            Get.offAllNamed('/pelanggan/dashboard');
            return;
          } else if (storedPassword == password && !isActive) {
            errorMessage.value =
                'Akun Anda belum dikonfirmasi oleh administrator';
            return;
          } else {
            errorMessage.value = 'Email atau password salah';
            return;
          }
        }
      }

      if (email == 'administrator@larisjayagas.com' &&
          password == 'administrator123') {
        await prefs.setString('auth_token',
            'administrator_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString('user_role', 'administrator');
        isLoggedIn.value = true;
        userRole.value = 'administrator';
        Get.offAllNamed('/administrator/dashboard');
      } else {
        if (!accountExists) {
          errorMessage.value = 'Email atau password salah';
        }
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat login: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      isLoggedIn.value = false;
      userRole.value = 'pelanggan';
      Get.offAllNamed('/');
    } catch (e) {
      errorMessage.value = 'Gagal logout: $e';
    }
  }

  void _loadPendingAccounts() {
    final pendingEmails = prefs.getStringList('registered_emails') ?? [];
    pendingAccounts.clear();
    for (var email in pendingEmails) {
      if (prefs.getBool('pending_${email}_status_aktif') == false) {
        pendingAccounts.add({
          'email': email,
          'password': prefs.getString('pending_${email}_password'),
          'role': prefs.getString('pending_${email}_role'),
        });
      }
    }
  }

  Future<void> confirmAccount(String email) async {
    await prefs.setBool('pending_${email}_status_aktif', true);
    _loadPendingAccounts();
    Get.snackbar('Sukses', 'Akun $email telah dikonfirmasi');
  }
}
