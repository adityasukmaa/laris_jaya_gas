import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../utils/dummy_data.dart';

class TambahTabungScreen extends StatelessWidget {
  final Color primaryBlue = const Color(0xFF0172B2);
  final Color darkBlue = const Color(0xFF001848);

  final List<String> jenisTabungList = [
    'Oksigen',
    'Nitrogen',
    'Argon',
    'Acetelyne',
    'Dinitrogen Oksida'
  ];
  final List<String> statusTabungList = ['Tersedia', 'Dipinjam'];

  final TextEditingController kodeTabungController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TambahTabungScreen({super.key});

  Future<String> _generateQRCode(String data) async {
    final qrCode = await QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImageData(200);
    final qrCodeData = qrCode!.buffer.asUint8List();
    return base64Encode(qrCodeData);
  }

  void _saveTabung() async {
    if (_formKey.currentState!.validate()) {
      if (DummyData.tabungList
          .any((tabung) => tabung.kodeTabung == kodeTabungController.text)) {
        Get.snackbar(
            'Error', 'Kode Tabung sudah ada, silakan gunakan kode lain',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final qrCodeBase64 = await _generateQRCode(kodeTabungController.text);
      final controller = Get.find<TambahTabungController>();
      final newTabung = Tabung(
        kodeTabung: kodeTabungController.text,
        jenisTabung: controller.selectedJenis.value,
        status: controller.selectedStatus.value,
        qrCode: qrCodeBase64,
      );
      DummyData.tabungList.add(newTabung);
      Get.back();
      Get.snackbar('Sukses', 'Tabung berhasil ditambahkan',
          backgroundColor: primaryBlue, colorText: Colors.white);
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
            backgroundColor: primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            title: const Text('Tambah Tabung',
                style: TextStyle(color: Colors.white)),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: paddingVertical, horizontal: 24.0),
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
                          value: controller.selectedJenis.value.isEmpty
                              ? null
                              : controller.selectedJenis.value,
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
                            controller.updateSelectedJenis(value!);
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
                            if (value == null) {
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
                          value: controller.selectedStatus.value.isEmpty
                              ? null
                              : controller.selectedStatus.value,
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
                            controller.updateSelectedStatus(value!);
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
                            if (value == null) {
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
                          backgroundColor: darkBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                        ),
                        child: const Text('Simpan',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
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
