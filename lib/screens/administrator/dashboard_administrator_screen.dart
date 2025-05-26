import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/primary_button.dart';

class DashboardAdministratorScreen extends StatelessWidget {
  final Color primaryBlue = const Color(0xFF0172B2);

  const DashboardAdministratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Ambil data dari DummyData
    final administratorData = DummyData.administratorData;
    final String namaPengguna = administratorData['name'] ?? 'Apriliady Rahman';
    final String email = administratorData['email'] ?? 'aprilia@gmail.com';
    final String phone = administratorData['phone'] ?? '081355189363';
    final String role = administratorData['role'] ?? 'Administrator';
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primaryBlue,
      statusBarIconBrightness: Brightness.light,
    ));

    // Hitung transactionCount dari transaksiList
    int transactionCount = DummyData.transaksiList
        .where((transaksi) =>
            transaksi.status == 'pending' || transaksi.status == 'success')
        .length;

    // Hitung stockCount dari tabungList (misalnya, total tabung tersedia)
    int stockCount = DummyData.tabungList
        .where((tabung) => tabung.status == 'Tersedia')
        .length;

    // Hitung historyCount dari riwayatTransaksiList
    int historyCount = DummyData.riwayatTransaksiList.length;

    // Hitung customerCount (sementara dari pelangganData, bisa diperluas)
    int customerCount = 1; // Hanya 1 pelanggan (Budi Santoso) untuk saat ini

    // Dapatkan tinggi layar untuk penyesuaian dinamis
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.40; // 20% dari tinggi layar
    final double paddingTop = screenHeight * 0.05; // 5% dari tinggi layar
    final double paddingBottom = screenHeight * 0.01; // 1% dari tinggi layar

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dipindahkan ke dalam body agar ikut scroll
            Container(
              width: double.infinity,
              height: headerHeight,
              padding: EdgeInsets.fromLTRB(16, paddingTop, 16, paddingBottom),
              decoration: BoxDecoration(
                color: primaryBlue,
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
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onSelected: (value) {
                          if (value == 'logout') {
                            // Tampilkan dialog konfirmasi logout
                            Get.defaultDialog(
                              title: 'Konfirmasi',
                              middleText: 'Apakah Anda yakin ingin keluar?',
                              textConfirm: 'Ya',
                              textCancel: 'Tidak',
                              confirmTextColor: Colors.white,
                              cancelTextColor: Colors.black87,
                              buttonColor: primaryBlue,
                              onConfirm: () {
                                authController.logout();
                                Get.offAllNamed('/login');
                              },
                              onCancel: () {},
                            );
                          } else if (value == 'notification') {
                            // Logika untuk menangani opsi Notifikasi
                            Get.snackbar(
                              'Notifikasi',
                              'Fitur notifikasi sedang dikembangkan atau diarahkan ke halaman notifikasi.',
                              backgroundColor: primaryBlue,
                              colorText: Colors.white,
                            );
                            // Anda bisa menambahkan navigasi ke halaman notifikasi, misalnya:
                            // Get.toNamed('/notification');
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'Notifikasi',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    color: Colors.black54,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Notifikasi',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.black54,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
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
                        Text(
                          'Halo,',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        Text(
                          '$role - Laris Jaya Gas',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
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
                                        '$transactionCount Transaksi Berjalan',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(namaPengguna,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(phone),
                                      Text(email),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.settings, color: Colors.grey),
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
            // Konten lainnya
            Padding(
              padding: const EdgeInsets.all(16),
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
                          _buildMenuCard(
                            'Stok Tabung',
                            Icons.storage,
                            '$stockCount',
                            Colors.white,
                            () {
                              Get.toNamed('/administrator/stok-tabung');
                            },
                          ),
                          _buildMenuCard(
                            'Transaksi',
                            Icons.swap_horiz,
                            '$transactionCount',
                            const LinearGradient(
                              colors: [Color(0xFF0172B2), Color(0xFF001848)],
                            ),
                            () {},
                          ),
                          _buildMenuCard(
                            'Riwayat',
                            Icons.history,
                            '$historyCount',
                            Colors.white,
                            () {},
                          ),
                          _buildMenuCard(
                            'Data Pelanggan',
                            Icons.people,
                            '$customerCount',
                            Colors.white,
                            () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Konfirmasi Akun Pelanggan',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        return Column(
                          children: List.generate(
                            authController.pendingAccounts.length,
                            (index) {
                              final account =
                                  authController.pendingAccounts[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.person_outline),
                                  title: Text(account['email']),
                                  subtitle:
                                      const Text('Status: Menunggu Konfirmasi'),
                                  trailing: PrimaryButton(
                                    label: 'Konfirmasi',
                                    onPressed: () {
                                      authController
                                          .confirmAccount(account['email']);
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
        selectedItemColor: primaryBlue,
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
              color: background is LinearGradient ? Colors.white : Colors.blue,
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
              '$count data',
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
