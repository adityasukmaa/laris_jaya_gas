import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class StokTabungScreen extends StatelessWidget {
  const StokTabungScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TabungController controller = Get.find<TabungController>();
    final showFilter = false.obs;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Stok Tabung', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: showFilter.toggle,
            tooltip: 'Tampilkan/Sembunyikan Filter',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingTabung.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue));
        } else if (controller.errorMessageTabung.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessageTabung.value,
                  style:
                      const TextStyle(color: AppColors.redFlame, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchAllTabung,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.cardRadius)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Coba Lagi',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: showFilter.value ? 80 : 0,
                  child: showFilter.value
                      ? _buildFilterSection(context, controller)
                      : const SizedBox.shrink(),
                )),
            Expanded(
              child: controller.filteredTabungList.isEmpty
                  ? const Center(
                      child: Text('Tidak ada tabung tersedia.',
                          style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return constraints.maxWidth > 600
                            ? _buildDataTable(controller)
                            : _buildListView(controller);
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
        tooltip: 'Tambah Tabung',
      ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, TabungController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.padding, vertical: 12),
      color: Colors.grey[100],
      child: Obx(() {
        if (controller.jenisTabungList.isEmpty ||
            controller.statusTabungList.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }

        final jenisItems = [
          const DropdownMenuItem(value: 'Semua', child: Text('Semua')),
          ...controller.jenisTabungList.map((jenis) => DropdownMenuItem(
              value: jenis.namaJenis, child: Text(jenis.namaJenis ?? '-'))),
        ];
        final statusItems = [
          const DropdownMenuItem(value: 'Semua', child: Text('Semua')),
          ...controller.statusTabungList.map((status) => DropdownMenuItem(
              value: status.statusTabung,
              child: Text(status.statusTabung ?? '-'))),
        ];

        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: controller.selectedJenis.value,
                decoration: InputDecoration(
                  labelText: 'Jenis Tabung',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: jenisItems,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedJenis.value = value;
                    controller.applyFilter();
                  }
                },
                isExpanded: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: controller.selectedStatus.value,
                decoration: InputDecoration(
                  labelText: 'Status Tabung',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: statusItems,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedStatus.value = value;
                    controller.applyFilter();
                  }
                },
                isExpanded: true,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDataTable(TabungController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        dataRowHeight: 80,
        headingRowColor:
            WidgetStateProperty.all(AppColors.primaryBlue.withOpacity(0.1)),
        columns: const [
          DataColumn(
              label:
                  Text('Kode', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label:
                  Text('Jenis', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Status',
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: controller.filteredTabungList.map((tabung) {
          return DataRow(
            cells: [
              DataCell(Text(tabung.kodeTabung ?? 'No Kode')),
              DataCell(Text(tabung.jenisTabung?.namaJenis ?? 'No Jenis')),
              DataCell(Text(
                tabung.statusTabung?.statusTabung ?? '',
                style: TextStyle(
                  color: tabung.statusTabung?.statusTabung == 'tersedia'
                      ? AppColors.greenSuccess
                      : AppColors.redFlame,
                  fontWeight: FontWeight.w600,
                ),
              )),
            ],
            onSelectChanged: (selected) {
              if (selected == true) {
                Get.toNamed('/administrator/detail-tabung',
                    arguments: tabung.idTabung);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListView(TabungController controller) {
    return RefreshIndicator(
      onRefresh: controller.fetchAllTabung,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.padding),
        itemCount: controller.filteredTabungList.length,
        itemBuilder: (context, index) {
          final tabung = controller.filteredTabungList[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      tabung.kodeTabung ?? 'No Kode',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tabung.statusTabung?.statusTabung == 'tersedia'
                          ? AppColors.greenSuccess.withOpacity(0.1)
                          : AppColors.orangeWarning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tabung.statusTabung?.statusTabung ?? 'Unknown',
                      style: TextStyle(
                        color: tabung.statusTabung?.statusTabung == 'tersedia'
                            ? AppColors.greenSuccess
                            : AppColors.orangeWarning,
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
                  Text('Jenis: ${tabung.jenisTabung?.namaJenis ?? 'No Jenis'}',
                      style: const TextStyle(fontSize: 14)),
                  Text(
                      'Status: ${tabung.statusTabung?.statusTabung ?? 'No Status'}',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
              onTap: () => Get.toNamed('/administrator/detail-tabung',
                  arguments: tabung.idTabung),
            ),
          );
        },
      ),
    );
  }
}
