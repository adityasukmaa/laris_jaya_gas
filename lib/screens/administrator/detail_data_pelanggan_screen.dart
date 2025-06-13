import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';

class DetailDataPelangganScreen extends StatefulWidget {
  final int idPelanggan;

  DetailDataPelangganScreen({Key? key, required this.idPelanggan})
      : super(key: key);

  @override
  _DetailDataPelangganScreenState createState() =>
      _DetailDataPelangganScreenState();
}

class _DetailDataPelangganScreenState extends State<DetailDataPelangganScreen> {
  final ManagePelangganController controller =
      Get.find<ManagePelangganController>();
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    // Panggil fetch setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPelangganDetail(widget.idPelanggan);
      _hasFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (controller.selectedPelanggan.value != null) {
                Get.toNamed('/administrator/edit-data-pelanggan', arguments: widget.idPelanggan);
              } else {
                Get.snackbar(
                  'Error',
                  'Data pelanggan belum dimuat',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              Get.defaultDialog(
                title: 'Konfirmasi Hapus',
                middleText: 'Apakah Anda yakin ingin menghapus pelanggan ini?',
                textConfirm: 'Hapus',
                textCancel: 'Batal',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () async {
                  await controller.deletePelanggan(widget.idPelanggan);
                  Get.back(); // Tutup dialog
                  if (controller.errorMessage.isEmpty) {
                    Get.offNamed('/administrator/data-pelanggan'); 
                  }
                },
                onCancel: () => Get.back(),
              );
            },
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value && !_hasFetched
            ? const Center(child: CircularProgressIndicator())
            : controller.errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.errorMessage.value),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            controller.fetchPelangganDetail(widget.idPelanggan);
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : controller.selectedPelanggan.value == null
                    ? const Center(
                        child: Text('Data pelanggan tidak ditemukan'))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            _buildPelangganInfoCard(),
                            const SizedBox(height: 16),
                            _buildAkunInfoCard(),
                            const SizedBox(height: 16),
                            _buildPerusahaanInfoCard(),
                          ],
                        ),
                      ),
      ),
    );
  }

  // Widget untuk menampilkan informasi perorangan
  Widget _buildPelangganInfoCard() {
    final pelanggan = controller.selectedPelanggan.value!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Perorangan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Nama Lengkap', pelanggan.namaLengkap ?? '-'),
            _buildInfoRow('NIK', pelanggan.nik ?? '-'),
            _buildInfoRow('No Telepon', pelanggan.noTelepon ?? '-'),
            _buildInfoRow('Alamat', pelanggan.alamat ?? '-'),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan informasi akun
  Widget _buildAkunInfoCard() {
    final akun = controller.selectedAkun.value;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Akun',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (akun == null)
              const Text('Tidak ada akun terkait',
                  style: TextStyle(color: Colors.grey))
            else ...[
              _buildInfoRow('Email', akun.email ?? '-'),
              _buildInfoRow('Role', akun.role ?? '-'),
              _buildInfoRow('Status Aktif',
                  akun.statusAktif == true ? 'Aktif' : 'Tidak Aktif'),
            ],
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan informasi perusahaan
  Widget _buildPerusahaanInfoCard() {
    final perusahaan = controller.selectedPerusahaan.value;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Perusahaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (perusahaan == null)
              const Text('Tidak ada perusahaan terkait',
                  style: TextStyle(color: Colors.grey))
            else ...[
              _buildInfoRow(
                  'Nama Perusahaan', perusahaan.namaPerusahaan ?? '-'),
              _buildInfoRow(
                  'Alamat Perusahaan', perusahaan.alamatPerusahaan ?? '-'),
              _buildInfoRow(
                  'Email Perusahaan', perusahaan.emailPerusahaan ?? '-'),
            ],
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan baris informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
