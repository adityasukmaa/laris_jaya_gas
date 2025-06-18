import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class EditPelangganScreen extends StatelessWidget {
  final ManagePelangganController controller =
      Get.find<ManagePelangganController>();
  final int idPelanggan = Get.arguments as int;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxBool isPerusahaan = false.obs;
  final RxBool denganAkun = false.obs;

  // Text controllers
  final TextEditingController namaLengkapController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController noTeleponController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController namaPerusahaanController =
      TextEditingController();
  final TextEditingController alamatPerusahaanController =
      TextEditingController();
  final TextEditingController emailPerusahaanController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  EditPelangganScreen({super.key}) {
    // Load pelanggan data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPelangganById(idPelanggan).then((_) {
        final pelanggan = controller.selectedPelanggan.value;
        if (pelanggan != null) {
          namaLengkapController.text = pelanggan.namaLengkap ?? '';
          nikController.text = pelanggan.nik ?? '';
          noTeleponController.text = pelanggan.noTelepon ?? '';
          alamatController.text = pelanggan.alamat ?? '';
          isPerusahaan.value = pelanggan.idPerusahaan != null;
          if (pelanggan.perusahaan != null) {
            namaPerusahaanController.text =
                pelanggan.perusahaan!.namaPerusahaan ?? '';
            alamatPerusahaanController.text =
                pelanggan.perusahaan!.alamatPerusahaan ?? '';
            emailPerusahaanController.text =
                pelanggan.perusahaan!.emailPerusahaan ?? '';
          }
          denganAkun.value = pelanggan.akun != null;
          if (pelanggan.akun != null) {
            emailController.text = pelanggan.akun!.email ?? '';
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody(context)),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: const Text('Edit Pelanggan',
          style: TextStyle(color: AppColors.white)),
      iconTheme: const IconThemeData(color: AppColors.white),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: AppColors.redFlame, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchPelangganById(idPelanggan),
              style: _buttonStyle(),
              child: const Text('Coba Lagi',
                  style: TextStyle(color: AppColors.white, fontSize: 16)),
            ),
          ],
        ),
      );
    }
    if (controller.selectedPelanggan.value == null) {
      return const Center(
          child: Text('Pelanggan tidak ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey)));
    }
    return Padding(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildJenisPelangganSwitch(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: namaLengkapController,
                label: 'Nama Lengkap',
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? 'Nama lengkap wajib diisi' : null,
              ),
              _buildTextField(
                controller: nikController,
                label: 'NIK',
                icon: Icons.badge,
                validator: (value) {
                  if (value!.isEmpty) return 'NIK wajib diisi';
                  if (value.length != 16) return 'NIK harus 16 digit';
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: noTeleponController,
                label: 'No. Telepon',
                icon: Icons.phone,
                validator: (value) {
                  if (value!.isEmpty) return 'No. telepon wajib diisi';
                  if (!RegExp(r'^[0-9]{9,14}$').hasMatch(value)) {
                    return 'No. telepon harus 9-14 digit angka';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: alamatController,
                label: 'Alamat',
                icon: Icons.location_on,
                validator: (value) =>
                    value!.isEmpty ? 'Alamat wajib diisi' : null,
                maxLines: 3,
              ),
              Obx(() => AnimatedOpacity(
                    opacity: isPerusahaan.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: isPerusahaan.value
                        ? _buildTextField(
                            controller: namaPerusahaanController,
                            label: 'Nama Perusahaan',
                            icon: Icons.business,
                            validator: (value) => value!.isEmpty
                                ? 'Nama perusahaan wajib diisi'
                                : null,
                          )
                        : const SizedBox.shrink(),
                  )),
              Obx(() => AnimatedOpacity(
                    opacity: isPerusahaan.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: isPerusahaan.value
                        ? _buildTextField(
                            controller: alamatPerusahaanController,
                            label: 'Alamat Perusahaan',
                            icon: Icons.location_city,
                            validator: (value) => value!.isEmpty
                                ? 'Alamat perusahaan wajib diisi'
                                : null,
                            maxLines: 3,
                          )
                        : const SizedBox.shrink(),
                  )),
              Obx(() => AnimatedOpacity(
                    opacity: isPerusahaan.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: isPerusahaan.value
                        ? _buildTextField(
                            controller: emailPerusahaanController,
                            label: 'Email Perusahaan',
                            icon: Icons.email,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Email perusahaan wajib diisi';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Email perusahaan tidak valid';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          )
                        : const SizedBox.shrink(),
                  )),
              Obx(() => AnimatedOpacity(
                    opacity: !isPerusahaan.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: !isPerusahaan.value
                        ? _buildAkunSwitch()
                        : const SizedBox.shrink(),
                  )),
              Obx(() => AnimatedOpacity(
                    opacity: denganAkun.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: denganAkun.value
                        ? _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email,
                            validator: (value) {
                              if (value!.isEmpty) return 'Email wajib diisi';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          )
                        : const SizedBox.shrink(),
                  )),
              Obx(() => AnimatedOpacity(
                    opacity: denganAkun.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: denganAkun.value
                        ? _buildTextField(
                            controller: passwordController,
                            label: 'Password (Kosongkan jika tidak diubah)',
                            icon: Icons.lock,
                            obscureText: true,
                            validator: (value) {
                              if (value!.isNotEmpty && value.length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              return null;
                            },
                          )
                        : const SizedBox.shrink(),
                  )),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJenisPelangganSwitch() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pelanggan Perusahaan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Obx(() => Switch(
                value: isPerusahaan.value,
                onChanged: (value) {
                  isPerusahaan.value = value;
                  if (value) {
                    denganAkun.value = true; // Perusahaan selalu dengan akun
                  }
                },
                activeColor: AppColors.primaryBlue,
              )),
        ],
      ),
    );
  }

  Widget _buildAkunSwitch() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Buat/Perbarui Akun',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Obx(() => Switch(
                value: denganAkun.value,
                onChanged: (value) => denganAkun.value = value,
                activeColor: AppColors.primaryBlue,
              )),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    bool obscureText = false,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey, size: AppSizes.iconSize),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
          filled: true,
          fillColor: readOnly ? Colors.grey[300] : Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        obscureText: obscureText,
        readOnly: readOnly,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.isLoading.value ? null : () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.secondary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondary, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await controller.updatePelanggan(
                              id: idPelanggan,
                              namaLengkap: namaLengkapController.text,
                              nik: nikController.text,
                              noTelepon: noTeleponController.text,
                              alamat: alamatController.text,
                              namaPerusahaan: isPerusahaan.value
                                  ? namaPerusahaanController.text
                                  : null,
                              alamatPerusahaan: isPerusahaan.value
                                  ? alamatPerusahaanController.text
                                  : null,
                              emailPerusahaan: isPerusahaan.value
                                  ? emailPerusahaanController.text
                                  : null,
                              email: denganAkun.value
                                  ? emailController.text
                                  : null,
                              password: denganAkun.value &&
                                      passwordController.text.isNotEmpty
                                  ? passwordController.text
                                  : null,
                            );
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Pelanggan berhasil diperbarui',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: AppColors.white,
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              e.toString(),
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: AppColors.redFlame,
                              colorText: AppColors.white,
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(color: AppColors.white, fontSize: 16),
                      ),
              )),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}
