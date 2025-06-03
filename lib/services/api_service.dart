import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/akun_model.dart';
import '../models/transaksi_model.dart';
import '../models/tabung_model.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.50.150:8000/api'; // Sesuaikan URL
  final SharedPreferences prefs;

  ApiService(this.prefs);

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print(
          'Login response: ${response.statusCode} ${response.body}'); // Debugging
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['data']['role']);
        await prefs.setString('akun_id', data['data']['akun_id'].toString());
        return data;
      } else {
        throw data['message'] ?? 'Login gagal';
      }
    } catch (e) {
      print('Login error: $e'); // Debugging
      throw 'Error login: $e';
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print(
          'Register response: ${response.statusCode} ${response.body}'); // Debugging
      final responseData = jsonDecode(response.body);
      if (response.statusCode != 201 || responseData['success'] != true) {
        throw responseData['message'] ?? 'Pendaftaran gagal';
      }
    } catch (e) {
      print('Register error: $e'); // Debugging
      throw 'Error register: $e';
    }
  }

  Future<Akun?> getAkun(int id) async {
    try {
      final token = prefs.getString('auth_token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/akun/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          'Get akun response: ${response.statusCode} ${response.body}'); // Debugging
      if (response.statusCode == 200) {
        return Akun.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching akun: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final token = prefs.getString('auth_token') ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          'Logout response: ${response.statusCode} ${response.body}'); // Debugging
    } catch (e) {
      print('Error logout: $e');
    }
  }

  Future<List<Transaksi>> getTransaksis(int akunId) async {
    try {
      final token = prefs.getString('auth_token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/transaksis/$akunId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          'Get transaksis response: ${response.statusCode} ${response.body}'); // Debugging
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Transaksi.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transaksis: $e');
      return [];
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
}
