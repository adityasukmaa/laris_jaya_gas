import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

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

  @override
  void dispose() {
    scannerController.stop();
    scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    final String? kodeTabung = barcodeCapture.barcodes.firstOrNull?.rawValue;
    print('QR Code detected: $kodeTabung'); // Log deteksi QR code

    if (kodeTabung != null) {
      final tabung = DummyData.tabungList.firstWhere(
        (t) => t.kodeTabung == kodeTabung,
        orElse: () => Tabung(
          idTabung: '',
          kodeTabung: '',
          idJenisTabung: '',
          idStatusTabung: '',
        ),
      );

      print('Tabung found: ${tabung.kodeTabung}'); // Log tabung ditemukan

      if (tabung.idTabung!.isEmpty) {
        print(
            'Tabung not found in DummyData for kode: $kodeTabung'); // Log debugging
        Get.snackbar(
          'Error',
          'Kode tabung tidak ditemukan!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await Future.delayed(
            const Duration(milliseconds: 500)); // Tunggu render
        Get.back();
        return;
      }

      if (tabung.statusTabung?.statusTabung == 'dipinjam') {
        print('Tabung $kodeTabung is currently borrowed'); // Log debugging
        Get.snackbar(
          'Peringatan',
          'Tabung ${tabung.kodeTabung} sedang dipinjam dan tidak dapat ditambahkan!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await Future.delayed(
            const Duration(milliseconds: 500)); // Tunggu render
        Get.back();
        return;
      }

      if (widget.selectedTabungs
          .any((t) => t['tabung'].kodeTabung == kodeTabung)) {
        print('Tabung $kodeTabung already selected'); // Log debugging
        Get.snackbar(
          'Peringatan',
          'Tabung ${tabung.kodeTabung} sudah dipilih sebelumnya!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await Future.delayed(
            const Duration(milliseconds: 500)); // Tunggu render
        Get.back();
        return;
      }

      print(
          'Showing transaction dialog for tabung: ${tabung.kodeTabung}'); // Log sebelum dialog
      await _showInitialTransactionDialog(tabung);
    } else {
      print('No QR code detected'); // Log jika QR code tidak terdeteksi
      Get.snackbar(
        'Error',
        'Tidak ada QR code yang terdeteksi!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      await Future.delayed(const Duration(milliseconds: 500)); // Tunggu render
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
                        value: 'peminjaman',
                        child: const Text('Peminjaman'),
                      ),
                      DropdownMenuItem(
                        value: 'isi ulang',
                        child: const Text('Isi Ulang'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedJenisTransaksi = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Jenis Transaksi harus dipilih';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('Dialog canceled'); // Log jika dialog dibatalkan
                    Get.back();
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedJenisTransaksi != null) {
                      print(
                          'Tabung selected: ${tabung.kodeTabung} with type $selectedJenisTransaksi'); // Log tabung dipilih
                      widget.onTabungSelected({
                        'tabung': tabung,
                        'jenisTransaksi': selectedJenisTransaksi,
                      });
                      Get.back();
                    } else {
                      print(
                          'Jenis Transaksi not selected'); // Log jika jenis transaksi tidak dipilih
                      Get.snackbar(
                        'Error',
                        'Harap pilih jenis transaksi!',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                  child: const Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );

    print('Stopping scanner after dialog'); // Log setelah dialog
    await scannerController.stop();
    print('Navigating back to TambahTransaksiScreen'); // Log navigasi kembali
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
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                print('Back button pressed'); // Log tombol kembali
                await scannerController.stop();
                Get.back();
              },
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white),
              onPressed: () {
                print('Toggling torch'); // Log tombol obor
                scannerController.toggleTorch();
              },
            ),
          ),
        ],
      ),
    );
  }
}
