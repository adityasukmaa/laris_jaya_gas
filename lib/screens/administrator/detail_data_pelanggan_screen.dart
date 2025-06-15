import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class DetailDataPelangganScreen extends StatefulWidget {
  final int idPelanggan;

  const DetailDataPelangganScreen({Key? key, required this.idPelanggan})
      : super(key: key);

  @override
  _DetailDataPelangganScreenState createState() =>
      _DetailDataPelangganScreenState();
}

class _DetailDataPelangganScreenState extends State<DetailDataPelangganScreen>
    with SingleTickerProviderStateMixin {
  final ManagePelangganController controller =
      Get.find<ManagePelangganController>();
  bool _hasFetched = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPelangganDetail(widget.idPelanggan);
      _hasFetched = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final padding = isLargeScreen ? 24.0 : 16.0;
    final fontSizeTitle = isLargeScreen ? 20.0 : 18.0;
    final fontSizeBody = isLargeScreen ? 16.0 : 14.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          _buildAppBarActionButton(
            icon: Icons.edit,
            color: Colors.white,
            tooltip: 'Edit Pelanggan',
            onPressed: () {
              if (controller.selectedPelanggan.value != null) {
                Get.toNamed('/administrator/edit-data-pelanggan',
                    arguments: controller.selectedPelanggan.value!.idPerorangan
                        .toString());
              } else {
                Get.snackbar(
                  'Error',
                  'Data pelanggan belum dimuat',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.redFlame,
                  colorText: Colors.white,
                );
              }
            },
          ),
          _buildAppBarActionButton(
            icon: Icons.delete,
            color: AppColors.redFlame,
            tooltip: 'Hapus Pelanggan',
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value && !_hasFetched
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : controller.errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: AppColors.redFlame,
                            fontSize: fontSizeBody,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller
                              .fetchPelangganDetail(widget.idPelanggan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Coba Lagi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : controller.selectedPelanggan.value == null
                    ? Center(
                        child: Text(
                          'Data pelanggan tidak ditemukan',
                          style: TextStyle(
                            fontSize: fontSizeBody,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : AnimatedOpacity(
                        opacity: controller.isLoading.value ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoCard(
                                title: 'Informasi Perorangan',
                                children: [
                                  _buildInfoRow(
                                    'Nama Lengkap',
                                    controller.selectedPelanggan.value!
                                            .namaLengkap ??
                                        '-',
                                    fontSizeBody,
                                  ),
                                  _buildInfoRow(
                                    'NIK',
                                    controller.selectedPelanggan.value!.nik ??
                                        '-',
                                    fontSizeBody,
                                  ),
                                  _buildInfoRow(
                                    'No Telepon',
                                    controller.selectedPelanggan.value!
                                            .noTelepon ??
                                        '-',
                                    fontSizeBody,
                                  ),
                                  _buildInfoRow(
                                    'Alamat',
                                    controller
                                            .selectedPelanggan.value!.alamat ??
                                        '-',
                                    fontSizeBody,
                                  ),
                                ],
                                fontSizeTitle: fontSizeTitle,
                                fontSizeBody: fontSizeBody,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                title: 'Informasi Akun',
                                children: controller.selectedAkun.value == null
                                    ? [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Tidak ada akun terkait',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: fontSizeBody,
                                            ),
                                          ),
                                        ),
                                      ]
                                    : [
                                        _buildInfoRow(
                                          'Email',
                                          controller
                                                  .selectedAkun.value!.email ??
                                              '-',
                                          fontSizeBody,
                                        ),
                                        _buildInfoRow(
                                          'Role',
                                          controller.selectedAkun.value!.role ??
                                              '-',
                                          fontSizeBody,
                                        ),
                                        _buildInfoRow(
                                          'Status Aktif',
                                          controller.selectedAkun.value!
                                                      .statusAktif ==
                                                  true
                                              ? 'Aktif'
                                              : 'Tidak Aktif',
                                          fontSizeBody,
                                        ),
                                      ],
                                fontSizeTitle: fontSizeTitle,
                                fontSizeBody: fontSizeBody,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                title: 'Informasi Perusahaan',
                                children: controller.selectedPerusahaan.value ==
                                        null
                                    ? [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Tidak ada perusahaan terkait',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: fontSizeBody,
                                            ),
                                          ),
                                        ),
                                      ]
                                    : [
                                        _buildInfoRow(
                                          'Nama Perusahaan',
                                          controller.selectedPerusahaan.value!
                                                  .namaPerusahaan ??
                                              '-',
                                          fontSizeBody,
                                        ),
                                        _buildInfoRow(
                                          'Alamat Perusahaan',
                                          controller.selectedPerusahaan.value!
                                                  .alamatPerusahaan ??
                                              '-',
                                          fontSizeBody,
                                        ),
                                        _buildInfoRow(
                                          'Email Perusahaan',
                                          controller.selectedPerusahaan.value!
                                                  .emailPerusahaan ??
                                              '-',
                                          fontSizeBody,
                                        ),
                                      ],
                                fontSizeTitle: fontSizeTitle,
                                fontSizeBody: fontSizeBody,
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildAppBarActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(icon, color: color, size: 24),
        tooltip: tooltip,
        onPressed: () {
          _animationController
              .forward()
              .then((_) => _animationController.reverse());
          onPressed();
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    required double fontSizeTitle,
    required double fontSizeBody,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final pelanggan = controller.selectedPelanggan.value;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.redFlame,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Konfirmasi Hapus',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus pelanggan ${pelanggan?.namaLengkap ?? 'ini'}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.deletePelanggan(widget.idPelanggan);
                      Get.back();
                      if (controller.errorMessage.isEmpty) {
                        Get.offNamed('/administrator/data-pelanggan');
                        Get.snackbar(
                          'Sukses',
                          'Pelanggan berhasil dihapus',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redFlame,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
