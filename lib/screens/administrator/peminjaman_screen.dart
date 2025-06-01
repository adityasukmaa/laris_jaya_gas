// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:laris_jaya_gas/controllers/auth_controller.dart';
// import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
// import 'package:laris_jaya_gas/utils/constants.dart';
// import 'package:laris_jaya_gas/utils/dummy_data.dart';
// import 'package:laris_jaya_gas/models/transaksi_model.dart';
// import 'package:laris_jaya_gas/models/detail_transaksi_model.dart';

// class AdministratorPeminjamanScreen extends StatelessWidget {
//   AdministratorPeminjamanScreen({super.key});

//   final TransaksiController transaksiController =
//       Get.find<TransaksiController>();
//   final AuthController authController = Get.find<AuthController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Kelola Peminjaman & Isi Ulang'),
//         backgroundColor: AppColors.primaryBlue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               'Daftar Transaksi Tertunda',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: Obx(() => ListView.builder(
//                     itemCount: transaksiController.transaksiList.length,
//                     itemBuilder: (context, index) {
//                       final transaksi =
//                           transaksiController.transaksiList[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: ListTile(
//                           title: Text('Transaksi #${transaksi.idTransaksi}'),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                   'Pelanggan: ${transaksi.akun?.email ?? "Tidak diketahui"}'),
//                               Text(
//                                   'Jenis: ${transaksi.detailTransaksis.isNotEmpty ? (transaksi.detailTransaksis[0].idJenisTransaksi == "JTR001" ? "Peminjaman" : "Isi Ulang") : "Tidak diketahui"}'),
//                               Text(
//                                   'Jumlah: ${transaksi.detailTransaksis.length} tabung'),
//                               Text(
//                                   'Total: ${transaksi.detailTransaksis.fold(0.0, (sum, dt) => sum + dt.totalTransaksi)}'),
//                               Text(
//                                   'Metode Pembayaran: ${transaksi.metodePembayaran}'),
//                             ],
//                           ),
//                           trailing: ElevatedButton(
//                             onPressed: () {
//                               transaksiController.selectTransaksi(transaksi);
//                               _showDetailDialog(context, transaksi);
//                             },
//                             child: const Text('Detail'),
//                           ),
//                         ),
//                       );
//                     },
//                   )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDetailDialog(BuildContext context, Transaksi transaksi) {
//     final TransaksiController transaksiController =
//         Get.find<TransaksiController>();
//     TextEditingController jumlahDibayarController = TextEditingController();

//     Get.dialog(
//       AlertDialog(
//         title: const Text('Detail Transaksi & Verifikasi'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Transaksi #${transaksi.idTransaksi}'),
//               const SizedBox(height: 8),
//               Text('Pelanggan: ${transaksi.akun?.email ?? "Tidak diketahui"}'),
//               Text(
//                   'Jenis: ${transaksi.detailTransaksis.isNotEmpty ? (transaksi.detailTransaksis[0].idJenisTransaksi == "JTR001" ? "Peminjaman" : "Isi Ulang") : "Tidak diketahui"}'),
//               Text('Jumlah Tabung: ${transaksi.detailTransaksis.length}'),
//               Text(
//                   'Total: ${transaksi.detailTransaksis.fold(0.0, (sum, dt) => sum + dt.totalTransaksi)}'),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: jumlahDibayarController,
//                 decoration: const InputDecoration(
//                   labelText: 'Jumlah Dibayar (Tunai)',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 16),
//               Text('Tabung yang Diproses:'),
//               ...transaksi.detailTransaksis
//                   .map((detail) => Text(
//                       '- ${detail.idTabung} (${detail.idJenisTransaksi == "JTR001" ? "Dipinjam" : "Diisi Ulang"})'))
//                   .toList(),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final jumlahDibayar =
//                   double.tryParse(jumlahDibayarController.text) ?? 0.0;
//               final total = transaksi.detailTransaksis
//                   .fold(0.0, (sum, dt) => sum + dt.totalTransaksi);
//               if (jumlahDibayar >= total) {
//                 transaksiController.updateTransaksiStatus(
//                     transaksi.idTransaksi, 'STS001', jumlahDibayar);
//                 Get.back();
//                 Get.snackbar('Sukses', 'Transaksi selesai dan dicatat');
//               } else {
//                 Get.snackbar('Error', 'Jumlah dibayar kurang dari total');
//               }
//             },
//             child: const Text('Selesaikan Transaksi'),
//           ),
//         ],
//       ),
//     );
//   }
// }
