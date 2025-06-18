import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class ManagePelangganScreen extends StatelessWidget {
  final ManagePelangganController controller =
      Get.put(ManagePelangganController());
  final RxBool showFilter = false.obs;

  ManagePelangganScreen({super.key});

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
      title: const Text('Data Pelanggan',
          style: TextStyle(color: AppColors.white)),
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
    if (controller.isLoading.value) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (controller.errorMessage.isNotEmpty) {
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
        Expanded(child: _buildPelangganList(context, isLargeScreen)),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.errorMessage.value,
            style: const TextStyle(color: AppColors.redFlame, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchAllPelanggan,
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
                Expanded(child: _buildFilterDropdown()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedJenisPelanggan.value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Jenis Pelanggan',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'Semua', child: Text('Semua')),
            DropdownMenuItem(value: 'Perorangan', child: Text('Perorangan')),
            DropdownMenuItem(value: 'Perusahaan', child: Text('Perusahaan')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.selectedJenisPelanggan.value = value;
              controller.applyFilter();
            }
          },
        ));
  }

  Widget _buildPelangganList(BuildContext context, bool isLargeScreen) {
    if (controller.filteredPelangganList.isEmpty) {
      return const Center(
        child: Text('Tidak ada pelanggan tersedia.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return isLargeScreen ? _buildDataTable(context) : _buildListView(context);
  }

  Widget _buildDataTable(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchAllPelanggan,
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
                label: Text('Nama',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label:
                    Text('NIK', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Telepon',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Alamat',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Email',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Perusahaan',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: controller.filteredPelangganList
              .map((pelanggan) => _buildDataRow(pelanggan))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(Perorangan pelanggan) {
    return DataRow(
      cells: [
        DataCell(Text(pelanggan.namaLengkap ?? '-')),
        DataCell(Text(pelanggan.nik ?? '-')),
        DataCell(Text(pelanggan.noTelepon ?? '-')),
        DataCell(Text(pelanggan.alamat ?? '-')),
        DataCell(Text(pelanggan.akun?.email ?? '-')),
        DataCell(Text(pelanggan.perusahaan?.namaPerusahaan ?? '-')),
      ],
      onSelectChanged: (selected) {
        if (selected ?? false) {
          _navigateToDetail(pelanggan.idPerorangan!);
        }
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchAllPelanggan,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.padding),
        itemCount: controller.filteredPelangganList.length,
        itemBuilder: (context, index) {
          final pelanggan = controller.filteredPelangganList[index];
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: _buildPelangganCard(pelanggan),
          );
        },
      ),
    );
  }

  Widget _buildPelangganCard(Perorangan pelanggan) {
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
                pelanggan.namaLengkap ?? '-',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            _buildJenisBadge(pelanggan),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('NIK: ${pelanggan.nik}', style: const TextStyle(fontSize: 14)),
            Text('Telp: ${pelanggan.noTelepon}',
                style: const TextStyle(fontSize: 14)),
            Text('Alamat: ${pelanggan.alamat}',
                style: const TextStyle(fontSize: 14)),
            if (pelanggan.akun != null)
              Text('Email: ${pelanggan.akun!.email}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.primaryBlue)),
            if (pelanggan.perusahaan != null)
              Text('Perusahaan: ${pelanggan.perusahaan!.namaPerusahaan}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.primaryBlue)),
          ],
        ),
        onTap: () => _navigateToDetail(pelanggan.idPerorangan!),
      ),
    );
  }

  Widget _buildJenisBadge(Perorangan pelanggan) {
    final isPerorangan = pelanggan.perusahaan == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPerorangan
            ? AppColors.primaryBlue.withOpacity(0.1)
            : AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPerorangan ? 'Perorangan' : 'Perusahaan',
        style: TextStyle(
          color: isPerorangan ? AppColors.primaryBlue : AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  FloatingActionButton _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(AppRoutes.tambahPelanggan),
      backgroundColor: AppColors.secondary,
      elevation: 6,
      child: const Icon(Icons.add, color: AppColors.white),
      tooltip: 'Tambah Pelanggan',
    );
  }

  void _navigateToDetail(int id) {
    Get.toNamed(AppRoutes.detailDataPelanggan, arguments: id);
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}
