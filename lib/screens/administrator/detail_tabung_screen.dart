import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/status_tabung_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;
import '../../utils/dummy_data.dart';

class DetailTabungScreen extends StatelessWidget {
  final Color primaryBlue = const Color(0xFF0172B2);
  final GlobalKey _qrKey = GlobalKey(); // Key untuk menangkap QR code

  DetailTabungScreen({super.key, required String kodeTabung});

  Future<bool> _checkAndRequestPermission() async {
    Permission permission;
    PermissionStatus status;

    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        int sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 30) {
          permission = Permission.manageExternalStorage;
        } else {
          permission = Permission.storage;
        }

        status = await permission.status;

        if (!status.isGranted) {
          bool? shouldProceed = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Izin Penyimpanan Diperlukan'),
              content: const Text(
                  'Aplikasi membutuhkan izin penyimpanan untuk menyimpan QR Code ke PDF. Izinkan akses?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Izinkan'),
                ),
              ],
            ),
          );

          if (shouldProceed != true) {
            Get.snackbar(
              'Izin Ditolak',
              'Izin penyimpanan diperlukan untuk menyimpan QR Code.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return false;
          }

          status = await permission.request();

          if (status.isPermanentlyDenied) {
            Get.snackbar(
              'Izin Ditolak',
              'Izin penyimpanan ditolak secara permanen. Silakan aktifkan di pengaturan.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Buka Pengaturan'),
              ),
            );
            return false;
          } else if (!status.isGranted) {
            Get.snackbar(
              'Izin Ditolak',
              'Izin penyimpanan diperlukan untuk menyimpan QR Code.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return false;
          }
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal memeriksa informasi perangkat: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menangkap QR Code: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> _downloadQRCodeAsPDF(String kodeTabung) async {
    bool hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) return;

    final qrImageData = await _captureQrCode();
    if (qrImageData == null) {
      Get.snackbar(
        'Error',
        'Gagal menangkap gambar QR Code.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('Detail Tabung - $kodeTabung',
                    style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Text('Kode Tabung: $kodeTabung',
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Image(pw.MemoryImage(qrImageData), width: 150, height: 150),
                pw.Text('QR Code untuk Tabung $kodeTabung',
                    style: pw.TextStyle(fontSize: 12)),
              ],
            );
          },
        ),
      );

      // Simpan PDF ke direktori publik
      String documentsDirPath = '/storage/emulated/0/Documents/LarisJayaGas';
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
        'PDF berhasil disimpan di galeri: $filePath',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan QR Code sebagai PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _refreshGallery(String filePath) async {
    final uri = Uri.parse('file://$filePath');
    final platform = MethodChannel('com.example.laris_jaya_gas/gallery');
    try {
      await platform.invokeMethod('scanFile', {'path': uri.toString()});
    } catch (e) {
      Get.snackbar(
        'Info',
        'File disimpan, tetapi pemindaian galeri gagal. Periksa secara manual di $filePath.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? kodeTabung = Get.arguments as String?;
    final tabung = DummyData.tabungList.firstWhere(
      (tabung) => tabung.kodeTabung == kodeTabung,
      orElse: () => Tabung(
        kodeTabung: '',
        idJenisTabung: '',
        idStatusTabung: '',
        jenisTabung: JenisTabung(
            idJenisTabung: '', kodeJenis: '', namaJenis: '', harga: 0.0),
        statusTabung: StatusTabung(idStatusTabung: '', statusTabung: ''),
      ),
    );

    // Cek jika tabung tidak ditemukan
    if (tabung.kodeTabung.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text('Detail Tabung',
              style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text(
            'Tabung tidak ditemukan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingVertical = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title:
            const Text('Detail Tabung', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: paddingVertical, horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Kode Tabung: ${tabung.kodeTabung}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Jenis Tabung: ${tabung.jenisTabung?.namaJenis ?? 'Unknown'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Status Tabung: ${tabung.statusTabung?.statusTabung ?? 'Unknown'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: _qrKey,
                      child: QrImageView(
                        data: tabung.kodeTabung,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _downloadQRCodeAsPDF(tabung.kodeTabung),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Unduh QR Code sebagai PDF',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
