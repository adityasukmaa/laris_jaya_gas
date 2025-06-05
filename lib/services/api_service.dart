import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laris_jaya_gas/models/notifikasi_model.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
import 'package:laris_jaya_gas/models/tagihan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/akun_model.dart';
import '../models/transaksi_model.dart';
import '../models/tabung_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.50.150:8000/api';
  final SharedPreferences prefs;

  ApiService(this.prefs);

  Future<bool> isLoggedIn() async {
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> _getWithToken(String endpoint) async {
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw 'Token tidak ditemukan';
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print(
          'API response [$endpoint]: ${response.statusCode} ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else if (response.statusCode == 401) {
        throw 'Unauthorized: ${data['message'] ?? 'Token tidak valid'}';
      } else if (response.statusCode == 403) {
        throw 'Forbidden: ${data['message'] ?? 'Akses ditolak'}';
      } else if (response.statusCode == 404) {
        throw 'Not Found: ${data['message'] ?? 'Data tidak ditemukan'}';
      } else {
        throw data['message'] ?? 'Gagal mengambil data';
      }
    } on FormatException catch (e) {
      print('API [$endpoint] JSON parse error: $e');
      throw 'Format respons tidak valid: Menerima HTML';
    } catch (e) {
      print('API [$endpoint] error: $e');
      throw 'Gagal mengambil data: $e';
    }
  }

  Future<Map<String, dynamic>> _postWithToken(
      String endpoint, Map<String, dynamic> body) async {
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 30));

      print('API [$endpoint]: ${response.statusCode} ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Gagal memproses permintaan');
      }
    } catch (e) {
      print('API [$endpoint] error: $e');
      throw Exception('Gagal memproses permintaan: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      print('API [login]: ${response.statusCode} ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await prefs.setString('auth_token', data['data']['token'] ?? '');
        await prefs.setString('user_role', data['data']['role'] ?? 'pelanggan');
        await prefs.setString('id_akun', data['data']['id_akun'].toString());
        return data;
      } else {
        throw data['message'] ?? 'Login gagal';
      }
    } on FormatException catch (e) {
      print('API [login] JSON parse error: $e');
      throw 'Format respons tidak valid: Menerima HTML';
    } catch (e) {
      print('API [login] error: $e');
      throw 'Gagal login: $e';
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      print('API [register]: ${response.statusCode} ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        return responseData;
      } else {
        throw responseData['errors'] ??
            {'general': responseData['message'] ?? 'Pendaftaran gagal'};
      }
    } on FormatException catch (e) {
      print('API [register] JSON parse error: $e');
      throw 'Format respons tidak valid: $e';
    } catch (e) {
      print('API [register] error: $e');
      throw 'Gagal mendaftar: $e';
    }
  }

  // Future<Akun?> getAkun(String id) async {
  //   try {
  //     final token = prefs.getString('auth_token') ?? '';
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/akun/$id'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //     ).timeout(const Duration(seconds: 30));

  //     print('API [akun/$id]: ${response.statusCode} ${response.body}');
  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200 && data['success'] == true) {
  //       return Akun.fromJson(data['data']);
  //     }
  //     return null;
  //   } on FormatException catch (e) {
  //     print('API [akun/$id] JSON parse error: $e');
  //     return null;
  //   } catch (e) {
  //     print('API [akun/$id] error: $e');
  //     return null;
  //   }
  // }

  Future<void> logout() async {
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) {
      print('No token found for logout');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Logout response: ${response.statusCode} ${response.body}');
      if (response.statusCode != 200) {
        print('Logout failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error logout: $e');
    } finally {
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('id_akun');
    }
  }

  Future<Map<String, dynamic>> getAdministratorProfile() async {
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      print('No token found in SharedPreferences');
      throw 'Token tidak ditemukan';
    }
    print('Using token for profile request: $token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/administrator/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print(
          'API response [administrator/profile]: ${response.statusCode} ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'];
      } else if (response.statusCode == 401) {
        throw 'Unauthorized: ${data['message'] ?? 'Token tidak valid'}';
      } else if (response.statusCode == 403) {
        throw 'Forbidden: ${data['message'] ?? 'Akses ditolak'}';
      } else if (response.statusCode == 404) {
        throw 'Not Found: ${data['message'] ?? 'Data tidak ditemukan'}';
      } else {
        throw data['message'] ?? 'Gagal mengambil profil';
      }
    } on FormatException catch (e) {
      print('API [administrator/profile] JSON parse error: $e');
      throw 'Format respons tidak valid: Menerima HTML';
    } catch (e) {
      print('API [administrator/profile] error: $e');
      throw 'Gagal mengambil profil: $e';
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    return await _getWithToken('administrator/statistics');
  }

  Future<List<Map<String, dynamic>>> getPendingAccounts() async {
    try {
      final response = await _getWithToken('administrator/pending-accounts');

      if (response['success'] == true) {
        // Pastikan data adalah List
        final data = response['data'];
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Field data bukan list');
        }
      } else {
        throw Exception(
            'Permintaan API gagal: ${response['message'] ?? 'Kesalahan tidak diketahui'}');
      }
    } catch (e) {
      throw Exception('Gagal mengambil akun tertunda: $e');
    }
  }

  Future<void> confirmAccount(String email) async {
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw 'Token tidak ditemukan';
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/administrator/confirm-account'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      print(
          'Confirm account response: ${response.statusCode} ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return;
      } else if (response.statusCode == 400) {
        throw data['message'] ?? 'Akun sudah aktif';
      } else if (response.statusCode == 401) {
        throw 'Unauthorized: ${data['message'] ?? 'Token tidak valid'}';
      } else if (response.statusCode == 404) {
        throw 'Not Found: ${data['message'] ?? 'Akun tidak ditemukan'}';
      } else if (response.statusCode == 422) {
        throw 'Validation Error: ${data['message'] ?? 'Data tidak valid'}';
      } else {
        throw data['message'] ?? 'Gagal mengkonfirmasi akun';
      }
    } on FormatException catch (e) {
      print('API [confirm-account] JSON parse error: $e');
      throw 'Format respons tidak valid: Menerima HTML';
    } catch (e) {
      print('API [confirm-account] error: $e');
      throw 'Gagal mengkonfirmasi akun: $e';
    }
  }

  // Future<Map<String, dynamic>> getTransaksi() async {
  //   final data = await _getWithToken('transaksi');
  //   return data;
  // }

  // Future<List<Transaksi>> getTransaksis(int akunId) async {
  //   try {
  //     final token = prefs.getString('auth_token') ?? '';
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/transaksi/$akunId'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //     ).timeout(const Duration(seconds: 30));

  //     print('Get transaksi response: ${response.statusCode} ${response.body}');
  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200 && data['success'] == true) {
  //       return (data['data'] as List)
  //           .map((json) => Transaksi.fromJson(json))
  //           .toList();
  //     }
  //     return [];
  //   } on FormatException catch (e) {
  //     print('API [transaksi/$akunId] JSON parse error: $e');
  //     return [];
  //   } catch (e) {
  //     print('Error fetching transaksi: $e');
  //     return [];
  //   }
  // }

  // Profil Pelanggan
  Future<Akun> getCustomerProfile() async {
    try {
      final response =
          await _getWithToken('pelanggan/profile'); // Pastikan endpoint benar
      final akunData =
          response; // Langsung ambil response karena data ada di root 'data'
      final akun = Akun(
        idAkun: akunData['id_akun'].toString(),
        email: akunData['email'],
        password: '', // Password tidak dikembalikan oleh API
        role: akunData['role'],
        statusAktif: akunData['status_aktif'] ?? false,
        idPerorangan: akunData['id_perorangan']?.toString(),
        perorangan: akunData['nama_lengkap'] != null
            ? Perorangan(
                idPerorangan: akunData['id_perorangan']?.toString() ?? '',
                namaLengkap: akunData['nama_lengkap'] ?? '',
                nik: akunData['nik'] ?? '',
                noTelepon: akunData['no_telepon'] ?? '',
                alamat: akunData['alamat'] ?? '',
                idPerusahaan: akunData['id_perusahaan']?.toString(),
                perusahaan: akunData['nama_perusahaan'] != null
                    ? Perusahaan(
                        idPerusahaan:
                            akunData['id_perusahaan']?.toString() ?? '',
                        namaPerusahaan: akunData['nama_perusahaan'] ?? '',
                        alamatPerusahaan: akunData['alamat_perusahaan'] ?? '',
                        emailPerusahaan: akunData['email_perusahaan'] ?? '',
                      )
                    : null,
              )
            : null,
      );
      return akun;
    } catch (e) {
      print('Error fetching customer profile: $e');
      throw Exception('Gagal mengambil profil: $e');
    }
  }

  Future<List<Tabung>> getActiveCylinders() async {
    try {
      final response = await _getWithToken('pelanggan/tabung-aktif');
      final data = response as List<dynamic>? ?? []; // Tangani list kosong
      return data
          .map((item) => Tabung.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching active cylinders: $e');
      throw Exception('Gagal mengambil tabung aktif: $e');
    }
  }

  // Riwayat Transaksi
  Future<List<Transaksi>> getTransactionHistory() async {
    try {
      final response = await _getWithToken(
          'pelanggan/riwayat-transaksi'); // Pastikan endpoint benar
      final data = response as List<dynamic>? ?? [];
      return data
          .map((item) => Transaksi.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching transaction history: $e');
      throw Exception('Gagal mengambil riwayat transaksi: $e');
    }
  }

  // Tagihan
  Future<List<Tagihan>> getTagihan() async {
    try {
      final response = await _getWithToken('pelanggan/tagihan');
      final data = response['data'] as List;
      return data.map((item) => Tagihan.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil tagihan: $e');
    }
  }

  Future<Map<String, dynamic>> updatePembayaran(
      Map<String, dynamic> data) async {
    return await _postWithToken('pelanggan/tagihan/update-pembayaran', data);
  }

  // Transaksi
  Future<Map<String, dynamic>> createPeminjaman(
      Map<String, dynamic> data) async {
    return await _postWithToken('pelanggan/transaksi/peminjaman', data);
  }

  Future<Map<String, dynamic>> createIsiUlang(Map<String, dynamic> data) async {
    return await _postWithToken('pelanggan/transaksi/isi-ulang', data);
  }

  Future<Map<String, dynamic>> createGabungan(Map<String, dynamic> data) async {
    return await _postWithToken('pelanggan/transaksi/gabungan', data);
  }

  Future<Transaksi> getTransaksiDetail(String id) async {
    try {
      final response = await _getWithToken('pelanggan/transaksi/$id');
      return Transaksi.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail transaksi: $e');
    }
  }

  // Jenis Tabung
  Future<List<Map<String, dynamic>>> getJenisTabung() async {
    try {
      final response = await _getWithToken('pelanggan/jenis-tabung');
      return (response['data'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Gagal mengambil jenis tabung: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getJenisTabungTersedia() async {
    try {
      final response = await _getWithToken('pelanggan/jenis-tabung-tersedia');
      return (response['data'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Gagal mengambil jenis tabung tersedia: $e');
    }
  }

  // Tabung Tersedia
  Future<List<Tabung>> getTabungTersedia() async {
    try {
      final response = await _getWithToken('pelanggan/tabung-tersedia');
      final data = response['data'] as List;
      return data.map((item) => Tabung.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil tabung tersedia: $e');
    }
  }

  // Tanggal Jatuh Tempo Terdekat
  Future<Map<String, dynamic>> getNearestDueDate() async {
    try {
      final response =
          await _getWithToken('pelanggan/nearest-transaction-due-date');
      return response['data'];
    } catch (e) {
      throw Exception('Gagal mengambil tanggal jatuh-tempo terdekat: $e');
    }
  }

  // Notifikasi
  Future<List<Notifikasi>> getNotifikasi(String akunId) async {
    try {
      final response = await _getWithToken('notifikasis/$akunId');
      return (response['data'] as List)
          .map((e) => Notifikasi.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil notifikasi: $e');
    }
  }

  Future<void> markNotifikasiAsRead(String notifikasiId) async {
    try {
      await _postWithToken('notifikasis/$notifikasiId/read', {});
    } catch (e) {
      throw Exception('Gagal menandai notifikasi sebagai dibaca: $e');
    }
  }

  Future<bool> createTransaksi(Map<String, dynamic> data) async {
    try {
      final token = prefs.getString('auth_token') ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/transaksis'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print(
          'Create transaksi response: ${response.statusCode} ${response.body}'); // Debugging
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating transaksi: $e');
      return false;
    }
  }

  Future<List<Tabung>> getAllTabungs() async {
    try {
      final token = prefs.getString('auth_token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/tabungs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          'Get all tabungs response: ${response.statusCode} ${response.body}'); // Debugging
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Tabung.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching tabungs: $e');
      return [];
    }
  }

  Future<Tabung?> getTabung(String kodeTabung) async {
    try {
      final token = prefs.getString('auth_token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/tabungs/$kodeTabung'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          'Get tabung response: ${response.statusCode} ${response.body}'); // Debugging
      if (response.statusCode == 200) {
        return Tabung.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching tabung: $e');
      return null;
    }
  }
}
