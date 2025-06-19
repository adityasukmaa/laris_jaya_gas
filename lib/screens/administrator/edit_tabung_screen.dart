import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class EditTabungScreen extends StatelessWidget {
  final int idTabung;
  final TabungController controller = Get.find<TabungController>();
  final TextEditingController kodeTabungController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxBool _isInitialized = false.obs; // Track initialization

  EditTabungScreen({super.key, required this.idTabung}) {
    // Schedule initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized.value) {
        _initializeData();
        _isInitialized.value = true;
      }
    });
  }

  void _initializeData() {
    // Fetch tabung data if not already loaded or ID differs
    if (controller.selectedTabung.value == null ||
        controller.selectedTabung.value!.idTabung != idTabung) {
      controller.fetchTabungById(idTabung).then((_) {
        final tabung = controller.selectedTabung.value;
        if (tabung != null && kodeTabungController.text.isEmpty) {
          kodeTabungController.text = tabung.kodeTabung ?? '';
          controller.selectedJenis.value = tabung.jenisTabung?.namaJenis ??
              controller.jenisTabungList.firstOrNull?.namaJenis ??
              'Semua';
          controller.selectedStatus.value = tabung.statusTabung?.statusTabung ??
              controller.statusTabungList.firstOrNull?.statusTabung ??
              'Semua';
        }
      });
    } else {
      // If data is already loaded, initialize controllers
      final tabung = controller.selectedTabung.value!;
      if (kodeTabungController.text.isEmpty) {
        kodeTabungController.text = tabung.kodeTabung ?? '';
        controller.selectedJenis.value = tabung.jenisTabung?.namaJenis ??
            controller.jenisTabungList.firstOrNull?.namaJenis ??
            'Semua';
        controller.selectedStatus.value = tabung.statusTabung?.statusTabung ??
            controller.statusTabungList.firstOrNull?.statusTabung ??
            'Semua';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody(context)),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: const Text('Edit Tabung',
          style: TextStyle(color: AppColors.white, fontSize: 20)),
      iconTheme: const IconThemeData(color: AppColors.white),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoadingDetail.value) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (controller.errorMessageDetail.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.errorMessageDetail.value,
              style: const TextStyle(color: AppColors.redFlame, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchTabungById(idTabung),
              style: _buttonStyle(),
              child: const Text('Coba Lagi',
                  style: TextStyle(color: AppColors.white, fontSize: 16)),
            ),
          ],
        ),
      );
    }
    if (controller.selectedTabung.value == null) {
      return const Center(
        child: Text('Tabung tidak ditemukan',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppSizes.padding,
        left: AppSizes.padding,
        right: AppSizes.padding,
        bottom: AppSizes.padding + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildTextField(
              controller: kodeTabungController,
              label: 'Kode Tabung',
              icon: Icons.tag,
              readOnly: true,
            ),
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
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey[300] : Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          errorText: this
              .controller
              .fieldErrors[label.toLowerCase().replaceAll(' ', '_')],
          errorBorder: this
                  .controller
                  .fieldErrors
                  .containsKey(label.toLowerCase().replaceAll(' ', '_'))
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  borderSide: const BorderSide(color: AppColors.redFlame),
                )
              : null,
          focusedErrorBorder: this
                  .controller
                  .fieldErrors
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
        readOnly: readOnly,
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
                : controller.jenisTabungList.firstOrNull?.namaJenis ?? 'Semua',
            decoration: InputDecoration(
              labelText: 'Jenis Tabung',
              prefixIcon: const Icon(Icons.category,
                  color: Colors.grey, size: AppSizes.iconSize),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
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
            items: controller.jenisTabungList.isEmpty
                ? [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Tidak ada jenis tersedia'),
                    )
                  ]
                : controller.jenisTabungList
                    .map((jenis) => DropdownMenuItem<String>(
                          value: jenis.namaJenis,
                          child: Text(jenis.namaJenis ?? '-'),
                        ))
                    .toList(),
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
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
                : controller.statusTabungList.firstOrNull?.statusTabung ??
                    'Semua',
            decoration: InputDecoration(
              labelText: 'Status Tabung',
              prefixIcon: const Icon(Icons.check_circle_outline,
                  color: Colors.grey, size: AppSizes.iconSize),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
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
            items: controller.statusTabungList.isEmpty
                ? [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Tidak ada status tersedia'),
                    )
                  ]
                : controller.statusTabungList
                    .map((status) => DropdownMenuItem<String>(
                          value: status.statusTabung,
                          child: Text(status.statusTabung ?? '-'),
                        ))
                    .toList(),
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
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
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondary, fontSize: 16),
            ),
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
                            controller.fieldErrors.clear();
                            final selectedJenis =
                                controller.jenisTabungList.firstWhere(
                              (jenis) =>
                                  jenis.namaJenis ==
                                  controller.selectedJenis.value,
                              orElse: () =>
                                  controller.jenisTabungList.firstOrNull ??
                                  JenisTabung(idJenisTabung: 0, namaJenis: ''),
                            );
                            final selectedStatus =
                                controller.statusTabungList.firstWhere(
                              (status) =>
                                  status.statusTabung ==
                                  controller.selectedStatus.value,
                              orElse: () =>
                                  controller.statusTabungList.firstOrNull ??
                                  StatusTabung(
                                      idStatusTabung: 0, statusTabung: ''),
                            );

                            if (selectedJenis.idJenisTabung == 0 ||
                                selectedStatus.idStatusTabung == 0) {
                              Get.snackbar(
                                'Error',
                                'Jenis atau Status tidak valid',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.redFlame,
                                colorText: AppColors.white,
                              );
                              return;
                            }

                            await controller.updateTabung(
                              id: idTabung,
                              kodeTabung: kodeTabungController.text.trim(),
                              idJenisTabung: selectedJenis.idJenisTabung!,
                              idStatusTabung: selectedStatus.idStatusTabung!,
                            );
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Tabung berhasil diperbarui',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: AppColors.greenSuccess,
                              colorText: AppColors.white,
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
                                'Error',
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

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}
