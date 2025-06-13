import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';

class TambahPelangganScreen extends StatelessWidget {
  final ManagePelangganController controller =
      Get.find<ManagePelangganController>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isAuthenticated = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Pelanggan')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextField(
                controller: nikController,
                decoration: InputDecoration(labelText: 'NIK'),
              ),
              TextField(
                controller: teleponController,
                decoration: InputDecoration(labelText: 'No Telepon'),
              ),
              TextField(
                controller: alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              Obx(
                () => CheckboxListTile(
                  title: Text('Buat Akun'),
                  value: isAuthenticated.value,
                  onChanged: (value) {
                    isAuthenticated.value = value!;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await controller.createPelanggan(
                    namaLengkap: namaController.text,
                    nik: nikController.text,
                    noTelepon: teleponController.text,
                    alamat: alamatController.text,
                    idPerusahaan: null, // Tambahkan dropdown untuk perusahaan
                    email: emailController.text,
                    password: passwordController.text,
                    isAuthenticated: isAuthenticated.value,
                  );
                  if (controller.errorMessage.isEmpty) {
                    Get.back();
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
