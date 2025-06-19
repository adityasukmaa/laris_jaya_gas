import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class StokTabungScreen extends StatelessWidget {
  final TabungController controller = Get.put(TabungController());
  final RxBool showFilter = false.obs;

  StokTabungScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody(context, isLargeScreen)),
      floatingActionButton: _buildFAB(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title:
          const Text('Stok Tabung', style: TextStyle(color: AppColors.white)),
      iconTheme: const IconThemeData(color: AppColors.white),
      elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: AppColors.white),
          onPressed: showFilter.toggle,
          tooltip: 'Toggle Filter',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isLargeScreen) {
    if (controller.isLoadingTabung.value) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (controller.errorMessageTabung.isNotEmpty) {
      return _buildErrorState(context);
    }
    return Column(
      children: [
        Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: showFilter.value ? 90 : 0,
              child: showFilter.value
                  ? _buildFilterSection(context)
                  : const SizedBox.shrink(),
            )),
        Expanded(child: _buildTabungList(context, isLargeScreen)),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.errorMessageTabung.value,
            style: const TextStyle(color: AppColors.redFlame, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchAllTabung,
            style: _buttonStyle(),
            child: const Text('Coba Lagi',
                style: TextStyle(color: AppColors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      color: AppColors.greyBackground,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildJenisFilterDropdown()),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusFilterDropdown()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJenisFilterDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedJenis.value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Jenis Tabung',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            const DropdownMenuItem(value: 'Semua', child: Text('Semua')),
            ...controller.jenisTabungList.map(
              (jenis) => DropdownMenuItem(
                value: jenis.namaJenis,
                child: Text(jenis.namaJenis ?? '-'),
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.selectedJenis.value = value;
              controller.applyFilter();
            }
          },
        ));
  }

  Widget _buildStatusFilterDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedStatus.value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Status Tabung',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            const DropdownMenuItem(value: 'Semua', child: Text('Semua')),
            ...controller.statusTabungList.map(
              (status) => DropdownMenuItem(
                value: status.statusTabung,
                child: Text(status.statusTabung ?? '-'),
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.selectedStatus.value = value;
              controller.applyFilter();
            }
          },
        ));
  }

  Widget _buildTabungList(BuildContext context, bool isLargeScreen) {
    if (controller.filteredTabungList.isEmpty) {
      return const Center(
        child: Text('Tidak ada tabung tersedia.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return isLargeScreen ? _buildDataTable(context) : _buildListView(context);
  }

  Widget _buildDataTable(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchAllTabung,
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          dataRowHeight: 80,
          headingRowColor:
              WidgetStateProperty.all(AppColors.primaryBlue.withOpacity(0.1)),
          columns: const [
            DataColumn(
                label: Text('Kode',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Jenis',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: controller.filteredTabungList
              .map((tabung) => _buildDataRow(tabung))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(Tabung tabung) {
    Color statusColor;
    switch (tabung.statusTabung?.statusTabung) {
      case 'tersedia':
        statusColor = AppColors.greenSuccess;
        break;
      case 'dipinjam':
        statusColor = AppColors.orangeWarning;
        break;
      case 'rusak':
      case 'hilang':
        statusColor = AppColors.redFlame;
        break;
      default:
        statusColor = Colors.grey;
    }

    return DataRow(
      cells: [
        DataCell(Text(tabung.kodeTabung ?? '-')),
        DataCell(Text(tabung.jenisTabung?.namaJenis ?? '-')),
        DataCell(Text(
          tabung.statusTabung?.statusTabung ?? '-',
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
        )),
      ],
      onSelectChanged: (selected) {
        if (selected ?? false) {
          _navigateToDetail(tabung.idTabung!);
        }
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchAllTabung,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.padding),
        itemCount: controller.filteredTabungList.length,
        itemBuilder: (context, index) {
          final tabung = controller.filteredTabungList[index];
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: _buildTabungCard(tabung),
          );
        },
      ),
    );
  }

  Widget _buildTabungCard(Tabung tabung) {
    Color statusColor;
    switch (tabung.statusTabung?.statusTabung) {
      case 'tersedia':
        statusColor = AppColors.greenSuccess;
        break;
      case 'dipinjam':
        statusColor = AppColors.orangeWarning;
        break;
      case 'rusak':
      case 'hilang':
        statusColor = AppColors.redFlame;
        break;
      default:
        statusColor = Colors.grey;
    }

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
                tabung.kodeTabung ?? '-',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            _buildStatusBadge(tabung),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Jenis: ${tabung.jenisTabung?.namaJenis ?? '-'}',
                style: const TextStyle(fontSize: 14)),
            Text('Status: ${tabung.statusTabung?.statusTabung ?? '-'}',
                style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        onTap: () => _navigateToDetail(tabung.idTabung!),
      ),
    );
  }

  Widget _buildStatusBadge(Tabung tabung) {
    Color badgeColor;
    Color textColor;
    switch (tabung.statusTabung?.statusTabung) {
      case 'tersedia':
        badgeColor = AppColors.greenSuccess.withOpacity(0.1);
        textColor = AppColors.greenSuccess;
        break;
      case 'dipinjam':
        badgeColor = AppColors.orangeWarning.withOpacity(0.1);
        textColor = AppColors.orangeWarning;
        break;
      case 'rusak':
      case 'hilang':
        badgeColor = AppColors.redFlame.withOpacity(0.1);
        textColor = AppColors.redFlame;
        break;
      default:
        badgeColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tabung.statusTabung?.statusTabung ?? '-',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  FloatingActionButton _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(AppRoutes.tambahTabung),
      backgroundColor: AppColors.secondary,
      elevation: 6,
      child: const Icon(Icons.add, color: AppColors.white),
      tooltip: 'Tambah Tabung',
    );
  }

  void _navigateToDetail(int id) {
    Get.toNamed(AppRoutes.detailTabung, arguments: id);
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}
