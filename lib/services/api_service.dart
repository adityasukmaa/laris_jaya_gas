import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan URL API Laravel Anda
  static String _baseUrl = 'http://192.168.76.150:8000/api';

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

      print('Request URL: $_baseUrl/$endpoint');
      print('Request Headers: $finalHeaders');

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

  Map<String, dynamic> _parseJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw Exception('Response is not a valid JSON object: $body');
      }
    } catch (e) {
      throw Exception('Failed to parse JSON: $body');
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return _parseJson(response.body);
      } catch (e) {
        throw Exception('Failed to parse response as JSON: ${response.body}');
      }
    } else {
      String errorMessage = response.body.isNotEmpty
          ? response.body
          : 'No error message provided';
      if (response.statusCode == 401) {
        throw Exception(
            'Unauthorized: Invalid or missing token - $errorMessage');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: Access denied - $errorMessage');
      } else if (response.statusCode == 404) {
        throw Exception('Not Found: Endpoint does not exist - $errorMessage');
      } else if (response.statusCode == 500) {
        throw Exception('Internal Server Error: $errorMessage');
      } else {
        throw Exception(
            'Request failed with status: ${response.statusCode} - $errorMessage');
      }
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

  // --- Fungsi Transaksi ---

  Future<List<Transaksi>> getAllTransaksi() async {
    try {
      final response = await getRequest('administrator/transaksi');
      print('getAllTransaksi Response: ${jsonEncode(response)}');
      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        print('Parsing ${dataList.length} transaksi');
        return dataList.asMap().entries.map((entry) {
          try {
            final json = entry.value as Map<String, dynamic>;
            print(
                'Parsing transaksi[${entry.key}]: id_transaksi=${json['id_transaksi']} (${json['id_transaksi'].runtimeType}), total_transaksi=${json['total_transaksi']} (${json['total_transaksi'].runtimeType})');
            return Transaksi.fromJson(json);
          } catch (e) {
            print('Error parsing transaksi at index ${entry.key}: $e');
            throw e;
          }
        }).toList();
      } else {
        throw Exception(
            'No transactions found: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }

  Future<Transaksi> getTransaksiById(String id) async {
    try {
      final response = await getRequest('administrator/transaksi/$id');
      if (response['success'] == true && response['data'] != null) {
        return Transaksi.fromJson(response['data']);
      }
      throw Exception('Transaksi tidak ditemukan');
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil detail transaksi');
    }
  }

  Future<Transaksi> createTransaksi(Map<String, dynamic> data) async {
    try {
      final response = await postRequest('administrator/transaksi', data: data);
      if (response['status'] == 'sukses' && response['data'] != null) {
        return Transaksi.fromJson(response['data']);
      }
      throw Exception(response['pesan'] ?? 'Gagal membuat transaksi');
    } catch (e) {
      throw _handleError(e, 'Gagal membuat transaksi');
    }
  }

  Future<Transaksi> updateTransaksi(
      String id, Map<String, dynamic> data) async {
    try {
      final response =
          await putRequest('administrator/transaksi/$id', data: data);
      if (response['success'] == true && response['data'] != null) {
        return Transaksi.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Gagal memperbarui transaksi');
    } catch (e) {
      throw _handleError(e, 'Gagal memperbarui transaksi');
    }
  }

  Future<List<Transaksi>> getRiwayatTransaksi() async {
    try {
      final response = await getRequest('administrator/transaksi/riwayat');
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((json) => Transaksi.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil riwayat transaksi');
    }
  }

  // --- Fungsi CRUD Pelanggan ---

  Future<List<Perorangan>> getAllPelanggan() async {
    try {
      final response = await getRequest('administrator/pelanggan');
      // Penyesuaian dengan response API Laravel: gunakan 'status' dan 'data->data'
      if (response['status'] == true &&
          response['data'] != null &&
          response['data']['data'] != null) {
        final data = response['data']['data'] as List;
        return data.map((json) => Perorangan.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil daftar pelanggan');
    }
  }

  Future<Perorangan> getPelangganById(int id) async {
    try {
      final response = await getRequest('administrator/pelanggan/$id');
      return Perorangan.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e, 'Gagal mengambil pelanggan');
    }
  }

  Future<Perorangan> createPelanggan(Map<String, dynamic> data) async {
    try {
      final response = await postRequest('administrator/pelanggan', data: data);
      return Perorangan.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e, 'Gagal membuat pelanggan');
    }
  }

  Future<Perorangan> updatePelanggan(int id, Map<String, dynamic> data) async {
    try {
      final response =
          await putRequest('administrator/pelanggan/$id', data: data);
      return Perorangan.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e, 'Gagal memperbarui pelanggan');
    }
  }

  Future<void> deletePelanggan(int id) async {
    try {
      await deleteRequest('administrator/pelanggan/$id');
    } catch (e) {
      throw _handleError(e, 'Gagal menghapus pelanggan');
    }
  }

  // Get all tabung (Admin)
  Future<List<Tabung>> getAllTabung({String? status}) async {
    try {
      String endpoint = 'administrator/tabung';
      if (status != null) {
        endpoint += '?status=$status';
      }

      final response = await getRequest(endpoint);
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
        'administrator/tabung-kode?kode_tabung=$kodeTabung',
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
      throw _handleError(e, '');
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

  /// Mengambil daftar tabung yang statusnya "tersedia".
  /// Disederhanakan untuk fitur pemilihan oleh pelanggan.
  Future<List<Tabung>> getTabungTersedia() async {
    try {
      // Pastikan endpoint ini sesuai dengan yang Anda daftarkan di routes/api.php
      // Contoh: Route::get('/pelanggan/tabung-tersedia', [ApiTabungController::class, 'getTabungsTersedia']);
      final response = await getRequest('administrator/tabung-tersedia');

      if (response['success'] == true && response['data'] != null) {
        // Casting data sebagai List<dynamic>
        final dataList = response['data'] as List<dynamic>;

        // Mapping setiap item JSON ke objek TabungTersedia
        return dataList.map((json) => Tabung.fromJson(json)).toList();
      } else {
        // Jika API mengembalikan success: false atau data null
        throw Exception('Gagal memuat data tabung tersedia.');
      }
    } catch (e) {
      // Melemparkan kembali error yang sudah ditangani oleh _handleError
      // atau error parsing JSON.
      throw _handleError(e, 'Gagal mengambil data tabung tersedia');
    }
  }

// Get tabung tersedia (Pelanggan)
  // Future<List<Map<String, dynamic>>> getTabungTersedia() async {
  //   try {
  //     final response = await getRequest('pelanggan/tabung-tersedia');
  //     if (response['success'] && response['data'] != null) {
  //       return List<Map<String, dynamic>>.from(response['data']);
  //     }
  //     return [];
  //   } catch (e) {
  //     throw _handleError(e, 'Gagal mengambil tabung tersedia');
  //   }
  // }

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
