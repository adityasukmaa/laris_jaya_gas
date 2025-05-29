import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import '../../utils/dummy_data.dart';

class TambahTabungScreen extends StatelessWidget {
  final List<String> jenisTabungList = DummyData.jenisTabungList
      .map((jenis) => jenis.namaJenis)
      .toSet()
      .toList(); // Hapus duplikat
  final List<String> statusTabungList = DummyData.statusTabungList
      .map((status) => status.statusTabung)
      .toSet()
      .toList(); // Hapus duplikat

  final TextEditingController kodeTabungController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TambahTabungScreen({super.key});

  void _saveTabung() {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<TambahTabungController>();

      // Debug: Periksa nilai sebelum menyimpan
      print('Selected Jenis: ${controller.selectedJenis.value}');
      print('Selected Status: ${controller.selectedStatus.value}');

      // Cek apakah kode tabung sudah ada
      if (DummyData.tabungList
          .any((tabung) => tabung.kodeTabung == kodeTabungController.text)) {
        Get.snackbar(
          'Error',
          'Kode Tabung sudah ada, silakan gunakan kode lain',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Cari idJenisTabung dan idStatusTabung berdasarkan pilihan pengguna
      final selectedJenisTabung = DummyData.jenisTabungList.firstWhere(
        (jenis) => jenis.namaJenis == controller.selectedJenis.value,
        orElse: () => JenisTabung(
          idJenisTabung: '',
          kodeJenis: '',
          namaJenis: '',
          harga: 0.0,
        ),
      );

      final selectedStatusTabung = DummyData.statusTabungList.firstWhere(
        (status) => status.statusTabung == controller.selectedStatus.value,
        orElse: () => StatusTabung(idStatusTabung: '', statusTabung: ''),
      );

      // Generate ID unik untuk tabung baru
      final newIdTabung =
          'TBG${(DummyData.tabungList.length + 1).toString().padLeft(3, '0')}';

      // Buat tabung baru sesuai model
      final newTabung = Tabung(
        idTabung: newIdTabung,
        kodeTabung: kodeTabungController.text,
        idJenisTabung: selectedJenisTabung.idJenisTabung,
        idStatusTabung: selectedStatusTabung.idStatusTabung,
        jenisTabung: selectedJenisTabung,
        statusTabung: selectedStatusTabung,
      );

      // Tambahkan tabung baru ke DummyData
      DummyData.tabungList.add(newTabung);

      // Kembali ke halaman sebelumnya dan tampilkan notifikasi
      Get.back();
      Get.snackbar(
        'Sukses',
        'Tabung berhasil ditambahkan',
        backgroundColor: AppColors.whiteSemiTransparent,
        colorText: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingVertical = screenHeight * 0.02;

    return GetBuilder<TambahTabungController>(
      init: TambahTabungController(),
      builder: (controller) {
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
          body: SingleChildScrollView(
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
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
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
                        DropdownButtonFormField<String>(
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
                          ),
                          value: jenisTabungList
                                  .contains(controller.selectedJenis.value)
                              ? controller.selectedJenis.value
                              : null,
                          items: jenisTabungList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.updateSelectedJenis(value);
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
                        DropdownButtonFormField<String>(
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
                          ),
                          value: statusTabungList
                                  .contains(controller.selectedStatus.value)
                              ? controller.selectedStatus.value
                              : null,
                          items: statusTabungList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.updateSelectedStatus(value);
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
                        onPressed: _saveTabung,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
