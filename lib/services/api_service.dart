import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan URL API Laravel Anda
  static const String _baseUrl = 'http://192.168.96.150:8000/api';

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

  // --- Fungsi CRUD Pelanggan ---

  // Get list pelanggan
  Future<List<Perorangan>> getAllPelanggan() async {
    try {
      final response = await getRequest('administrator/pelanggan');
      if (response['status'] && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Perorangan.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil daftar pelanggan');
    }
  }

  // Get detail pelanggan
  Future<Perorangan?> getPelangganById(int id) async {
    try {
      final response = await getRequest('administrator/pelanggan/$id');
      if (response['status'] && response['data'] != null) {
        return Perorangan.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil detail pelanggan');
    }
  }

  // Create pelanggan
  Future<Map<String, dynamic>> createPelanggan({
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
      final response = await postRequest(
        'administrator/pelanggan',
        data: {
          'nama_lengkap': namaLengkap,
          'nik': nik,
          'no_telepon': noTelepon,
          'alamat': alamat,
          'id_perusahaan': idPerusahaan,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'is_authenticated': isAuthenticated,
        },
      );
      return response;
    } catch (e) {
      throw _handleError(e, 'Gagal menambahkan pelanggan');
    }
  }

  // Update pelanggan
  Future<Map<String, dynamic>> updatePelanggan({
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
      final data = <String, dynamic>{};
      if (namaLengkap != null) data['nama_lengkap'] = namaLengkap;
      if (nik != null) data['nik'] = nik;
      if (noTelepon != null) data['no_telepon'] = noTelepon;
      if (alamat != null) data['alamat'] = alamat;
      if (idPerusahaan != null) data['id_perusahaan'] = idPerusahaan;
      if (email != null) data['email'] = email;
      if (password != null) {
        data['password'] = password;
        data['password_confirmation'] = password;
      }
      if (statusAktif != null) data['status_aktif'] = statusAktif;

      final response = await putRequest(
        'administrator/pelanggan/$id',
        data: data,
      );
      return response;
    } catch (e) {
      throw _handleError(e, 'Gagal memperbarui pelanggan');
    }
  }

  // Delete pelanggan
  Future<Map<String, dynamic>> deletePelanggan(int id) async {
    try {
      final response = await deleteRequest('administrator/pelanggan/$id');
      return response;
    } catch (e) {
      throw _handleError(e, 'Gagal menghapus pelanggan');
    }
  }

  // Get all tabung (Admin)
  Future<List<Tabung>> getAllTabung() async {
    try {
      final response = await getRequest('administrator/tabung');
      if (response['success'] && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Tabung.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil data tabung');
    }
  }

  // Get tabung by ID (Admin)
  Future<Tabung?> getTabungById(int id) async {
    try {
      final response = await getRequest('administrator/tabung/$id');
      if (response['success'] && response['data'] != null) {
        return Tabung.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil detail tabung');
    }
  }

// Get tabung by kode (Admin)
  Future<Tabung?> getTabungByKode(String kodeTabung) async {
    try {
      final response = await getRequest(
        'administrator/tabung/kode?kode_tabung=$kodeTabung',
      );
      if (response['success'] && response['data'] != null) {
        return Tabung.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil tabung berdasarkan kode');
    }
  }

// Create tabung (Admin)
  Future<Map<String, dynamic>> createTabung({
    required String kodeTabung,
    required int idJenisTabung,
    required int idStatusTabung,
  }) async {
    try {
      final response = await postRequest(
        'administrator/tabung',
        data: {
          'kode_tabung': kodeTabung,
          'id_jenis_tabung': idJenisTabung,
          'id_status_tabung': idStatusTabung,
        },
      );
      return response;
    } catch (e) {
      throw _handleError(e, 'Gagal menambahkan tabung');
    }
  }

// Update tabung (Admin)
  Future<Map<String, dynamic>> updateTabung({
    required int id,
    required String kodeTabung,
    required int idJenisTabung,
    required int idStatusTabung,
  }) async {
    try {
      final response = await putRequest(
        'administrator/tabung/$id',
        data: {
          'kode_tabung': kodeTabung,
          'id_jenis_tabung': idJenisTabung,
          'id_status_tabung': idStatusTabung,
        },
      );
      return response;
    } catch (e) {
      throw _handleError(e, 'Gagal memperbarui tabung');
    }
  }

// Delete tabung (Admin)
  Future<Map<String, dynamic>> deleteTabung(int id) async {
    try {
      final response = await deleteRequest('administrator/tabung/$id');
      return response;
    } catch (e) {
      throw _handleError(e, 'Gagal menghapus tabung');
    }
  }

// Get tabung tersedia (Pelanggan)
  Future<List<Map<String, dynamic>>> getTabungTersedia() async {
    try {
      final response = await getRequest('pelanggan/tabung-tersedia');
      if (response['success'] && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil tabung tersedia');
    }
  }

// Get tabung aktif (Pelanggan)
  Future<List<Tabung>> getTabungAktif() async {
    try {
      final response = await getRequest('pelanggan/tabung-aktif');
      if (response['success'] && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Tabung.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil tabung aktif');
    }
  }

  // Fetch tabung data
  Future<Map<String, dynamic>> getTabung() async {
    return await getRequest('administrator/tabung');
  }

  // Fetch tabung aktif untuk pelanggan
  Future<Map<String, dynamic>> getTabungAktifPelanggan() async {
    return await getRequest('pelanggan/tabung-aktif');
  }

  // Fetch profile (untuk admin dan pelanggan)
  Future<Map<String, dynamic>> getAdministratorProfile() async {
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
