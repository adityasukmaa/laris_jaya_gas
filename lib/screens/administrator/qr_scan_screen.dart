import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Mengubah menjadi StatefulWidget untuk mengelola state pemrosesan.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  // Mengambil instance controller yang sudah ada menggunakan Get.find()
  final TransaksiController transaksiController =
      Get.find<TransaksiController>();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Kode QR Tabung'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            color: Colors.white,
            iconSize: 28.0,
            tooltip: 'Senter',
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined),
            color: Colors.white,
            iconSize: 28.0,
            tooltip: 'Ganti Kamera',
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              // Mencegah deteksi berulang saat satu kode sedang diproses
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? scannedCode = barcodes.first.rawValue;

                if (scannedCode != null && scannedCode.isNotEmpty) {
                  setState(() {
                    _isProcessing = true;
                  });

                  // Memanggil controller untuk validasi.
                  // Controller akan otomatis menampilkan snackbar jika ada error.
                  final tabung = await transaksiController
                      .validateAndGetTabung(scannedCode);

                  // Jika validasi BERHASIL (tabung tidak null)
                  if (tabung != null) {
                    if (mounted) {
                      // Kembali ke halaman form dengan membawa hasil kode yang valid
                      Get.back(result: scannedCode);
                    }
                  } else {
                    // Jika validasi GAGAL (tabung null), snackbar sudah ditampilkan oleh controller.
                    // Beri jeda agar pengguna bisa membaca snackbar, lalu aktifkan kembali scanner.
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) {
                      setState(() {
                        _isProcessing = false;
                      });
                    }
                  }
                }
              }
            },
          ),
          // Overlay untuk area scan
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade400, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Menampilkan loading indicator saat memvalidasi
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Memvalidasi Kode...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
