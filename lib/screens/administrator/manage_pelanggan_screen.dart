import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class ManagePelangganScreen extends StatelessWidget {
  final ManagePelangganController controller =
      Get.put(ManagePelangganController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Pelanggan'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.toNamed('/administrator/tambah-data-pelanggan');
            },
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : controller.errorMessage.isNotEmpty
                ? Center(child: Text(controller.errorMessage.value))
                : RefreshIndicator(
                    onRefresh: controller.fetchPelangganList,
                    child: ListView.builder(
                      itemCount: controller.pelangganList.length,
                      itemBuilder: (context, index) {
                        final pelanggan = controller.pelangganList[index];
                        return ListTile(
                          title: Text(pelanggan.namaLengkap ?? 'No Name'),
                          subtitle: Text(pelanggan.nik ?? 'No NIK'),
                          onTap: () {
                            // Hanya navigasi tanpa fetch data
                            if (pelanggan.idPerorangan != null) {
                              Get.toNamed(
                                  '/administrator/detail-data-pelanggan',
                                  arguments: pelanggan.idPerorangan);
                            } else {
                              Get.snackbar('Error', 'ID pelanggan tidak valid');
                            }
                          },
                          trailing: IconButton(
                            icon:
                                Icon(Icons.delete, color: AppColors.redFlame),
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Konfirmasi',
                                middleText:
                                    'Hapus pelanggan ${pelanggan.namaLengkap}?',
                                onConfirm: () async {
                                  await controller
                                      .deletePelanggan(pelanggan.idPerorangan!);
                                  Get.back();
                                },
                                onCancel: () => Get.back(),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
