import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var userId = ''.obs; // Tambahkan userId sebagai observable
  var userRole = 'pelanggan'.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var pendingAccounts = <Map<String, dynamic>>[].obs;
  late SharedPreferences prefs;

  @override
  void onInit() async {
    super.onInit();
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
      final role = prefs.getString('user_role') ?? 'pelanggan';
      final storedUserId = prefs.getString('user_id') ??
          ''; // Muat userId dari SharedPreferences
      print(
          'Check Login Status: token=$token, role=$role, userId=$storedUserId'); // Debugging
      if (token != null && token.isNotEmpty) {
        isLoggedIn.value = true;
        userRole.value = role;
        userId.value = storedUserId; // Set userId dari penyimpanan
      } else {
        isLoggedIn.value = false;
        userRole.value = 'pelanggan';
        userId.value = ''; // Reset userId jika tidak login
      }
    } catch (e) {
      errorMessage.value = 'Gagal memeriksa status login: $e';
      print('Error checking login status: $e'); // Debugging
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      print('Login attempt: email=$email, password=$password'); // Debugging

      // Pengecekan kredensial statis untuk administrator
      if (email == 'administrator@larisjayagas.com' &&
          password == 'administrator123') {
        await prefs.setString('auth_token',
            'administrator_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString('user_role', 'administrator');
        await prefs.setString(
            'user_id', 'AKN001'); // Set userId untuk administrator
        isLoggedIn.value = true;
        userRole.value = 'administrator';
        userId.value = 'AKN001'; // Set userId
        print(
            'Admin login successful, navigating to /administrator/dashboard'); // Debugging
        await Future.delayed(Duration.zero); // Pastikan status diperbarui
        Get.offAllNamed('/administrator/dashboard');
        return;
      }
      // Pengecekan kredensial statis untuk pelanggan
      else if (email == 'pelanggan@larisjayagas.com' &&
          password == 'pelanggan123') {
        await prefs.setString('auth_token',
            'pelanggan_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString('user_role', 'pelanggan');
        await prefs.setString(
            'user_id', 'AKN002'); // Set userId untuk pelanggan
        isLoggedIn.value = true;
        userRole.value = 'pelanggan';
        userId.value = 'AKN002'; // Set userId
        print(
            'Pelanggan login successful, navigating to /pelanggan/dashboard'); // Debugging
        await Future.delayed(Duration.zero); // Pastikan status diperbarui
        Get.offAllNamed('/pelanggan/dashboard');
        return;
      }

      // Pengecekan akun tertunda di SharedPreferences
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
            await prefs.setString(
                'user_id', 'AKN003'); // Set userId untuk akun tertunda
            isLoggedIn.value = true;
            userRole.value = 'pelanggan';
            userId.value = 'AKN003'; // Set userId
            print(
                'Registered account login successful, navigating to /pelanggan/dashboard'); // Debugging
            await Future.delayed(Duration.zero); // Pastikan status diperbarui
            Get.offAllNamed('/pelanggan/dashboard');
            return;
          } else if (storedPassword == password && !isActive) {
            errorMessage.value =
                'Akun Anda belum dikonfirmasi oleh administrator';
            print('Account not confirmed: $email'); // Debugging
            return;
          } else {
            errorMessage.value = 'Email atau password salah';
            print(
                'Invalid email or password for registered account: $email'); // Debugging
            return;
          }
        }
      }

      // Jika email tidak ditemukan
      if (!accountExists) {
        errorMessage.value = 'Email atau password salah';
        print('Account not found: $email'); // Debugging
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat login: $e';
      print('Login error: $e'); // Debugging
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('user_id'); // Hapus userId saat logout
      isLoggedIn.value = false;
      userRole.value = 'pelanggan';
      userId.value = ''; // Reset userId
      print('Logout successful, navigating to /'); // Debugging
      Get.offAllNamed('/');
    } catch (e) {
      errorMessage.value = 'Gagal logout: $e';
      print('Logout error: $e'); // Debugging
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
    print('Pending accounts loaded: ${pendingAccounts.length}'); // Debugging
  }

  Future<void> confirmAccount(String email) async {
    await prefs.setBool('pending_${email}_status_aktif', true);
    _loadPendingAccounts();
    Get.snackbar('Sukses', 'Akun $email telah dikonfirmasi');
    print('Account confirmed: $email'); // Debugging
  }
}
