// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../models/tabung_model.dart';
// import '../../services/api_service.dart';

// class QRScanScreen extends StatefulWidget {
//   final Function(Map<String, dynamic>) onTabungSelected;
//   final List<Map<String, dynamic>> selectedTabungs;

//   const QRScanScreen({
//     super.key,
//     required this.onTabungSelected,
//     required this.selectedTabungs,
//   });

//   @override
//   State<QRScanScreen> createState() => _QRScanScreenState();
// }

// class _QRScanScreenState extends State<QRScanScreen> {
//   final MobileScannerController scannerController = MobileScannerController(
//     formats: [BarcodeFormat.qrCode],
//     detectionSpeed: DetectionSpeed.normal,
//     facing: CameraFacing.back,
//     torchEnabled: false,
//   );
//   late ApiService apiService;
//   bool isProcessing = false;

//   @override
//   void initState() {
//     super.initState();
//     SharedPreferences.getInstance().then((prefs) {
//       apiService = ApiService(prefs);
//     });
//   }

//   @override
//   void dispose() {
//     scannerController.stop();
//     scannerController.dispose();
//     super.dispose();
//   }

//   void _onDetect(BarcodeCapture barcodeCapture) async {
//     if (isProcessing) return;
//     isProcessing = true;

//     final String? kodeTabung = barcodeCapture.barcodes.isNotEmpty
//         ? barcodeCapture.barcodes.first.rawValue
//         : null;
//     if (kodeTabung != null) {
//       try {
//         final tabung = await apiService.getTabungByKode(kodeTabung);
//         if (tabung == null) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Get.snackbar(
//               'Error',
//               'Kode tabung tidak ditemukan!',
//               backgroundColor: Colors.red,
//               colorText: Colors.white,
//               snackPosition: SnackPosition.TOP,
//             );
//           });
//           await Future.delayed(const Duration(milliseconds: 500));
//           Get.back();
//           return;
//         }

//         if (tabung.statusTabung?.statusTabung.toLowerCase() == 'dipinjam') {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Get.snackbar(
//               'Peringatan',
//               'Tabung ${tabung.kodeTabung} sedang dipinjam!',
//               backgroundColor: Colors.orange,
//               colorText: Colors.white,
//               snackPosition: SnackPosition.TOP,
//             );
//           });
//           await Future.delayed(const Duration(milliseconds: 500));
//           Get.back();
//           return;
//         }

//         if (widget.selectedTabungs
//             .any((t) => t['tabung'].kodeTabung == kodeTabung)) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Get.snackbar(
//               'Peringatan',
//               'Tabung ${tabung.kodeTabung} sudah dipilih!',
//               backgroundColor: Colors.orange,
//               colorText: Colors.white,
//               snackPosition: SnackPosition.TOP,
//             );
//           });
//           await Future.delayed(const Duration(milliseconds: 500));
//           Get.back();
//           return;
//         }

//         await _showInitialTransactionDialog(tabung);
//       } catch (e) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Get.snackbar(
//             'Error',
//             'Gagal memproses tabung: $e',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         });
//         await Future.delayed(const Duration(milliseconds: 500));
//         Get.back();
//       }
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Get.snackbar(
//           'Error',
//           'Tidak ada QR code yang terdeteksi!',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//       });
//       await Future.delayed(const Duration(milliseconds: 500));
//       Get.back();
//     }

//     isProcessing = false;
//   }

//   Future<void> _showInitialTransactionDialog(Tabung tabung) async {
//     String? selectedJenisTransaksi;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Pilih Jenis Transaksi untuk ${tabung.kodeTabung}'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   DropdownButtonFormField<String>(
//                     value: selectedJenisTransaksi,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       labelText: 'Jenis Transaksi',
//                     ),
//                     items: const [
//                       DropdownMenuItem(
//                         value: 'peminjaman',
//                         child: Text('Peminjaman'),
//                       ),
//                       DropdownMenuItem(
//                         value: 'isi ulang',
//                         child: Text('Isi Ulang'),
//                       ),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         selectedJenisTransaksi = value;
//                       });
//                     },
//                     validator: (value) =>
//                         value == null ? 'Jenis Transaksi harus dipilih' : null,
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Get.back(),
//                   child: const Text('Batal'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (selectedJenisTransaksi != null) {
//                       widget.onTabungSelected({
//                         'tabung': tabung,
//                         'jenisTransaksi': selectedJenisTransaksi,
//                       });
//                       Get.back();
//                     } else {
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         Get.snackbar(
//                           'Error',
//                           'Harap pilih jenis transaksi!',
//                           backgroundColor: Colors.red,
//                           colorText: Colors.white,
//                           snackPosition: SnackPosition.TOP,
//                         );
//                       });
//                     }
//                   },
//                   child: const Text('Pilih'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     await scannerController.stop();
//     Get.back();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           MobileScanner(
//             controller: scannerController,
//             onDetect: _onDetect,
//           ),
//           Center(
//             child: Container(
//               height: 250,
//               width: 250,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.white, width: 2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 50,
//             left: 16,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () async {
//                 await scannerController.stop();
//                 Get.back();
//               },
//             ),
//           ),
//           Positioned(
//             top: 50,
//             right: 16,
//             child: IconButton(
//               icon: const Icon(Icons.flash_on, color: Colors.white),
//               onPressed: () => scannerController.toggleTorch(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
