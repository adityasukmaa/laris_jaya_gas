import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/screens/administrator/detail_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/detail_transaksi_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/edit_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/peminjaman_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/qr_scan_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/tambah_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/tambah_transaksi_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/transaksi_screen.dart';
import 'package:laris_jaya_gas/screens/pelanggan/ajukan_isi_ulang_screen.dart';
import 'package:laris_jaya_gas/screens/pelanggan/ajukan_peminjaman_screen.dart';
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

  /** Routing Administrator */
  static const String dashboardAdministrator = '/administrator/dashboard';
  static const String stokTabung = '/administrator/stok-tabung';
  static const String detailTabung = '/administrator/detail-tabung';
  static const String tambahTabung = '/administrator/tambah-tabung';
  static const String editTabung = '/administrator/edit-tabung';
  static const String transaksiAdministrator = '/administrator/transaksi';
  static const String detailTransaksiAdministrator =
      '/administrator/detail-transaksi';
  static const String tambahTransaksiAdministrator =
      '/administrator/tambah-transaksi';
  static const String qrScan = '/administrator/qr-scan';
  static const String peminjamanAdministrator = '/administrator/peminjaman';

  /** Routing Pelanggan */
  static const String dashboardPelanggan = '/pelanggan/dashboard';
  static const String ajukanPeminjaman = '/pelanggan/ajukan-peminjaman';
  static const String ajukanIsiUlang = '/pelanggan/ajukan-isi-ulang';
  static const String tagihanPelanggan = '/pelanggan/tagihan';
  static const String profilPelanggan = '/pelanggan/profil';

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
    GetPage(name: transaksiAdministrator, page: () => const TransaksiScreen()),
    GetPage(name: tambahTabung, page: () => TambahTabungScreen()),
    GetPage(
        name: tambahTransaksiAdministrator,
        page: () => const TambahTransaksiScreen()),
    GetPage(
        name: detailTransaksiAdministrator,
        page: () => DetailTransaksiScreen(transaksi: Get.arguments)),
    GetPage(
      name: qrScan,
      page: () {
        final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
        final Function(Map<String, dynamic>) onTabungSelected =
            args['onTabungSelected'];
        final List<Map<String, dynamic>> selectedTabungs =
            (args['selectedTabungs'] as List<Map<String, dynamic>>?) ?? [];
        return QRScanScreen(
          onTabungSelected: onTabungSelected,
          selectedTabungs: selectedTabungs,
        );
      },
    ),
    GetPage(
      name: peminjamanAdministrator,
      page: () => AdministratorPeminjamanScreen(),
    ),

    /** Routing Pelanggan */
    GetPage(name: dashboardPelanggan, page: () => DashboardPelangganScreen()),
    GetPage(name: ajukanPeminjaman, page: () => const AjukanPeminjamanScreen()),
    GetPage(
      name: tagihanPelanggan,
      page: () => const Scaffold(
        body: Center(child: Text('Halaman Tagihan (Belum Diimplementasikan)')),
      ),
    ),
    GetPage(
      name: unknownRoute,
      page: () => Scaffold(
        body: Center(
          child: Text('Halaman tidak ditemukan: ${Get.currentRoute}'),
        ),
      ),
    ),
    GetPage(
      name: '/pelanggan/profil',
      page: () => const Scaffold(
        body: Center(
            child: Text('Halaman Profil Pelanggan (Belum Diimplementasikan)')),
      ),
    ),
    GetPage(
      name: ajukanPeminjaman,
      page: () => const AjukanPeminjamanScreen(),
    ),
    GetPage(name: ajukanIsiUlang, page: () => const AjukanIsiUlangScreen()),
  ];
}
