import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan URL API Laravel Anda
  static const String _baseUrl = 'http://192.168.50.150:8000/api';

  // SharedPreferences untuk menyimpan token
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Mendapatkan token dari SharedPreferences
  Future<String?> _getToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token');
  }

  // Menyimpan token ke SharedPreferences
  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('auth_token', token);
  }

  // Menyimpan role pengguna ke SharedPreferences
  Future<void> _saveUserRole(String role) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('user_role', role);
  }

  // Menghapus token dan role saat logout
  Future<void> _removeTokenAndRole() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
  }

  // Generic GET request
  Future<Map<String, dynamic>> getRequest(String endpoint,
      {Map<String, String>? headers}) async {
    try {
      final token = await _getToken();
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final finalHeaders =
          headers != null ? {...defaultHeaders, ...headers} : defaultHeaders;

      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: finalHeaders,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'GET request gagal');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> postRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await _getToken();
      }
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final finalHeaders =
          headers != null ? {...defaultHeaders, ...headers} : defaultHeaders;

      print('Mengirim POST ke: $_baseUrl/$endpoint'); // Tambahkan log
      print('Headers: $finalHeaders'); // Tambahkan log
      print('Body: ${jsonEncode(data)}'); // Tambahkan log

      final response = await http
          .post(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: finalHeaders,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      print(
          'Respons: ${response.statusCode} - ${response.body}'); // Tambahkan log

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'POST request gagal');
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> putRequest(String endpoint,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    try {
      final token = await _getToken();
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final finalHeaders =
          headers != null ? {...defaultHeaders, ...headers} : defaultHeaders;

      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: finalHeaders,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'PUT request gagal');
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> deleteRequest(String endpoint,
      {Map<String, String>? headers}) async {
    try {
      final token = await _getToken();
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final finalHeaders =
          headers != null ? {...defaultHeaders, ...headers} : defaultHeaders;

      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: finalHeaders,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e, 'DELETE request gagal');
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw Exception(responseBody['message'] ??
          'Request gagal dengan status: ${response.statusCode}');
    }
  }

  // Handle errors
  String _handleError(dynamic e, String defaultMessage) {
    if (e is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else if (e is TimeoutException) {
      return 'Koneksi timeout. Server tidak merespons.';
    } else if (e is http.ClientException) {
      return 'Error jaringan: ${e.message}';
    } else {
      return '${e.toString()}';
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await postRequest(
        'login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] &&
          response['data'] != null &&
          response['token'] != null) {
        await _saveToken(response['token']);
        await _saveUserRole(response['data']['role']);
      }

      return response;
    } catch (e) {
      throw _handleError(e, 'Gagal masuk');
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await postRequest('register', data: {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      return response;
    } catch (e) {
      throw _handleError(e, 'Pendaftaran gagal');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await postRequest('logout');
      await _removeTokenAndRole();
    } catch (e) {
      throw _handleError(e, 'Gagal keluar');
    }
  }

  // Fetch tabung data
  Future<Map<String, dynamic>> getTabung() async {
    return await getRequest('administrator/tabung');
  }

  // Fetch tabung aktif untuk pelanggan
  Future<Map<String, dynamic>> getTabungAktif() async {
    return await getRequest('pelanggan/tabung-aktif');
  }

  // Fetch profile (untuk admin dan pelanggan)
  Future<Map<String, dynamic>> getProfile() async {
    return await getRequest('administrator/profile');
  }

  // Fetch pelanggan profile
  Future<Map<String, dynamic>> getPelangganProfile() async {
    return await getRequest('pelanggan/profile');
  }

  // Fetch riwayat transaksi pelanggan
  Future<Map<String, dynamic>> getTransaksi() async {
    return await getRequest('transaksi');
  }

  // Fetch admin statistics
  Future<Map<String, dynamic>> getStatistics() async {
    return await getRequest('administrator/statistics');
  }

  // Fetch pending accounts
  Future<Map<String, dynamic>> getPendingAccounts() async {
    return await getRequest('administrator/pending-accounts');
  }

  // Confirm account
  Future<Map<String, dynamic>> confirmAccount(String email) async {
    return await postRequest('administrator/confirm-account',
        data: {'email': email});
  }
}
