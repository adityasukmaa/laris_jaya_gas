import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/pelanggan_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class ProfilPelangganScreen extends StatelessWidget {
  const ProfilPelangganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PelangganController controller = Get.find<PelangganController>();

    return Obx(() {
      if (controller.isLoading.value || controller.akun.value == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final akun = controller.akun.value!;
      final perorangan = akun.perorangan;
      final perusahaan = perorangan?.perusahaan;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil Pelanggan'),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Pribadi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Nama'),
                subtitle: Text(perorangan?.namaLengkap ?? akun.email),
              ),
              ListTile(
                title: const Text('Email'),
                subtitle: Text(akun.email),
              ),
              ListTile(
                title: const Text('NIK'),
                subtitle: Text(perorangan?.nik ?? '-'),
              ),
              ListTile(
                title: const Text('No. Telepon'),
                subtitle: Text(perorangan?.noTelepon ?? '-'),
              ),
              ListTile(
                title: const Text('Alamat'),
                subtitle: Text(perorangan?.alamat ?? '-'),
              ),
              ListTile(
                title: const Text('Status Akun'),
                subtitle: Text(
                  akun.statusAktif ? 'Aktif' : 'Non-Aktif',
                  style: TextStyle(
                    color: akun.statusAktif ? Colors.green : Colors.red,
                  ),
                ),
              ),
              if (perusahaan != null) ...[
                const Divider(),
                const Text(
                  'Informasi Perusahaan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Nama Perusahaan'),
                  subtitle: Text(perusahaan.namaPerusahaan ?? '-'),
                ),
                ListTile(
                  title: const Text('Alamat Perusahaan'),
                  subtitle: Text(perusahaan.alamatPerusahaan ?? '-'),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
