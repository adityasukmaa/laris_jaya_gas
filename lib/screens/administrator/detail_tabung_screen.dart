import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DetailTabungScreen extends StatefulWidget {
  final int idTabung;
  const DetailTabungScreen({super.key, required this.idTabung});

  @override
  State<DetailTabungScreen> createState() => _DetailTabungScreenState();
}

class _DetailTabungScreenState extends State<DetailTabungScreen>
    with SingleTickerProviderStateMixin {
  final TabungController controller = Get.find<TabungController>();
  final GlobalKey _qrKey = GlobalKey();
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
      controller.fetchTabungById(widget.idTabung);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.selectedTabung.value = null; // Reset selectedTabung
    super.dispose();
  }

  Future<bool> _checkAndRequestPermission() async {
    Permission permission;
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        permission = androidInfo.version.sdkInt >= 30
            ? Permission.manageExternalStorage
            : Permission.storage;
        var status = await permission.status;

        if (!status.isGranted) {
          final shouldProceed = await Get.dialog<bool>(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              title: const Text('Izin Penyimpanan Diperlukan'),
              content: const Text(
                'Aplikasi membutuhkan izin penyimpanan untuk menyimpan QR Code ke PDF. Izinkan akses?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Tidak',
                      style: TextStyle(color: AppColors.redFlame)),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Izinkan',
                      style: TextStyle(color: AppColors.primaryBlue)),
                ),
              ],
            ),
          );

          if (shouldProceed != true) {
            Get.snackbar(
              'Izin Ditolak',
              'Izin penyimpanan diperlukan untuk menyimpan QR Code.',
              backgroundColor: AppColors.orangeWarning,
              colorText: AppColors.white,
              snackPosition: SnackPosition.TOP,
            );
            return false;
          }

          status = await permission.request();
          if (status.isPermanentlyDenied) {
            Get.snackbar(
              'Izin Ditolak',
              'Izin penyimpanan ditolak secara permanen. Silakan aktifkan di pengaturan.',
              backgroundColor: AppColors.orangeWarning,
              colorText: AppColors.white,
              snackPosition: SnackPosition.TOP,
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Buka Pengaturan',
                    style: TextStyle(color: AppColors.white)),
              ),
            );
            return false;
          } else if (!status.isGranted) {
            Get.snackbar(
              'Izin Ditolak',
              'Izin penyimpanan diperlukan untuk menyimpan QR Code.',
              backgroundColor: AppColors.orangeWarning,
              colorText: AppColors.white,
              snackPosition: SnackPosition.TOP,
            );
            return false;
          }
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal memeriksa informasi perangkat: ${e.toString()}',
          backgroundColor: AppColors.redFlame,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    }
    return true;
  }

  Future<Uint8List?> _captureQrCode() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.snackbar(
          'Error',
          'Gagal menangkap QR Code: Render boundary tidak tersedia',
          backgroundColor: AppColors.redFlame,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
        return null;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menangkap QR Code: ${e.toString()}',
        backgroundColor: AppColors.redFlame,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  Future<void> _downloadQRCodeAsPDF(String kodeTabung) async {
    if (!await _checkAndRequestPermission()) return;

    final qrImageData = await _captureQrCode();
    if (qrImageData == null) return;

    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Detail Tabung - $kodeTabung',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Kode Tabung: $kodeTabung',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Image(pw.MemoryImage(qrImageData), width: 150, height: 150),
              pw.Text('QR Code untuk Tabung $kodeTabung',
                  style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );

      final documentsDirPath = '/storage/emulated/0/Documents/LarisJayaGas';
      final documentsDir = Directory(documentsDirPath);
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      final fileName =
          '${kodeTabung}_qrcode_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = path.join(documentsDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      await _refreshGallery(filePath);
      Get.snackbar(
        'Sukses',
        'PDF berhasil disimpan di: $filePath',
        backgroundColor: AppColors.greenSuccess,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan QR Code sebagai PDF: ${e.toString()}',
        backgroundColor: AppColors.redFlame,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _refreshGallery(String filePath) async {
    try {
      await const MethodChannel('com.example.laris_jaya_gas/gallery')
          .invokeMethod('scanFile', {'path': 'file://$filePath'});
    } catch (e) {
      Get.snackbar(
        'Info',
        'File disimpan, tetapi pemindaian galeri gagal. Periksa di $filePath.',
        backgroundColor: AppColors.primaryBlue,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    final tabung = controller.selectedTabung.value;
    if (tabung == null) {
      Get.snackbar(
        'Error',
        'Data tabung belum dimuat',
        backgroundColor: AppColors.redFlame,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        backgroundColor: AppColors.white,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Konfirmasi Hapus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus tabung "${tabung.kodeTabung}"?',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
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
                    onPressed: controller.isLoadingTabung.value
                        ? null
                        : () => Get.back(),
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
                    child: const Text(
                      'Batal',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: controller.isLoadingTabung.value
                        ? null
                        : () async {
                            await controller.deleteTabung(tabung.idTabung!);
                            if (controller.errorMessageTabung.isEmpty) {
                              Get.offNamed('/administrator/stok-tabung');
                              Get.snackbar(
                                'Sukses',
                                'Tabung berhasil dihapus',
                                backgroundColor: AppColors.greenSuccess,
                                colorText: AppColors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                            }
                            Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redFlame,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isLoadingTabung.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Hapus',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                  ),
                ],
              )),
        ],
      ),
      barrierDismissible: false,
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
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
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

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final padding = isLargeScreen ? 24.0 : AppSizes.padding;
    final fontSizeTitle = isLargeScreen ? 20.0 : 18.0;
    final fontSizeBody = isLargeScreen ? 16.0 : 14.0;

    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Detail Tabung',
            style: TextStyle(color: AppColors.white, fontSize: 20)),
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          Obx(() {
            final tabung = controller.selectedTabung.value;
            if (tabung == null) return const SizedBox.shrink();
            return Row(
              children: [
                _buildAppBarActionButton(
                  icon: Icons.edit,
                  color: AppColors.white,
                  tooltip: 'Edit Tabung',
                  onPressed: () {
                    if (tabung.idTabung != null) {
                      Get.toNamed('/administrator/edit-tabung',
                          arguments: tabung.idTabung);
                    } else {
                      Get.snackbar(
                        'Error',
                        'ID Tabung tidak valid',
                        backgroundColor: AppColors.redFlame,
                        colorText: AppColors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                ),
                _buildAppBarActionButton(
                  icon: Icons.delete,
                  color: AppColors.white,
                  tooltip: 'Hapus Tabung',
                  onPressed: () => _showDeleteConfirmationDialog(),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() => _buildBody(padding, fontSizeTitle, fontSizeBody)),
    );
  }

  Widget _buildBody(double padding, double fontSizeTitle, double fontSizeBody) {
    if (controller.isLoadingDetail.value) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (controller.errorMessageDetail.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.errorMessageDetail.value,
              style:
                  TextStyle(color: AppColors.redFlame, fontSize: fontSizeBody),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchTabungById(widget.idTabung),
              style: _buttonStyle(),
              child: Text('Coba Lagi',
                  style: TextStyle(
                      color: AppColors.white, fontSize: fontSizeBody)),
            ),
          ],
        ),
      );
    }
    if (controller.selectedTabung.value == null) {
      return Center(
        child: Text(
          'Data tabung tidak ditemukan',
          style: TextStyle(fontSize: fontSizeBody, color: Colors.grey[600]),
        ),
      );
    }

    final tabung = controller.selectedTabung.value!;
    final qrSize = MediaQuery.of(context).size.width * 0.5;

    return RefreshIndicator(
      onRefresh: () => controller.fetchTabungById(widget.idTabung),
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(padding),
        child: AnimatedOpacity(
          opacity: controller.isLoadingDetail.value ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                'Informasi Tabung',
                [
                  _buildInfoRow(
                      'Kode Tabung', tabung.kodeTabung ?? '-', fontSizeBody),
                  _buildInfoRow('Jenis', tabung.jenisTabung?.namaJenis ?? '-',
                      fontSizeBody),
                  _buildInfoRow('Status',
                      tabung.statusTabung?.statusTabung ?? '-', fontSizeBody),
                ],
                fontSizeTitle,
                fontSizeBody,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'QR Code',
                [
                  Center(
                    child: RepaintBoundary(
                      key: _qrKey,
                      child: QrImageView(
                        data: tabung.qrCode ?? tabung.kodeTabung ?? '',
                        version: QrVersions.auto,
                        size: qrSize,
                        backgroundColor: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'QR Code untuk ${tabung.kodeTabung ?? '-'}',
                      style: TextStyle(
                          fontSize: fontSizeBody, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Obx(() => ElevatedButton.icon(
                          onPressed: controller.isLoadingTabung.value ||
                                  tabung.kodeTabung == null
                              ? null
                              : () => _downloadQRCodeAsPDF(tabung.kodeTabung!),
                          icon: controller.isLoadingTabung.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download,
                                  color: AppColors.white),
                          label: Text(
                            controller.isLoadingTabung.value
                                ? 'Menyimpan...'
                                : 'Unduh QR Code sebagai PDF',
                            style: TextStyle(fontSize: fontSizeBody),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.cardRadius),
                            ),
                          ),
                        )),
                  ),
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
}
