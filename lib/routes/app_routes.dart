import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';
import 'package:laris_jaya_gas/screens/administrator/detail_data_pelanggan_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/detail_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/edit_pelanggan_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/edit_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/manage_pelanggan_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/stok_tabung_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/tambah_pelanggan_screen.dart';
import 'package:laris_jaya_gas/screens/administrator/tambah_tabung_screen.dart';
import '../controllers/administrator_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/pelanggan_controller.dart';
import '../controllers/tabung_controller.dart';
import '../screens/pelanggan/dashboard_pelanggan_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/administrator/dashboard_administrator_screen.dart';
import '../screens/splash_screen/splash_screen.dart';

// Define all route names as constants for easy reference and maintenance
class AppRoutes {
  // General Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String unknownRoute = '/not-found';

  // Pelanggan (Customer) Routes
  static const String dashboardPelanggan = '/pelanggan/dashboard';
  static const String ajukanPeminjaman = '/pelanggan/ajukan-peminjaman';
  static const String ajukanIsiUlang = '/pelanggan/ajukan-isi-ulang';
  static const String tagihanPelanggan = '/pelanggan/tagihan';
  static const String profilPelanggan = '/pelanggan/profil';

  // Administrator Routes
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

  // Manage Pelanggan Routes
  static const String dataPelanggan = '/administrator/data-pelanggan';
  static const String tambahPelanggan = '/administrator/tambah-data-pelanggan';
  static const String detailDataPelanggan =
      '/administrator/detail-data-pelanggan';
  static const String editDataPelanggan = '/administrator/edit-data-pelanggan';

  // List of all routes with their respective pages and controller bindings
  static final routes = [
    // General Routes
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        // AuthController is already initialized in main.dart
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: unknownRoute,
      page: () => const Scaffold(
        body: Center(child: Text('Halaman Tidak Ditemukan')),
      ),
      transition: Transition.noTransition,
    ),

    // Pelanggan Routes
    GetPage(
      name: dashboardPelanggan,
      page: () => DashboardPelangganScreen(),
      binding: BindingsBuilder(() {
        Get.put(PelangganController());
      }),
      transition: Transition.fadeIn,
    ),
    // GetPage(
    //   name: ajukanPeminjaman,
    //   page: () => const AjukanPeminjamanScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(TransaksiController());
    //   }),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: ajukanIsiUlang,
    //   page: () => const AjukanIsiUlangScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(TransaksiController());
    //   }),
    //   transition: Transition.rightToLeft,
    // ),
    GetPage(
      name: tagihanPelanggan,
      page: () => const Scaffold(
        body: Center(child: Text('Halaman Tagihan (Belum Diimplementasikan)')),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profilPelanggan,
      page: () => const Scaffold(
        body: Center(
            child: Text('Halaman Profil Pelanggan (Belum Diimplementasikan)')),
      ),
      transition: Transition.rightToLeft,
    ),

    // Administrator Routes
    GetPage(
      name: dashboardAdministrator,
      page: () => const DashboardAdministratorScreen(),
      binding: BindingsBuilder(() {
        Get.put(AdministratorController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: stokTabung,
      page: () => StokTabungScreen(),
      binding: BindingsBuilder(() {
        Get.put(TabungController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.detailTabung,
      page: () {
        final int? idTabung = Get.arguments as int?;
        if (idTabung == null) {
          return const Scaffold(
            body: Center(child: Text('ID Tabung Tidak Ditemukan')),
          );
        }
        return DetailTabungScreen(idTabung: idTabung);
      },
      binding: BindingsBuilder(() {
        Get.put(TabungController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tambahTabung,
      page: () => TambahTabungScreen(),
      binding: BindingsBuilder(() {
        Get.put(TabungController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: editTabung,
      page: () {
        final int? idTabung = Get.arguments as int?;
        if (idTabung == null) {
          return const Scaffold(
            body: Center(child: Text('Kode Tabung Tidak Ditemukan')),
          );
        }
        return EditTabungScreen(idTabung: idTabung);
      },
      binding: BindingsBuilder(() {
        Get.put(TabungController());
      }),
      transition: Transition.rightToLeft,
    ),

    // Manage Pelanggan
    GetPage(
      name: dataPelanggan,
      page: () => ManagePelangganScreen(),
      binding: BindingsBuilder(() {
        Get.put(ManagePelangganController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: tambahPelanggan,
      page: () => TambahPelangganScreen(),
      binding: BindingsBuilder(() {
        Get.put(ManagePelangganController());
      }),
    ),
    GetPage(
      name: detailDataPelanggan,
      page: () {
        final id = Get.arguments as int;
        return DetailDataPelangganScreen(idPelanggan: id);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: editDataPelanggan,
      page: () {
        return EditPelangganScreen();
      },
      transition: Transition.rightToLeft,
    ),
    // GetPage(
    //   name: AppRoutes.qrScan,
    //   page: () {
    //     final Map<String, dynamic>? args =
    //         Get.arguments as Map<String, dynamic>?;
    //     final Function(Map<String, dynamic>)? onTabungSelected =
    //         args?['onTabungSelected'];
    //     final List<Map<String, dynamic>> selectedTabungs =
    //         args?['selectedTabungs'] ?? [];
    //     if (onTabungSelected == null) {
    //       return const Scaffold(
    //         body: Center(
    //             child: Text('Parameter onTabungSelected Tidak Ditemukan')),
    //       );
    //     }
    //     return QRScanScreen(
    //       onTabungSelected: onTabungSelected,
    //       selectedTabungs: selectedTabungs,
    //     );
    //   },
    //   binding: BindingsBuilder(() {
    //     Get.put(TabungController());
    //   }),
    //   transition: Transition.rightToLeft,
    // ),

    // GetPage(
    //   name: transaksiAdministrator,
    //   page: () => const TransaksiScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(TransaksiController());
    //   }),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: detailTransaksiAdministrator,
    //   page: () {
    //     final dynamic transaksi = Get.arguments;
    //     if (transaksi == null) {
    //       return const Scaffold(
    //         body: Center(child: Text('Data Transaksi Tidak Ditemukan')),
    //       );
    //     }
    //     return DetailTransaksiScreen(transaksi: transaksi);
    //   },
    //   binding: BindingsBuilder(() {
    //     Get.put(TransaksiController());
    //   }),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: tambahTransaksiAdministrator,
    //   page: () => const TambahTransaksiScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(TransaksiController());
    //   }),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: qrScan,
    //   page: () {
    //     final Map<String, dynamic>? args =
    //         Get.arguments as Map<String, dynamic>?;
    //     final Function(Map<String, dynamic>)? onTabungSelected =
    //         args?['onTabungSelected'];
    //     final List<Map<String, dynamic>> selectedTabungs =
    //         args?['selectedTabungs'] ?? [];
    //     if (onTabungSelected == null) {
    //       return const Scaffold(
    //         body: Center(
    //             child: Text('Parameter onTabungSelected Tidak Ditemukan')),
    //       );
    //     }
    //     return QRScanScreen(
    //       onTabungSelected: onTabungSelected,
    //       selectedTabungs: selectedTabungs,
    //     );
    //   },
    //   binding: BindingsBuilder(() {
    //     Get.put(TabungController());
    //   }),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: peminjamanAdministrator,
    //   page: () => AdministratorPeminjamanScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(TransaksiController());
    //   }),
    //   transition: Transition.rightToLeft,
    // ),
  ];
}
