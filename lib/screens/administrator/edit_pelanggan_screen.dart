import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class EditPelangganScreen extends StatelessWidget {
  final ManagePelangganController controller =
      Get.find<ManagePelangganController>();
  final String idPelanggan = Get.arguments as String;

  EditPelangganScreen() {
    // Load data pelanggan setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPelangganData(idPelanggan);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pelanggan'),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller.namaLengkapController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama lengkap wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.nikController,
                          decoration: InputDecoration(
                            labelText: 'NIK',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'NIK wajib diisi';
                            }
                            if (value.length != 16) {
                              return 'NIK harus 16 digit';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.noTeleponController,
                          decoration: InputDecoration(
                            labelText: 'No. Telepon',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'No. telepon wajib diisi';
                            }
                            if (!RegExp(r'^\+?[1-9]\d{9,14}$')
                                .hasMatch(value)) {
                              return 'No. telepon tidak valid';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.alamatController,
                          decoration: InputDecoration(
                            labelText: 'Alamat',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Alamat wajib diisi';
                            }
                            return null;
                          },
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.namaPerusahaanController,
                          decoration: InputDecoration(
                            labelText: 'Nama Perusahaan (Opsional)',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.emailController,
                          decoration: InputDecoration(
                            labelText: 'Email (Opsional)',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Email tidak valid';
                              }
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password (Opsional)',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              bool success = await controller.updatePelanggan(
                                id: idPelanggan,
                                namaLengkap:
                                    controller.namaLengkapController.text,
                                nik: controller.nikController.text,
                                noTelepon: controller.noTeleponController.text,
                                alamat: controller.alamatController.text,
                                email: controller.emailController.text.isEmpty
                                    ? null
                                    : controller.emailController.text,
                                password:
                                    controller.passwordController.text.isEmpty
                                        ? null
                                        : controller.passwordController.text,
                                statusAktif:
                                    controller.selectedAkun.value?.statusAktif,
                              );
                              if (success) {
                                Get.back();
                                Get.snackbar(
                                  'Sukses',
                                  'Pelanggan berhasil diperbarui',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
