import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/screens/administrator/detail_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/edit_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/tambah_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/pelanggan/dashboard_pelanggan_screen.dart';
import 'package:laris_jaya_gas/screens/splash_screen/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/administrator/dashboard_administrator_screen.dart';
import '../screens/administrator/stok_tabung_screen.dart'; // Tambahkan impor

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboardAdministrator = '/administrator/dashboard';
  static const String dashboardPelanggan = '/pelanggan/dashboard';
  static const String ajukanPeminjaman = '/pelanggan/ajukan-peminjaman';
  static const String stokTabung = '/administrator/stok-tabung';
  static const String detailTabung = '/administrator/detail-tabung';
  static const String editTabung = '/administrator/edit-tabung';
  static const String tambahTabung = '/administrator/tambah-tabung';
  static const String unknownRoute = '/not-found';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),

    /** Routing Administrator */
    GetPage(
        name: dashboardAdministrator,
        page: () => const DashboardAdministratorScreen()),
    GetPage(
        name: stokTabung,
        page: () =>
            StokTabungScreen()), // Tambahkan GetPage untuk StokTabungScreen
    GetPage(name: detailTabung, page: () => DetailTabungScreen()),
    GetPage(
        name: editTabung,
        page: () => EditTabungScreen(
            body: Center(
                child: Text('Edit Tabung: ${Get.arguments}')))), // Placeholder
    GetPage(name: tambahTabung, page: () => TambahTabungScreen()),

    /** Routing Pelanggan */
    GetPage(
        name: dashboardPelanggan, page: () => const DashboardPelangganScreen()),
    // GetPage(name: ajukanPeminjaman, page: () => const AjukanPeminjamanScreen()),
    GetPage(
        name: unknownRoute,
        page: () => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')))),
  ];
}
