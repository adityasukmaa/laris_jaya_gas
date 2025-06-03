import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/tabung_model.dart';
import '../../services/api_service.dart';

class QRScanScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onTabungSelected;
  final List<Map<String, dynamic>> selectedTabungs;

  const QRScanScreen({
    super.key,
    required this.onTabungSelected,
    required this.selectedTabungs,
  });

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final MobileScannerController scannerController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      apiService = ApiService(prefs);
    });
  }

  @override
  void dispose() {
    scannerController.stop();
    scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    final String? kodeTabung = barcodeCapture.barcodes.firstOrNull?.rawValue;
    if (kodeTabung != null) {
      final tabung = await apiService.getTabung(kodeTabung);
      if (tabung == null) {
        Get.snackbar('Error', 'Kode tabung tidak ditemukan!',
            backgroundColor: Colors.red, colorText: Colors.white);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
        return;
      }

      if (tabung.statusTabung?.statusTabung == 'dipinjam') {
        Get.snackbar(
            'Peringatan', 'Tabung ${tabung.kodeTabung} sedang dipinjam!',
            backgroundColor: Colors.orange, colorText: Colors.white);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
        return;
      }

      if (widget.selectedTabungs
          .any((t) => t['tabung'].kodeTabung == kodeTabung)) {
        Get.snackbar('Peringatan', 'Tabung ${tabung.kodeTabung} sudah dipilih!',
            backgroundColor: Colors.orange, colorText: Colors.white);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
        return;
      }

      await _showInitialTransactionDialog(tabung);
    } else {
      Get.snackbar('Error', 'Tidak ada QR code yang terdeteksi!',
          backgroundColor: Colors.red, colorText: Colors.white);
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    }
  }

  Future<void> _showInitialTransactionDialog(Tabung tabung) async {
    String? selectedJenisTransaksi;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pilih Jenis Transaksi untuk ${tabung.kodeTabung}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedJenisTransaksi,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: 'Jenis Transaksi',
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'peminjaman', child: Text('Peminjaman')),
                      DropdownMenuItem(
                          value: 'isi ulang', child: Text('Isi Ulang')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedJenisTransaksi = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Jenis Transaksi harus dipilih' : null,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedJenisTransaksi != null) {
                      widget.onTabungSelected({
                        'tabung': tabung,
                        'jenisTransaksi': selectedJenisTransaksi,
                      });
                      Get.back();
                    } else {
                      Get.snackbar('Error', 'Harap pilih jenis transaksi!',
                          backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  child: Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );

    await scannerController.stop();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                await scannerController.stop();
                Get.back();
              },
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.flash_on, color: Colors.white),
              onPressed: () => scannerController.toggleTorch(),
            ),
          ),
        ],
      ),
    );
  }
}
