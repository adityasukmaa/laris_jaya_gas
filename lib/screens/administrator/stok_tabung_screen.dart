import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class StokTabungScreen extends StatelessWidget {
  const StokTabungScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TabungController controller = Get.find<TabungController>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Stok Tabung', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Obx(() {
        if (controller.isLoadingTabung.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.errorMessageTabung.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessageTabung.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchAllTabung,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Obx(() => DropdownButtonFormField<String>(
                              value: controller.selectedJenis.value,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Jenis Tabung',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'Semua',
                                  child: Text('Semua'),
                                ),
                                ...controller.jenisTabungList
                                    .map((jenis) => DropdownMenuItem(
                                          value: jenis.namaJenis,
                                          child: Text(jenis.namaJenis ?? '-'),
                                        ))
                                    .toList(),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedJenis.value = value;
                                  controller.applyFilter();
                                }
                              },
                            ));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedStatus.value,
                          decoration: const InputDecoration(
                            labelText: 'Status Tabung',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Semua'),
                            ),
                            ...controller.statusTabungList
                                .map((status) => DropdownMenuItem(
                                      value: status.statusTabung,
                                      child: Text(status.statusTabung ?? '-'),
                                    ))
                                .toList(),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedStatus.value = value;
                              controller.applyFilter();
                            }
                          },
                        )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.filteredTabungList.isEmpty
                  ? const Center(child: Text('Tidak ada tabung tersedia.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.filteredTabungList.length,
                      itemBuilder: (context, index) {
                        final Tabung tabung =
                            controller.filteredTabungList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            title: Text(
                              tabung.kodeTabung ?? 'Tidak Diketahui',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Jenis: ${tabung.jenisTabung?.namaJenis ?? 'Unknown'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${tabung.statusTabung?.statusTabung ?? 'Unknown'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            onTap: () => Get.toNamed(
                              '/administrator/detail-tabung',
                              arguments: tabung.idTabung,
                            ),
                            trailing: SizedBox(
                              width: 96,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: AppColors.primaryBlue, size: 18),
                                    onPressed: () => Get.toNamed(
                                      '/administrator/edit-tabung',
                                      arguments: tabung.idTabung,
                                    ),
                                    tooltip: 'Edit Tabung',
                                    padding: EdgeInsets.zero,
                                    constraints:
                                        const BoxConstraints(minWidth: 40),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: AppColors.redFlame, size: 18),
                                    onPressed: () {
                                      Get.defaultDialog(
                                        title: '',
                                        titlePadding: EdgeInsets.zero,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                16, 16, 16, 16),
                                        backgroundColor: Colors.white,
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Apakah Anda yakin ingin menghapus tabung ${tabung.kodeTabung}?',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.secondary,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 18),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () => Get.back(),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12,
                                                        horizontal: 38),
                                                    side: BorderSide(
                                                        color: AppColors
                                                            .secondary),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16)),
                                                  ),
                                                  child: const Text(
                                                    'Batal',
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.secondary,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (tabung.idTabung !=
                                                        null) {
                                                      controller.deleteTabung(
                                                          tabung.idTabung!);
                                                      Get.back();
                                                    } else {
                                                      Get.snackbar(
                                                        'Error',
                                                        'ID Tabung tidak valid',
                                                        snackPosition:
                                                            SnackPosition.TOP,
                                                        backgroundColor:
                                                            AppColors.redFlame,
                                                        colorText: Colors.white,
                                                      );
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.redFlame,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12,
                                                        horizontal: 38),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16)),
                                                  ),
                                                  child: const Text(
                                                    'Hapus',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    tooltip: 'Hapus Tabung',
                                    padding: EdgeInsets.zero,
                                    constraints:
                                        const BoxConstraints(minWidth: 40),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/administrator/tambah-tabung'),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
