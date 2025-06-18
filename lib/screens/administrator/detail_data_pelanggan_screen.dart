import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/manage_pelanggan_controller.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class DetailDataPelangganScreen extends StatefulWidget {
  final int idPelanggan;
  const DetailDataPelangganScreen({super.key, required this.idPelanggan});

  @override
  State<DetailDataPelangganScreen> createState() =>
      _DetailDataPelangganScreenState();
}

class _DetailDataPelangganScreenState extends State<DetailDataPelangganScreen>
    with SingleTickerProviderStateMixin {
  final ManagePelangganController controller =
      Get.find<ManagePelangganController>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPelangganById(widget.idPelanggan);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.clearSelectedPelanggan(); // Reset selectedPelanggan saat keluar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final padding = isLargeScreen ? 24.0 : AppSizes.padding;
    final fontSizeTitle = isLargeScreen ? 20.0 : 18.0;
    final fontSizeBody = isLargeScreen ? 16.0 : 14.0;

    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody(padding, fontSizeTitle, fontSizeBody)),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: const Text('Detail Pelanggan',
          style: TextStyle(color: AppColors.white, fontSize: 20)),
      iconTheme: const IconThemeData(color: AppColors.white),
      actions: [
        _buildAppBarActionButton(
          icon: Icons.edit,
          color: AppColors.white,
          tooltip: 'Edit Pelanggan',
          onPressed: () {
            if (controller.selectedPelanggan.value != null) {
              Get.toNamed('/administrator/edit-data-pelanggan',
                  arguments: controller.selectedPelanggan.value!.idPerorangan);
            } else {
              Get.snackbar('Error', 'Data pelanggan belum dimuat',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.redFlame,
                  colorText: AppColors.white);
            }
          },
        ),
        _buildAppBarActionButton(
          icon: Icons.delete,
          color: AppColors.white,
          tooltip: 'Hapus Pelanggan',
          onPressed: () => _showDeleteConfirmationDialog(),
        ),
      ],
    );
  }

  Widget _buildBody(double padding, double fontSizeTitle, double fontSizeBody) {
    if (controller.isLoading.value) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.errorMessage.value,
                style: TextStyle(
                    color: AppColors.redFlame, fontSize: fontSizeBody)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  controller.fetchPelangganById(widget.idPelanggan),
              style: _buttonStyle(),
              child: Text('Coba Lagi',
                  style: TextStyle(
                      color: AppColors.white, fontSize: fontSizeBody)),
            ),
          ],
        ),
      );
    }
    if (controller.selectedPelanggan.value == null) {
      return Center(
          child: Text('Data pelanggan tidak ditemukan',
              style:
                  TextStyle(fontSize: fontSizeBody, color: Colors.grey[600])));
    }
    return RefreshIndicator(
      onRefresh: () => controller.fetchPelangganById(widget.idPelanggan),
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(padding),
        child: AnimatedOpacity(
          opacity: controller.isLoading.value ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                'Informasi Perorangan',
                [
                  _buildInfoRow(
                      'Nama Lengkap',
                      controller.selectedPelanggan.value!.namaLengkap ?? '-',
                      fontSizeBody),
                  _buildInfoRow(
                      'NIK',
                      controller.selectedPelanggan.value!.nik ?? '-',
                      fontSizeBody),
                  _buildInfoRow(
                      'No Telepon',
                      controller.selectedPelanggan.value!.noTelepon ?? '-',
                      fontSizeBody),
                  _buildInfoRow(
                      'Alamat',
                      controller.selectedPelanggan.value!.alamat ?? '-',
                      fontSizeBody),
                ],
                fontSizeTitle,
                fontSizeBody,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Informasi Akun',
                controller.selectedPelanggan.value!.akun == null
                    ? [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Tidak ada akun terkait',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: fontSizeBody)),
                        ),
                      ]
                    : [
                        _buildInfoRow(
                            'Email',
                            controller.selectedPelanggan.value!.akun!.email ??
                                '-',
                            fontSizeBody),
                        _buildInfoRow(
                            'Role',
                            controller.selectedPelanggan.value!.akun!.role ??
                                '-',
                            fontSizeBody),
                        _buildInfoRow(
                            'Status Aktif',
                            (controller.selectedPelanggan.value!.akun!
                                        .statusAktif ??
                                    false)
                                ? 'Aktif'
                                : 'Tidak Aktif',
                            fontSizeBody),
                      ],
                fontSizeTitle,
                fontSizeBody,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Informasi Perusahaan',
                controller.selectedPelanggan.value!.perusahaan == null
                    ? [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Tidak ada perusahaan terkait',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: fontSizeBody)),
                        ),
                      ]
                    : [
                        _buildInfoRow(
                            'Nama Perusahaan',
                            controller.selectedPelanggan.value!.perusahaan!
                                    .namaPerusahaan ??
                                '-',
                            fontSizeBody),
                        _buildInfoRow(
                            'Alamat Perusahaan',
                            controller.selectedPelanggan.value!.perusahaan!
                                    .alamatPerusahaan ??
                                '-',
                            fontSizeBody),
                        _buildInfoRow(
                            'Email Perusahaan',
                            controller.selectedPelanggan.value!.perusahaan!
                                    .emailPerusahaan ??
                                '-',
                            fontSizeBody),
                      ],
                fontSizeTitle,
                fontSizeBody,
              ),
            ],
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

  Widget _buildInfoCard(String title, List<Widget> children,
      double fontSizeTitle, double fontSizeBody) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.white, Colors.grey[50]!],
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
              style: TextStyle(fontSize: fontSize, color: Colors.grey[900]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    final pelanggan = controller.selectedPelanggan.value;
    if (pelanggan == null) {
      Get.snackbar('Error', 'Data pelanggan belum dimuat',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redFlame,
          colorText: AppColors.white);
      return;
    }
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        backgroundColor: AppColors.white,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(width: 8),
              Text('Konfirmasi Hapus',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue)),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus pelanggan "${pelanggan.namaLengkap}"?',
              style: const TextStyle(
                  fontSize: 16, color: Colors.black87, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed:
                        controller.isLoading.value ? null : () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: AppColors.secondary.withOpacity(0.5)),
                      ),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            await controller
                                .deletePelanggan(widget.idPelanggan);
                            if (controller.errorMessage.isEmpty) {
                              Get.offNamed(AppRoutes.dataPelanggan);
                              Get.snackbar(
                                  'Sukses', 'Pelanggan berhasil dihapus',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.green,
                                  colorText: AppColors.white);
                            }
                            Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redFlame,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.white, strokeWidth: 2),
                          )
                        : const Text('Hapus',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ],
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}
