import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class EditTabungScreen extends StatelessWidget {
  final int idTabung;
  EditTabungScreen({super.key, required this.idTabung});

  final TextEditingController kodeTabungController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TabungController controller = Get.find<TabungController>();
    final double padding = AppSizes.padding;

    // Inisialisasi data tabung hanya jika selectedTabung belum ada atau ID berbeda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedTabung.value == null ||
          controller.selectedTabung.value!.idTabung != idTabung) {
        controller.fetchTabungById(idTabung);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title:
            const Text('Edit Tabung', style: TextStyle(color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue));
        } else if (controller.errorMessageDetail.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessageDetail.value,
                  style:
                      const TextStyle(color: AppColors.redFlame, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchTabungById(idTabung),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.cardRadius)),
                  ),
                  child:
                      const Text('Coba Lagi', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        } else if (controller.selectedTabung.value == null) {
          return const Center(
            child: Text('Tabung tidak ditemukan',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        final tabung = controller.selectedTabung.value!;
        if (kodeTabungController.text.isEmpty) {
          // Inisialisasi controller hanya sekali untuk menghindari overwrite saat rebuild
          kodeTabungController.text = tabung.kodeTabung ?? '';
          controller.selectedJenis.value = tabung.jenisTabung?.namaJenis ??
              controller.jenisTabungList.firstOrNull?.namaJenis ??
              '';
          controller.selectedStatus.value = tabung.statusTabung?.statusTabung ??
              controller.statusTabungList.firstOrNull?.statusTabung ??
              '';
        }

        void _saveTabung() {
          if (_formKey.currentState!.validate()) {
            final selectedJenis = controller.jenisTabungList.firstWhere(
              (jenis) => jenis.namaJenis == controller.selectedJenis.value,
              orElse: () =>
                  controller.jenisTabungList.firstOrNull ??
                  JenisTabung(idJenisTabung: 0, namaJenis: ''),
            );
            final selectedStatus = controller.statusTabungList.firstWhere(
              (status) =>
                  status.statusTabung == controller.selectedStatus.value,
              orElse: () =>
                  controller.statusTabungList.firstOrNull ??
                  StatusTabung(idStatusTabung: 0, statusTabung: ''),
            );

            if (selectedJenis.idJenisTabung == 0 ||
                selectedStatus.idStatusTabung == 0) {
              Get.snackbar('Error', 'Jenis atau Status tidak valid',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.redFlame,
                  colorText: AppColors.white);
              return;
            }

            controller.updateTabung(
              id: idTabung,
              kodeTabung:
                  tabung.kodeTabung ?? '', // Gunakan nilai asli dari tabung
              idJenisTabung: selectedJenis.idJenisTabung!,
              idStatusTabung: selectedStatus.idStatusTabung!,
            );
          }
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kode Tabung',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: kodeTabungController,
                      readOnly: true, // Membuat field read-only
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[
                            200], // Latar belakang abu-abu untuk indikasi read-only
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        prefixIcon: const Icon(Icons.tag,
                            size: AppSizes.iconSize, color: Colors.grey),
                        hintText: 'Kode tabung',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Jenis Tabung',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.jenisTabungList.any((jenis) =>
                                  jenis.namaJenis ==
                                  controller.selectedJenis.value)
                              ? controller.selectedJenis.value
                              : controller
                                  .jenisTabungList.firstOrNull?.namaJenis,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            prefixIcon: const Icon(Icons.category,
                                size: AppSizes.iconSize, color: Colors.grey),
                            hintText: 'Pilih Jenis',
                            errorText:
                                controller.fieldErrors['id_jenis_tabung'],
                          ),
                          items: controller.jenisTabungList.isEmpty
                              ? [
                                  const DropdownMenuItem<String>(
                                      value: '',
                                      child: Text('Tidak ada jenis tersedia'))
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
                    const SizedBox(height: 16),
                    const Text('Status Tabung',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.statusTabungList.any((status) =>
                                  status.statusTabung ==
                                  controller.selectedStatus.value)
                              ? controller.selectedStatus.value
                              : controller
                                  .statusTabungList.firstOrNull?.statusTabung,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            prefixIcon: const Icon(Icons.check_circle_outline,
                                size: AppSizes.iconSize, color: Colors.grey),
                            hintText: 'Pilih Status',
                            errorText:
                                controller.fieldErrors['id_status_tabung'],
                          ),
                          items: controller.statusTabungList.isEmpty
                              ? [
                                  const DropdownMenuItem<String>(
                                      value: '',
                                      child: Text('Tidak ada status tersedia'))
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
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: controller.isLoadingTabung.value
                                ? null
                                : () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side:
                                  const BorderSide(color: AppColors.secondary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Batal',
                                style: TextStyle(
                                    color: AppColors.secondary, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.isLoadingTabung.value
                                ? null
                                : _saveTabung,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.white,
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
                                    style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
