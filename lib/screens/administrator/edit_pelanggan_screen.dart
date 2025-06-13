import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';

class EditDataPelangganScreen extends StatelessWidget {
  final ManagePelangganController controller =
      Get.find<ManagePelangganController>();
  final int idPelanggan = Get.arguments as int;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pre-fill form dengan data pelanggan
    if (controller.selectedPelanggan.value != null) {
      namaController.text =
          controller.selectedPelanggan.value!.namaLengkap ?? '';
      nikController.text = controller.selectedPelanggan.value!.nik ?? '';
      teleponController.text =
          controller.selectedPelanggan.value!.noTelepon ?? '';
      alamatController.text = controller.selectedPelanggan.value!.alamat ?? '';
      if (controller.selectedAkun.value != null) {
        emailController.text = controller.selectedAkun.value!.email ?? '';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pelanggan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextField(
                controller: nikController,
                decoration: const InputDecoration(labelText: 'NIK'),
              ),
              TextField(
                controller: teleponController,
                decoration: const InputDecoration(labelText: 'No Telepon'),
              ),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration:
                    const InputDecoration(labelText: 'Password (opsional)'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await controller.updatePelanggan(
                    id: idPelanggan,
                    namaLengkap: namaController.text,
                    nik: nikController.text,
                    noTelepon: teleponController.text,
                    alamat: alamatController.text,
                    email: emailController.text,
                    password: passwordController.text.isEmpty
                        ? null
                        : passwordController.text,
                    statusAktif: controller.selectedAkun.value?.statusAktif,
                  );
                  if (controller.errorMessage.isEmpty) {
                    Get.back();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
