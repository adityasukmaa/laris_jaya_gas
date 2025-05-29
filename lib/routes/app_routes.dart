import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/screens/administrator/detail_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/detail_transaksi_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/edit_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/tambah_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/tambah_transaksi_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/transaksi_screen.dart';
import 'package:laris_jaya_gas/screens/pelanggan/dashboard_pelanggan_screen.dart';
import 'package:laris_jaya_gas/screens/splash_screen/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/administrator/dashboard_administrator_screen.dart';
import '../screens/administrator/stok_tabung_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboardAdministrator = '/administrator/dashboard';
  static const String dashboardPelanggan = '/pelanggan/dashboard';
  static const String ajukanPeminjaman = '/pelanggan/ajukan-peminjaman';

  static const String stokTabung = '/administrator/stok-tabung';
  static const String detailTabung = '/administrator/detail-tabung';
  static const String tambahTabung = '/administrator/tambah-tabung';
  static const String editTabung = '/administrator/edit-tabung';
  static const String transaksiAdministrator = '/administrator/transaksi';
  static const String detailTransaksiAdministrator =
      '/administrator/detail-transaksi';
  static const String tambahTransaksiAdministrator =
      '/administrator/tambah-transaksi';

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
        page: () => StokTabungScreen()), // Pastikan tanpa argumen
    GetPage(
      name: detailTabung,
      page: () => DetailTabungScreen(), // kodeTabung dari Get.arguments
    ),
    GetPage(
      name: editTabung,
      page: () {
        final String? kodeTabung = Get.arguments as String?;
        if (kodeTabung == null) {
          return const Scaffold(
            body: Center(child: Text('Kode Tabung tidak ditemukan')),
          );
        }
        return EditTabungScreen(kodeTabung: kodeTabung);
      },
    ),
    GetPage(name: tambahTabung, page: () => TambahTabungScreen()),
    GetPage(name: transaksiAdministrator, page: () => const TransaksiScreen()),
    GetPage(
      name: detailTransaksiAdministrator,
      page: () {
        final Transaksi? transaction = Get.arguments as Transaksi?;
        if (transaction == null) {
          return const Scaffold(
            body: Center(child: Text('Transaksi tidak ditemukan')),
          );
        }
        return DetailTransaksiScreen(transaction: transaction);
      },
    ),
    GetPage(name: tambahTransaksiAdministrator, page: () => const TambahTransaksiScreen()),

    /** Routing Pelanggan */
    GetPage(
        name: dashboardPelanggan, page: () => const DashboardPelangganScreen()),
    // GetPage(name: ajukanPeminjaman, page: () => const AjukanPeminjamanScreen()),
    GetPage(
      name: unknownRoute,
      page: () => Scaffold(
        body: Center(
          child: Text('Halaman tidak ditemukan: ${Get.currentRoute}'),
        ),
      ),
    ),
  ];
}
