import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class TambahTabungScreen extends StatelessWidget {
  TambahTabungScreen({super.key});

  final TextEditingController kodeTabungController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _saveTabung(TabungController controller) {
    if (_formKey.currentState!.validate()) {
      final selectedJenis = controller.jenisTabungList.firstWhere(
        (jenis) => jenis.namaJenis == controller.selectedJenis.value,
        orElse: () => controller.jenisTabungList.first,
      );
      final selectedStatus = controller.statusTabungList.firstWhere(
        (status) => status.statusTabung == controller.selectedStatus.value,
        orElse: () => controller.statusTabungList.first,
      );

      controller.createTabung(
        kodeTabung: kodeTabungController.text.trim(),
        idJenisTabung: selectedJenis.idJenisTabung ?? 0,
        idStatusTabung: selectedStatus.idStatusTabung ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TabungController controller = Get.find<TabungController>();
    final double padding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title:
            const Text('Tambah Tabung', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingTabung.value ||
            controller.jenisTabungList.isEmpty ||
            controller.statusTabungList.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }

        return SingleChildScrollView(
          child: Padding(
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.tag,
                              size: 20, color: Colors.grey),
                          hintText: 'Masukkan kode tabung (contoh: OXY023)',
                          errorText: controller.fieldErrors['kode_tabung'],
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kode Tabung tidak boleh kosong';
                          }
                          if (!RegExp(r'^[A-Z0-9]{5,10}$')
                              .hasMatch(value.trim())) {
                            return 'Kode harus 5-10 karakter alfanumerik';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Jenis Tabung',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.category,
                              size: 20, color: Colors.grey),
                          hintText: 'Pilih Jenis',
                          errorText: controller.fieldErrors['id_jenis_tabung'],
                        ),
                        value: controller.jenisTabungList.any((jenis) =>
                                jenis.namaJenis ==
                                controller.selectedJenis.value)
                            ? controller.selectedJenis.value
                            : controller.jenisTabungList.first.namaJenis,
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
                      ),
                      const SizedBox(height: 16),
                      const Text('Status Tabung',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.check_circle_outline,
                              size: 20, color: Colors.grey),
                          hintText: 'Pilih Status',
                          errorText: controller.fieldErrors['id_status_tabung'],
                        ),
                        value: controller.statusTabungList.any((status) =>
                                status.statusTabung ==
                                controller.selectedStatus.value)
                            ? controller.selectedStatus.value
                            : controller.statusTabungList.first.statusTabung,
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
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.isLoadingTabung.value
                                  ? null
                                  : () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(
                                    color: AppColors.secondary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Batal',
                                  style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: controller.isLoadingTabung.value
                                  ? null
                                  : () => _saveTabung(controller),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: controller.isLoadingTabung.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Simpan',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
