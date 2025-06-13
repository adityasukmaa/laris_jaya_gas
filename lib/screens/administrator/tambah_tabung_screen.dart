import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class TambahTabungScreen extends StatelessWidget {
  final TextEditingController kodeTabungController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TambahTabungScreen({super.key});

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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingVertical = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Tambah Tabung',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Obx(() => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: paddingVertical,
                horizontal: 24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kode Tabung',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: kodeTabungController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Color(0xFFD0D5DD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            prefixIcon: const Icon(Icons.tag,
                                size: 20, color: Color(0xFFD0D5DD)),
                            hintText: 'Masukkan kode tabung (contoh: OXY023)',
                            hintStyle: const TextStyle(fontSize: 14),
                            errorText: controller.fieldErrors['kode_tabung'],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Kode Tabung tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis Tabung',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Color(0xFFD0D5DD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            prefixIcon: const Icon(Icons.category,
                                size: 20, color: Color(0xFFD0D5DD)),
                            hintText: 'Pilih Jenis',
                            hintStyle: const TextStyle(fontSize: 14),
                            errorText:
                                controller.fieldErrors['id_jenis_tabung'],
                          ),
                          value: controller.jenisTabungList.any((jenis) =>
                                  jenis.namaJenis ==
                                  controller.selectedJenis.value)
                              ? controller.selectedJenis.value
                              : controller.jenisTabungList.isNotEmpty
                                  ? controller.jenisTabungList.first.namaJenis
                                  : null,
                          items: controller.jenisTabungList
                              .map((jenis) => DropdownMenuItem(
                                    value: jenis.namaJenis,
                                    child: Text(
                                      jenis.namaJenis ?? '-',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedJenis.value = value;
                            }
                          },
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Color(0xFFD0D5DD), size: 24),
                          isExpanded: true,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                          menuMaxHeight: screenHeight * 0.3,
                          elevation: 8,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis Tabung harus dipilih';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Tabung',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Color(0xFFD0D5DD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            prefixIcon: const Icon(Icons.check_circle_outline,
                                size: 20, color: Color(0xFFD0D5DD)),
                            hintText: 'Pilih Status',
                            hintStyle: const TextStyle(fontSize: 14),
                            errorText:
                                controller.fieldErrors['id_status_tabung'],
                          ),
                          value: controller.statusTabungList.any((status) =>
                                  status.statusTabung ==
                                  controller.selectedStatus.value)
                              ? controller.selectedStatus.value
                              : controller.statusTabungList.isNotEmpty
                                  ? controller
                                      .statusTabungList.first.statusTabung
                                  : null,
                          items: controller.statusTabungList
                              .map((status) => DropdownMenuItem(
                                    value: status.statusTabung,
                                    child: Text(
                                      status.statusTabung ?? '-',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedStatus.value = value;
                            }
                          },
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Color(0xFFD0D5DD), size: 24),
                          isExpanded: true,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                          menuMaxHeight: screenHeight * 0.3,
                          elevation: 8,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Status Tabung harus dipilih';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoadingTabung.value
                            ? null
                            : () => _saveTabung(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoadingTabung.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
