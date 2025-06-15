import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class ManagePelangganScreen extends StatelessWidget {
  final ManagePelangganController controller =
      Get.put(ManagePelangganController());

  @override
  Widget build(BuildContext context) {
    final showFilter = false.obs; // Kontrol visibilitas filter

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Data Pelanggan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => showFilter.toggle(),
            tooltip: 'Tampilkan/Sembunyikan Filter',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
          );
        } else if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style:
                      const TextStyle(color: AppColors.redFlame, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchPelangganList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Tampilkan filter jika showFilter true
            Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: showFilter.value ? 80 : 0,
                  child: showFilter.value
                      ? _buildFilterSection(context)
                      : const SizedBox.shrink(),
                )),
            Expanded(
              child: controller.filteredPelangganList.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pelanggan tersedia.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Gunakan DataTable untuk layar besar (tablet/desktop)
                        if (constraints.maxWidth > 600) {
                          return _buildDataTable(context);
                        }
                        // Gunakan ListView untuk layar kecil (mobile)
                        return _buildListView(context);
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/administrator/tambah-data-pelanggan'),
        backgroundColor: AppColors.secondary,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Tambah Pelanggan',
      ),
    );
  }

  // Widget untuk filter jenis pelanggan
  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              // Pastikan nilai default jika null
              final currentValue =
                  controller.selectedJenisPelanggan.value.isNotEmpty
                      ? controller.selectedJenisPelanggan.value
                      : 'Semua';
              return DropdownButtonFormField<String>(
                value: currentValue,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Jenis Pelanggan',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                  DropdownMenuItem(
                      value: 'Perorangan', child: Text('Perorangan')),
                  DropdownMenuItem(
                      value: 'Perusahaan', child: Text('Perusahaan')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedJenisPelanggan.value = value;
                    controller.applyFilter();
                    debugPrint('Selected Jenis Pelanggan: $value');
                  }
                },
              );
            }),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            onPressed: () {
              controller.fetchPelangganList();
              debugPrint('Refreshing pelanggan list');
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
    );
  }

  // Widget untuk DataTable (layar besar)
  Widget _buildDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        dataRowHeight: 80,
        headingRowColor:
            WidgetStateProperty.all(AppColors.primaryBlue.withOpacity(0.1)),
        columns: const [
          DataColumn(
            label: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('NIK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label:
                Text('Telepon', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label:
                Text('Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Jenis', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Perusahaan',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: controller.filteredPelangganList.map((pelanggan) {
          return DataRow(
            cells: [
              DataCell(Text(pelanggan.namaLengkap ?? 'No Name')),
              DataCell(Text(pelanggan.nik ?? 'No NIK')),
              DataCell(Text(pelanggan.noTelepon ?? 'No Phone')),
              DataCell(Text(pelanggan.alamat ?? 'No Address')),
              DataCell(Text(
                pelanggan.idPerusahaan == null ? 'Perorangan' : 'Perusahaan',
                style: TextStyle(
                  color: pelanggan.idPerusahaan == null
                      ? AppColors.primaryBlue
                      : AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              )),
              DataCell(Text(pelanggan.namaPerusahaan ?? '-')),
            ],
            onSelectChanged: (selected) {
              if (selected ?? false) {
                _navigateToDetail(pelanggan.idPerorangan);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  // Widget untuk ListView (layar kecil)
  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchPelangganList,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredPelangganList.length,
        itemBuilder: (context, index) {
          final pelanggan = controller.filteredPelangganList[index];
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pelanggan.namaLengkap ?? 'No Name',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pelanggan.idPerusahaan == null
                            ? AppColors.primaryBlue.withOpacity(0.1)
                            : AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pelanggan.idPerusahaan == null
                            ? 'Perorangan'
                            : 'Perusahaan',
                        style: TextStyle(
                          color: pelanggan.idPerusahaan == null
                              ? AppColors.primaryBlue
                              : AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('NIK: ${pelanggan.nik ?? 'No NIK'}',
                        style: const TextStyle(fontSize: 14)),
                    Text('Telp: ${pelanggan.noTelepon ?? 'No Phone'}',
                        style: const TextStyle(fontSize: 14)),
                    Text('Alamat: ${pelanggan.alamat ?? 'No Address'}',
                        style: const TextStyle(fontSize: 14)),
                    if (pelanggan.namaPerusahaan != null)
                      Text(
                        'Perusahaan: ${pelanggan.namaPerusahaan}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primaryBlue),
                      ),
                  ],
                ),
                onTap: () => _navigateToDetail(pelanggan.idPerorangan),
              ),
            ),
          );
        },
      ),
    );
  }

  // Navigasi ke halaman detail
  void _navigateToDetail(int? id) {
    if (id != null) {
      Get.toNamed(
        '/administrator/detail-data-pelanggan',
        arguments: id,
      );
    } else {
      Get.snackbar(
        'Error',
        'ID pelanggan tidak valid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.redFlame,
        colorText: Colors.white,
      );
    }
  }
}
