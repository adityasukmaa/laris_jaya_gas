import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/auth_controller.dart';
import 'package:laris_jaya_gas/controllers/pelanggan_controller.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class DashboardPelangganScreen extends StatelessWidget {
  const DashboardPelangganScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final PelangganController controller = Get.find<PelangganController>();

    return FutureBuilder(
      future: authController.checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        print(
            'DashboardPelangganScreen: isLoggedIn=${authController.isLoggedIn.value}, '
            'userRole=${authController.userRole.value}');

        if (!authController.isLoggedIn.value ||
            authController.userRole.value != 'pelanggan') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('Invalid login or role, redirecting to /login');
            Get.offAllNamed(AppRoutes.login);
          });
          return const Scaffold(
            body: Center(child: Text('You are not logged in as a customer')),
          );
        }

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryBlue,
          statusBarIconBrightness: Brightness.light,
        ));

        final double screenHeight = MediaQuery.of(context).size.height;
        final double paddingTop = screenHeight * 0.05;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Obx(() {
            if (controller.isLoading.value || controller.akun.value == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final akun = controller.akun.value!;
            final namaDisplay = akun.perorangan?.namaLengkap ??
                akun.perorangan?.perusahaan?.namaPerusahaan ??
                akun.email;
            return SingleChildScrollView(
              child: Column(
                children: [
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
                                return const Icon(Icons.error,
                                    color: Colors.white);
                              },
                            ),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              onSelected: (value) {
                                if (value == 'logout') {
                                  Get.defaultDialog(
                                    title: '',
                                    titlePadding: EdgeInsets.zero,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 16),
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
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () => Get.back(),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 38),
                                                side: BorderSide(
                                                    color: AppColors.secondary),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                'Tidak',
                                                style: TextStyle(
                                                  color: AppColors.secondary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.find<AuthController>()
                                                    .logout();
                                                Get.back();
                                                Get.offAllNamed('/login');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.secondary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 48),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                'Ya',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (value == 'notification') {
                                  Get.toNamed('/pelanggan/notifikasi');
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem(
                                    value: 'notification',
                                    child: Row(
                                      children: [
                                        Icon(Icons.notifications,
                                            color: Colors.black54, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Notifikasi',
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'logout',
                                    child: Row(
                                      children: [
                                        Icon(Icons.logout,
                                            color: Colors.black54, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Logout',
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14),
                                        ),
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
                              const Text(
                                'Halo,',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 22),
                              ),
                              Text(
                                '$namaDisplay - Laris Jaya Gas',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                              '${controller.activeCylinders.length} Tabung Aktif',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              namaDisplay,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              akun.email,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              'Status: ${akun.statusAktif ? 'Aktif' : 'Non-Aktif'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: akun.statusAktif
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.person,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildMenuCard(
                              'Pinjam Tabung',
                              Icons.add,
                              '',
                              Colors.white,
                              () => Get.toNamed('/pelanggan/ajukan-peminjaman'),
                            ),
                            _buildMenuCard(
                              'Isi Ulang',
                              Icons.refresh,
                              '',
                              const LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  Color(0xFF001848)
                                ],
                              ),
                              () => Get.toNamed('/pelanggan/ajukan-isi-ulang'),
                            ),
                            _buildMenuCard(
                              'Tagihan',
                              Icons.receipt,
                              '',
                              Colors.white,
                              () => Get.toNamed('/pelanggan/tagihan'),
                            ),
                            _buildMenuCard(
                              'Profil',
                              Icons.person,
                              '',
                              Colors.white,
                              () => Get.toNamed('/pelanggan/profil'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tabung Aktif',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildCylinderList(controller),
                        const SizedBox(height: 16),
                        const Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildTransactionHistory(controller),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: Colors.grey,
            currentIndex: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping), label: 'Peminjaman'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.refresh), label: 'Isi Ulang'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt), label: 'Tagihan'),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  Get.toNamed('/pelanggan/ajukan-peminjaman');
                  break;
                case 2:
                  Get.toNamed('/pelanggan/ajukan-isi-ulang');
                  break;
                case 3:
                  Get.toNamed('/pelanggan/tagihan');
                  break;
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    String count,
    dynamic background,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: background is LinearGradient ? background : null,
          color: background is Color ? background : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
              count.isEmpty ? 'Akses Sekarang' : '$count data',
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

  Widget _buildCylinderList(PelangganController controller) {
    return controller.activeCylinders.isEmpty
        ? const Text(
            'Tidak ada tabung aktif.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.activeCylinders.length,
            itemBuilder: (context, index) {
              final Tabung cylinder = controller.activeCylinders[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.propane_tank),
                  title: Text('Tabung: ${cylinder.kodeTabung}'),
                  subtitle: Text(
                      'Jenis: ${cylinder.jenisTabung?.namaJenis ?? 'Unknown'}'),
                  trailing: Text(
                    cylinder.statusTabung?.statusTabung ?? 'Unknown',
                    style: TextStyle(
                      color: cylinder.statusTabung?.statusTabung == 'dipinjam'
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  onTap: () =>
                      controller.viewCylinderDetails(cylinder.idTabung ?? ''),
                ),
              );
            },
          );
  }

  Widget _buildTransactionHistory(PelangganController controller) {
    return controller.transactionHistory.isEmpty
        ? const Text(
            'Tidak ada riwayat transaksi.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.transactionHistory.length,
            itemBuilder: (context, index) {
              final Transaksi transaction =
                  controller.transactionHistory[index];
              final detail = transaction.detailTransaksis?.isNotEmpty == true
                  ? transaction.detailTransaksis![0]
                  : null;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.receipt),
                  title: Text(
                      '${detail?.jenisTransaksi?.namaJenisTransaksi ?? 'Transaksi'} - ${transaction.idTransaksi}'),
                  subtitle: Text('Tanggal: ${transaction.tanggalTransaksi}'),
                  trailing: Text(
                    transaction.statusTransaksi?.status ?? 'Unknown',
                    style: TextStyle(
                      color: transaction.statusTransaksi?.status == 'success'
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  onTap: () => controller
                      .viewTransactionDetails(transaction.idTransaksi),
                ),
              );
            },
          );
  }
}
