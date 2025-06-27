import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class ManageTransaksiScreen extends StatelessWidget {
  final TransaksiController controller = Get.put(TransaksiController());
  final RxBool showFilter = false.obs;

  ManageTransaksiScreen({super.key});

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
      title: const Text('Data Transaksi',
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
        Expanded(child: _buildTransaksiList(context, isLargeScreen)),
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
            onPressed: controller.fetchAllTransaksi,
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
          value: controller.selectedStatusTransaksi.value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Status Transaksi',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'Semua', child: Text('Semua')),
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            DropdownMenuItem(value: 'Success', child: Text('Selesai')),
            DropdownMenuItem(value: 'Gagal', child: Text('Dibatalkan')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.selectedStatusTransaksi.value = value;
              controller.applyFilter();
            }
          },
        ));
  }

  Widget _buildTransaksiList(BuildContext context, bool isLargeScreen) {
    if (controller.filteredTransaksiList.isEmpty) {
      return const Center(
        child: Text('Tidak ada transaksi tersedia.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return isLargeScreen ? _buildDataTable(context) : _buildListView(context);
  }

  Widget _buildDataTable(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchAllTransaksi,
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
                label: Text('Tanggal',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Pelanggan',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Metode',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: controller.filteredTransaksiList
              .map((transaksi) => _buildDataRow(transaksi))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(Transaksi transaksi) {
    return DataRow(
      cells: [
        DataCell(Text(transaksi.tanggalTransaksi ?? '-')),
        DataCell(Text(_getNamaPelanggan(transaksi))),
        DataCell(
            Text('Rp ${transaksi.totalTransaksi?.toStringAsFixed(0) ?? '0'}')),
        DataCell(Text(transaksi.statusTransaksi ?? '-')),
        DataCell(Text(transaksi.metodePembayaran ?? '-')),
      ],
      onSelectChanged: (selected) {
        if (selected ?? false) {
          _navigateToDetail(transaksi.idTransaksi!);
        }
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchAllTransaksi,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.padding),
        itemCount: controller.filteredTransaksiList.length,
        itemBuilder: (context, index) {
          final transaksi = controller.filteredTransaksiList[index];
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: _buildTransaksiCard(transaksi),
          );
        },
      ),
    );
  }

  Widget _buildTransaksiCard(Transaksi transaksi) {
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
                'Transaksi #${transaksi.idTransaksi}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            _buildStatusBadge(transaksi),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Tanggal: ${transaksi.tanggalTransaksi ?? '-'}',
                style: const TextStyle(fontSize: 14)),
            Text('Pelanggan: ${_getNamaPelanggan(transaksi)}',
                style: const TextStyle(fontSize: 14)),
            Text(
                'Total: Rp ${transaksi.totalTransaksi?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(fontSize: 14)),
            Text('Metode: ${transaksi.metodePembayaran ?? '-'}',
                style: const TextStyle(fontSize: 14)),
            if (transaksi.tagihans != null && transaksi.tagihans!.isNotEmpty)
              Text('Status Tagihan: ${transaksi.tagihans!.first.status}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.primaryBlue)),
          ],
        ),
        onTap: () => _navigateToDetail(transaksi.idTransaksi!),
      ),
    );
  }

  String _getNamaPelanggan(Transaksi transaksi) {
    if (transaksi.pelanggan != null) {
      if (transaksi.pelanggan!.namaLengkap != null) {
        return transaksi.pelanggan!.namaLengkap!;
      }
      if (transaksi.pelanggan!.perusahaan != null &&
          transaksi.pelanggan!.perusahaan!.namaPerusahaan != null) {
        return transaksi.pelanggan!.perusahaan!.namaPerusahaan!;
      }
    }
    return '-';
  }

  Widget _buildStatusBadge(Transaksi transaksi) {
    final status = transaksi.statusTransaksi ?? 'Unknown';
    final color = status.toLowerCase() == 'pending'
        ? AppColors.redFlame
        : status.toLowerCase() == 'selesai'
            ? AppColors.primaryBlue
            : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  FloatingActionButton _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Get.toNamed('/administrator/tambah-transaksi'),
      backgroundColor: AppColors.secondary,
      elevation: 6,
      child: const Icon(Icons.add, color: AppColors.white),
      tooltip: 'Tambah Transaksi',
    );
  }

  void _navigateToDetail(String id) {
    Get.toNamed(AppRoutes.detailTransaksi, arguments: id);
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}
