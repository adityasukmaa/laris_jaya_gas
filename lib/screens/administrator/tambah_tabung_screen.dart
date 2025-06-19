import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class TambahTabungScreen extends StatelessWidget {
  final TabungController controller = Get.find<TabungController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController kodeTabungController = TextEditingController();

  TambahTabungScreen({super.key}) {
    // Clear controller on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      kodeTabungController.clear();
      controller.selectedJenis.value = controller.jenisTabungList.isNotEmpty
          ? controller.jenisTabungList.first.namaJenis ?? 'Semua'
          : 'Semua';
      controller.selectedStatus.value = controller.statusTabungList.isNotEmpty
          ? controller.statusTabungList.first.statusTabung ?? 'Semua'
          : 'Semua';
      controller.fieldErrors.clear(); // Reset field errors
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      resizeToAvoidBottomInset:
          true, // Allow body to resize when keyboard appears
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody(context)),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: const Text('Tambah Tabung',
          style: TextStyle(color: AppColors.white, fontSize: 20)),
      iconTheme: const IconThemeData(color: AppColors.white),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoadingTabung.value ||
        controller.jenisTabungList.isEmpty ||
        controller.statusTabungList.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: AppSizes.padding,
          left: AppSizes.padding,
          right: AppSizes.padding,
          bottom: AppSizes.padding +
              MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                  height: 16), // Extra padding to prevent label cutoff
              Obx(() => _buildTextField(
                    textController: kodeTabungController,
                    label: 'Kode Tabung',
                    icon: Icons.tag,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kode Tabung tidak boleh kosong';
                      }
                      if (!RegExp(r'^[A-Z0-9]{2,10}$').hasMatch(value.trim())) {
                        return 'Kode harus 2-10 karakter alfanumerik';
                      }
                      if (controller.tabungList
                          .any((tabung) => tabung.kodeTabung == value.trim())) {
                        return 'Kode Tabung sudah ada';
                      }
                      return null;
                    },
                  )),
              Obx(() => AnimatedOpacity(
                    opacity: controller.jenisTabungList.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildJenisDropdown(),
                  )),
              Obx(() => AnimatedOpacity(
                    opacity: controller.statusTabungList.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildStatusDropdown(),
                  )),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: textController,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey, size: AppSizes.iconSize),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          errorText:
              controller.fieldErrors[label.toLowerCase().replaceAll(' ', '_')],
          errorBorder: controller.fieldErrors
                  .containsKey(label.toLowerCase().replaceAll(' ', '_'))
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  borderSide: const BorderSide(color: AppColors.redFlame),
                )
              : null,
          focusedErrorBorder: controller.fieldErrors
                  .containsKey(label.toLowerCase().replaceAll(' ', '_'))
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  borderSide: const BorderSide(color: AppColors.redFlame),
                )
              : null,
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildJenisDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.jenisTabungList.any((jenis) =>
                    jenis.namaJenis == controller.selectedJenis.value)
                ? controller.selectedJenis.value
                : controller.jenisTabungList.first.namaJenis,
            decoration: InputDecoration(
              labelText: 'Jenis Tabung',
              prefixIcon: const Icon(Icons.category,
                  color: Colors.grey, size: AppSizes.iconSize),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorText: controller.fieldErrors['id_jenis_tabung'],
              errorBorder: controller.fieldErrors.containsKey('id_jenis_tabung')
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      borderSide: const BorderSide(color: AppColors.redFlame),
                    )
                  : null,
              focusedErrorBorder: controller.fieldErrors
                      .containsKey('id_jenis_tabung')
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      borderSide: const BorderSide(color: AppColors.redFlame),
                    )
                  : null,
            ),
            items: controller.jenisTabungList
                .map((jenis) => DropdownMenuItem<String>(
                      value: jenis.namaJenis,
                      child: Text(jenis.namaJenis ?? '-'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedJenis.value = value;
              }
            },
            isExpanded: true,
            validator: (value) => value == null || value.isEmpty
                ? 'Jenis Tabung harus dipilih'
                : null,
          )),
    );
  }

  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.statusTabungList.any((status) =>
                    status.statusTabung == controller.selectedStatus.value)
                ? controller.selectedStatus.value
                : controller.statusTabungList.first.statusTabung,
            decoration: InputDecoration(
              labelText: 'Status Tabung',
              prefixIcon: const Icon(Icons.check_circle_outline,
                  color: Colors.grey, size: AppSizes.iconSize),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorText: controller.fieldErrors['id_status_tabung'],
              errorBorder: controller.fieldErrors
                      .containsKey('id_status_tabung')
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      borderSide: const BorderSide(color: AppColors.redFlame),
                    )
                  : null,
              focusedErrorBorder: controller.fieldErrors
                      .containsKey('id_status_tabung')
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      borderSide: const BorderSide(color: AppColors.redFlame),
                    )
                  : null,
            ),
            items: controller.statusTabungList
                .map((status) => DropdownMenuItem<String>(
                      value: status.statusTabung,
                      child: Text(status.statusTabung ?? '-'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedStatus.value = value;
              }
            },
            isExpanded: true,
            validator: (value) => value == null || value.isEmpty
                ? 'Status Tabung harus dipilih'
                : null,
          )),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                controller.isLoadingTabung.value ? null : () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.secondary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.secondary, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(() => ElevatedButton(
                onPressed: controller.isLoadingTabung.value
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            controller.fieldErrors
                                .clear(); // Reset field errors before API call
                            final selectedJenis =
                                controller.jenisTabungList.firstWhere(
                              (jenis) =>
                                  jenis.namaJenis ==
                                  controller.selectedJenis.value,
                              orElse: () => controller.jenisTabungList.first,
                            );
                            final selectedStatus =
                                controller.statusTabungList.firstWhere(
                              (status) =>
                                  status.statusTabung ==
                                  controller.selectedStatus.value,
                              orElse: () => controller.statusTabungList.first,
                            );

                            await controller.createTabung(
                              kodeTabung: kodeTabungController.text.trim(),
                              idJenisTabung: selectedJenis.idJenisTabung ?? 0,
                              idStatusTabung:
                                  selectedStatus.idStatusTabung ?? 0,
                            );
                          } catch (e) {
                            if (controller.fieldErrors
                                .containsKey('kode_tabung')) {
                              Get.snackbar(
                                'Kode Tabung Sudah Digunakan',
                                'Kode tabung yang dimasukkan sudah terdaftar. Silakan gunakan kode lain.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.redFlame,
                                colorText: AppColors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Gagal',
                                e.toString().replaceFirst('Exception: ', ''),
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.redFlame,
                                colorText: AppColors.white,
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: controller.isLoadingTabung.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2),
                      )
                    : const Text('Simpan',
                        style: TextStyle(color: AppColors.white, fontSize: 16)),
              )),
        ),
      ],
    );
  }
}
