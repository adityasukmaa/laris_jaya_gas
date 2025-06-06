// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:laris_jaya_gas/models/tabung_model.dart';
// import 'package:laris_jaya_gas/utils/constants.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'dart:convert';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import '../../utils/dummy_data.dart';

// class DetailTabungScreen extends StatelessWidget {
//   final Color primaryBlue = const Color(0xFF0172B2);

//   const DetailTabungScreen({super.key});

//   Future<void> _downloadQRCode(String kodeTabung, String qrCodeBase64) async {
//     // Validasi apakah qrCodeBase64 kosong
//     if (qrCodeBase64.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Tidak ada gambar QR Code yang bisa diunduh.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     // Minta izin penyimpanan untuk Android
//     var permissionStatus = await Permission.storage.status;

//     if (!permissionStatus.isGranted) {
//       permissionStatus = await Permission.storage.request();

//       if (permissionStatus.isPermanentlyDenied) {
//         Get.snackbar(
//           'Izin Ditolak',
//           'Izin penyimpanan ditolak secara permanen. Silakan aktifkan di pengaturan.',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           mainButton: TextButton(
//             onPressed: () => openAppSettings(),
//             child: const Text('Buka Pengaturan'),
//           ),
//         );
//         return;
//       } else if (!permissionStatus.isGranted) {
//         Get.snackbar(
//           'Izin Ditolak',
//           'Izin penyimpanan diperlukan untuk menyimpan QR Code.',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//         return;
//       }
//     }

//     if (permissionStatus.isGranted) {
//       try {
//         // Dekode base64 menjadi data gambar
//         final qrCodeData = base64Decode(qrCodeBase64);

//         // Simpan gambar ke galeri menggunakan image_gallery_saver
//         final result = await ImageGallerySaver.saveImage(
//           Uint8List.fromList(qrCodeData),
//           quality: 100,
//           name: '${kodeTabung}_qrcode_${DateTime.now().millisecondsSinceEpoch}',
//         );

//         if (result['isSuccess']) {
//           Get.snackbar(
//             'Sukses',
//             'QR Code berhasil disimpan di galeri.',
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//           );
//         } else {
//           Get.snackbar(
//             'Error',
//             'Gagal menyimpan QR Code: ${result['errorMessage'] ?? 'Unknown error'}',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//         }
//       } catch (e) {
//         Get.snackbar(
//           'Error',
//           'Gagal menyimpan QR Code: ${e.toString()}',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String? kodeTabung = Get.arguments as String?;
//     final tabung = DummyData.tabungList.firstWhere(
//       (tabung) => tabung.kodeTabung == kodeTabung,
//       orElse: () =>
//           Tabung(kodeTabung: '', jenisTabung: '', status: '', qrCode: ''),
//     );

//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double paddingVertical = screenHeight * 0.02;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: primaryBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         title:
//             const Text('Detail Tabung', style: TextStyle(color: Colors.white)),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding:
//               EdgeInsets.symmetric(vertical: paddingVertical, horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//               Text(
//                 'Kode Tabung: ${tabung.kodeTabung}',
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Jenis Tabung: ${tabung.jenisTabung}',
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Status Tabung: ${tabung.status}',
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 32),
//               Center(
//                 child: Column(
//                   children: [
//                     tabung.qrCode.isNotEmpty
//                         ? QrImageView(
//                             data: tabung.kodeTabung,
//                             version: QrVersions.auto,
//                             size: 200.0,
//                           )
//                         : const Text('QR Code tidak tersedia'),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: tabung.qrCode.isNotEmpty
//                           ? () =>
//                               _downloadQRCode(tabung.kodeTabung, tabung.qrCode)
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.secondary,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12, horizontal: 24),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(0)),
//                       ),
//                       child: const Text(
//                         'Unduh QR Code',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
