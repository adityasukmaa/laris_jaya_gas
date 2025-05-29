import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/stok_tabung_controller.dart';
import '../../utils/dummy_data.dart';
import '../../utils/constants.dart'; // Impor AppColors

class StokTabungScreen extends StatelessWidget {
  StokTabungScreen({super.key});

  // Daftar jenis tabung untuk dropdown (sesuai dengan JenisTabung di DummyData)
  final List<String> jenisTabungList = [
    'Semua',
    ...DummyData.jenisTabungList.map((jenis) => jenis.namaJenis).toList(),
  ];

  // Daftar status tabung untuk dropdown (sesuai dengan StatusTabung di DummyData)
  final List<String> statusTabungList = [
    'Semua',
    ...DummyData.statusTabungList.map((status) => status.statusTabung).toList(),
  ];

  @override
  Widget build(BuildContext context) {
    final StokTabungController controller = Get.put(StokTabungController());

    // Dapatkan tinggi dan lebar layar untuk penyesuaian responsif
    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingVertical = screenHeight * 0.02; // 2% dari tinggi layar

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Stok Tabung', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: paddingVertical, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Tabung Tersedia: ${DummyData.tabungList.where((tabung) => tabung.statusTabung?.statusTabung == 'tersedia').length}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Tabung Keseluruhan: ${DummyData.tabungList.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedJenis.value.isEmpty
                              ? 'Semua'
                              : controller.selectedJenis.value,
                          decoration: InputDecoration(
                            labelText: 'Jenis Tabung',
                            labelStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryBlue),
                            ),
                          ),
                          items: jenisTabungList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontWeight:
                                      value == controller.selectedJenis.value
                                          ? FontWeight.normal
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedJenis.value = value;
                            }
                          },
                        )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedStatus.value.isEmpty
                              ? 'Semua'
                              : controller.selectedStatus.value,
                          decoration: InputDecoration(
                            labelText: 'Status Tabung',
                            labelStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryBlue),
                            ),
                          ),
                          items: statusTabungList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontWeight:
                                      value == controller.selectedStatus.value
                                          ? FontWeight.normal
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedStatus.value = value;
                            }
                          },
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controller.applyFilter();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Terapkan Filter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredTabungList.length,
                    itemBuilder: (context, index) {
                      final tabung = controller.filteredTabungList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: tabung.statusTabung?.statusTabung == 'tersedia'
                            ? Colors.grey[200]
                            : Colors.blue[100],
                        child: ListTile(
                          title: Text('Kode: ${tabung.kodeTabung}'),
                          subtitle: Text(
                              'Jenis: ${tabung.jenisTabung?.namaJenis ?? 'Tidak diketahui'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tabung.statusTabung?.statusTabung ??
                                    'Tidak diketahui',
                                style: TextStyle(
                                  color: tabung.statusTabung?.statusTabung ==
                                          'tersedia'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: AppColors.primaryBlue, size: 20),
                                onPressed: () {
                                  Get.toNamed('/administrator/edit-tabung',
                                      arguments: tabung.kodeTabung);
                                },
                                tooltip: 'Edit Tabung',
                              ),
                            ],
                          ),
                          onTap: () {
                            Get.toNamed('/administrator/detail-tabung',
                                arguments: tabung.kodeTabung);
                          },
                        ),
                      );
                    },
                  )),
              const SizedBox(height: 80), // Tambahan padding bawah untuk FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/administrator/tambah-tabung');
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
