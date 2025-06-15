import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/tabung_controller.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DetailTabungScreen extends StatelessWidget {
  final GlobalKey _qrKey = GlobalKey();
  final int idTabung;

  DetailTabungScreen({super.key, required this.idTabung});

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
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
              title: const Text('Izin Penyimpanan Diperlukan'),
              content: const Text(
                  'Aplikasi membutuhkan izin penyimpanan untuk menyimpan QR Code ke PDF. Izinkan akses?'),
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
            Get.snackbar('Izin Ditolak',
                'Izin penyimpanan diperlukan untuk menyimpan QR Code.',
                backgroundColor: AppColors.orangeWarning,
                colorText: AppColors.white,
                snackPosition: SnackPosition.TOP);
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
            Get.snackbar('Izin Ditolak',
                'Izin penyimpanan diperlukan untuk menyimpan QR Code.',
                backgroundColor: AppColors.orangeWarning,
                colorText: AppColors.white,
                snackPosition: SnackPosition.TOP);
            return false;
          }
        }
      } catch (e) {
        Get.snackbar(
            'Error', 'Gagal memeriksa informasi perangkat: ${e.toString()}',
            backgroundColor: AppColors.redFlame,
            colorText: AppColors.white,
            snackPosition: SnackPosition.TOP);
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
            'Error', 'Gagal menangkap QR Code: Render boundary tidak tersedia',
            backgroundColor: AppColors.redFlame,
            colorText: AppColors.white,
            snackPosition: SnackPosition.TOP);
        return null;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menangkap QR Code: ${e.toString()}',
          backgroundColor: AppColors.redFlame,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP);
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
      Get.snackbar('Sukses', 'PDF berhasil disimpan di: $filePath',
          backgroundColor: AppColors.greenSuccess,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar(
          'Error', 'Gagal menyimpan QR Code sebagai PDF: ${e.toString()}',
          backgroundColor: AppColors.redFlame,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _refreshGallery(String filePath) async {
    try {
      await const MethodChannel('com.example.laris_jaya_gas/gallery')
          .invokeMethod('scanFile', {'path': 'file://$filePath'});
    } catch (e) {
      Get.snackbar('Info',
          'File disimpan, tetapi pemindaian galeri gagal. Periksa di $filePath.',
          backgroundColor: AppColors.primaryBlue,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  void _showDeleteDialog(Tabung tabung, TabungController controller) {
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
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: AppColors.secondary.withOpacity(0.5)),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: controller.isLoadingTabung.value
                        ? null
                        : () {
                            if (tabung.idTabung != null) {
                              controller.deleteTabung(tabung.idTabung!);
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redFlame,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ],
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _navigateToEdit(Tabung? tabung) {
    if (tabung?.idTabung != null) {
      Get.toNamed('/administrator/edit-tabung', arguments: tabung!.idTabung);
    } else {
      Get.snackbar('Error', 'ID Tabung tidak valid',
          backgroundColor: AppColors.redFlame,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TabungController controller = Get.find<TabungController>();
    final double padding = AppSizes.padding;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTabungById(idTabung);
    });

    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Detail Tabung',
            style: TextStyle(color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            final tabung = controller.selectedTabung.value;
            if (tabung == null) return const SizedBox.shrink();
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.white),
                  onPressed: () => _navigateToEdit(tabung),
                  tooltip: 'Edit Tabung',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.white),
                  onPressed: () => _showDeleteDialog(tabung, controller),
                  tooltip: 'Hapus Tabung',
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue));
        } else if (controller.errorMessageDetail.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessageDetail.value,
                  style:
                      const TextStyle(color: AppColors.redFlame, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchTabungById(idTabung),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.cardRadius)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child:
                      const Text('Coba Lagi', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        } else if (controller.selectedTabung.value == null) {
          return const Center(
              child: Text('Tabung tidak ditemukan',
                  style: TextStyle(fontSize: 16, color: Colors.grey)));
        }

        final Tabung tabung = controller.selectedTabung.value!;
        final qrSize = MediaQuery.of(context).size.width * 0.5;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tabung.kodeTabung ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.category,
                              color: AppColors.primaryBlue,
                              size: AppSizes.iconSize),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Jenis: ${tabung.jenisTabung?.namaJenis ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color:
                                tabung.statusTabung?.statusTabung == 'Tersedia'
                                    ? AppColors.greenSuccess
                                    : AppColors.redFlame,
                            size: AppSizes.iconSize,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Status: ${tabung.statusTabung?.statusTabung ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    child: Column(
                      children: [
                        RepaintBoundary(
                          key: _qrKey,
                          child: QrImageView(
                            data: tabung.qrCode ?? tabung.kodeTabung ?? '',
                            version: QrVersions.auto,
                            size: qrSize,
                            backgroundColor: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'QR Code untuk ${tabung.kodeTabung ?? 'Unknown'}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => ElevatedButton.icon(
                              onPressed: controller.isLoadingTabung.value ||
                                      tabung.kodeTabung == null
                                  ? null
                                  : () =>
                                      _downloadQRCodeAsPDF(tabung.kodeTabung!),
                              icon: controller.isLoadingTabung.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.download),
                              label: Text(
                                controller.isLoadingTabung.value
                                    ? 'Menyimpan...'
                                    : 'Unduh QR Code sebagai PDF',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.cardRadius)),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
