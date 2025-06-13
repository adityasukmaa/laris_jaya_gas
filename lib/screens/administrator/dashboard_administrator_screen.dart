import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/administrator_controller.dart';
import 'package:laris_jaya_gas/controllers/auth_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:laris_jaya_gas/widgets/primary_button.dart';

class DashboardAdministratorScreen extends StatelessWidget {
  const DashboardAdministratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final administratorController = Get.find<AdministratorController>();

    // Periksa apakah pengguna sudah login dan memiliki role administrator
    if (!authController.isLoggedIn.value ||
        authController.userRole.value != 'administrator') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/');
      });
      return const Center(child: CircularProgressIndicator());
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryBlue,
      statusBarIconBrightness: Brightness.light,
    ));

    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingTop = screenHeight * 0.05;

    return Obx(() {
      // Tampilkan loading saat data diambil
      if (administratorController.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final profile = administratorController.administratorProfile;
      final statistics = administratorController.statistics;

      // Default values jika data belum dimuat
      final String namaLengkap =
          profile.containsKey('nama_lengkap') && profile['nama_lengkap'] != null
              ? profile['nama_lengkap']
              : 'Administrator';
      final String noTelepon =
          profile.containsKey('no_telepon') && profile['no_telepon'] != null
              ? profile['no_telepon']
              : 'Tidak tersedia';
      final String email =
          profile.containsKey('email') && profile['email'] != null
              ? profile['email']
              : 'admin@example.com';
      final int totalTransaksiBerjalan =
          statistics.containsKey('total_transaksi_berjalan') &&
                  statistics['total_transaksi_berjalan'] != null
              ? statistics['total_transaksi_berjalan']
              : 0;
      final int transactionCount = statistics.containsKey('total_transaksi') &&
              statistics['total_transaksi'] != null
          ? statistics['total_transaksi']
          : 0;
      final int stockCount = statistics.containsKey('stok_tabung') &&
              statistics['stok_tabung'] != null
          ? statistics['stok_tabung']
          : 0;
      final int historyCount = statistics.containsKey('riwayat_transaksi') &&
              statistics['riwayat_transaksi'] != null
          ? statistics['riwayat_transaksi']
          : 0;
      final int customerCount = statistics.containsKey('jumlah_pelanggan') &&
              statistics['jumlah_pelanggan'] != null
          ? statistics['jumlah_pelanggan']
          : 0;

      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ... (kode Container header sama seperti sebelumnya)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16, paddingTop, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, color: Colors.white);
                          },
                        ),
                        PopupMenuButton<String>(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) {
                            if (value == 'logout') {
                              Get.defaultDialog(
                                title: '',
                                titlePadding: EdgeInsets.zero,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                backgroundColor: Colors.white,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Apakah Anda yakin ingin keluar?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => Get.back(),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 38),
                                            side: BorderSide(
                                                color: AppColors.secondary),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                          ),
                                          child: const Text(
                                            'Tidak',
                                            style: TextStyle(
                                                color: AppColors.secondary,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            authController.logout();
                                            Get.back();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 48),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                          ),
                                          child: const Text(
                                            'Ya',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            } else if (value == 'notification') {
                              Get.snackbar(
                                'Notifikasi',
                                'Fitur notifikasi sedang dikembangkan.',
                                backgroundColor: AppColors.whiteSemiTransparent,
                                colorText: Colors.black,
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'notification',
                                child: Row(
                                  children: [
                                    Icon(Icons.notifications,
                                        color: Colors.black54, size: 20),
                                    SizedBox(width: 8),
                                    Text('Notifikasi',
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout,
                                        color: Colors.black54, size: 20),
                                    SizedBox(width: 8),
                                    Text('Logout',
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14)),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          const Text('Halo,',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22)),
                          Text('Administrator - Laris Jaya Gas',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 16),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '$totalTransaksiBerjalan Transaksi Berjalan',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text(namaLengkap,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(noTelepon),
                                        Text(email),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.settings,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildMenuCard('Stok Tabung', Icons.storage,
                                '$stockCount', Colors.white, () {
                              Get.toNamed('/administrator/stok-tabung');
                            }),
                            _buildMenuCard(
                                'Transaksi',
                                Icons.swap_horiz,
                                '$transactionCount',
                                const LinearGradient(colors: [
                                  AppColors.primaryBlue,
                                  Color(0xFF001848)
                                ]), () {
                              Get.toNamed('/administrator/transaksi');
                            }),
                            _buildMenuCard('Riwayat', Icons.history,
                                '$historyCount', Colors.white, () {}),
                            _buildMenuCard('Data Pelanggan', Icons.people,
                                '$customerCount', Colors.white, () {
                              Get.toNamed('/administrator/data-pelanggan');
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Konfirmasi Akun Pelanggan',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Obx(() {
                          // Tampilkan pesan jika tidak ada akun pending
                          if (administratorController.pendingAccounts.isEmpty &&
                              !administratorController.isLoading.value) {
                            return const Center(
                                child: Text('Tidak ada akun pending'));
                          }
                          return Column(
                            children: List.generate(
                              administratorController.pendingAccounts.length,
                              (index) {
                                final account = administratorController
                                    .pendingAccounts[index];
                                return Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.person_outline),
                                    title: Text(
                                        account['email'] ?? 'Tidak tersedia'),
                                    subtitle: const Text(
                                        'Status: Menunggu Konfirmasi'),
                                    trailing: PrimaryButton(
                                      label: 'Konfirmasi',
                                      onPressed: administratorController
                                              .isLoading.value
                                          ? () {}
                                          : () {
                                              administratorController
                                                  .confirmAccount(
                                                      account['email']);
                                            },
                                      isCompact: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Peminjaman'),
            BottomNavigationBarItem(
                icon: Icon(Icons.refresh), label: 'Isi Ulang'),
            BottomNavigationBarItem(
                icon: Icon(Icons.reply), label: 'Pengembalian'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long), label: 'Tagihan'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Get.toNamed('/administrator/dashboard');
                break;
              case 1:
                Get.toNamed('/administrator/peminjaman');
                break;
              case 2:
                break;
              case 3:
                break;
              case 4:
                break;
            }
          },
        ),
      );
    });
  }

  Widget _buildMenuCard(String title, IconData icon, String count,
      dynamic background, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: background is LinearGradient ? background : null,
          color: background is Color ? background : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.1 * 255).toInt()),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: background is LinearGradient
                  ? Colors.white
                  : AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    background is LinearGradient ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              count.isEmpty ? 'Belum ada data' : '$count data',
              style: TextStyle(
                color:
                    background is LinearGradient ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
