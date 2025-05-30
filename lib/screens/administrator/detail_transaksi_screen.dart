// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
// import 'package:laris_jaya_gas/models/transaksi_model.dart';
// import 'package:laris_jaya_gas/utils/constants.dart';

// class DetailTransaksiScreen extends StatelessWidget {
//   final Transaksi transaction;

//   const DetailTransaksiScreen({super.key, required this.transaction});

//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double paddingVertical = screenHeight * 0.02;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Detail Transaksi',
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(
//           vertical: paddingVertical,
//           horizontal: 24.0,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'ID Transaksi: ${transaction.idTransaksi}',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Tanggal: ${DateFormat('dd MMMM yyyy').format(transaction.tanggalTransaksi)}',
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Metode Pembayaran: ${transaction.metodePembayaran ?? '-'}',
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Jumlah Dibayar: Rp ${NumberFormat('#,##0', 'id_ID').format(transaction.jumlahDibayar ?? 0)}',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Tanggal Jatuh Tempo: ${transaction.tanggalJatuhTempo != null ? DateFormat('dd MMMM yyyy').format(transaction.tanggalJatuhTempo!) : '-'}',
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Text(
//                   'Status: ${transaction.statusTransaksi?.status ?? 'Unknown'}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: transaction.statusTransaksi?.status == 'success'
//                         ? Colors.green
//                         : transaction.statusTransaksi?.status == 'pending'
//                             ? Colors.orange
//                             : Colors.red,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: transaction.statusTransaksi?.status == 'success'
//                         ? Colors.green.withOpacity(0.1)
//                         : transaction.statusTransaksi?.status == 'pending'
//                             ? Colors.orange.withOpacity(0.1)
//                             : Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     transaction.statusTransaksi?.status ?? 'Unknown',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: transaction.statusTransaksi?.status == 'success'
//                           ? Colors.green
//                           : transaction.statusTransaksi?.status == 'pending'
//                               ? Colors.orange
//                               : Colors.red,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Detail Tabung:',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ...transaction.detailTransaksis?.map((detail) => Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Tabung: ${detail.tabung?.kodeTabung ?? 'Unknown'} (${detail.jenisTransaksi?.namaJenisTransaksi ?? 'Unknown'})',
//                             style: const TextStyle(
//                                 fontSize: 16, color: Colors.grey),
//                           ),
//                           Text(
//                             'Rp ${NumberFormat('#,##0', 'id_ID').format(detail.harga ?? 0)}',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )) ??
//                 [
//                   const Text('Tidak ada detail tabung',
//                       style: TextStyle(fontSize: 16, color: Colors.grey))
//                 ],
//             const SizedBox(height: 32),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Fitur edit belum diimplementasikan'),
//                           backgroundColor: AppColors.primaryBlue,
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.edit, size: 20),
//                     label: const Text('Edit'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryBlue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Get.back();
//                       Get.find<TransaksiController>().transaksiList.removeWhere(
//                           (trans) =>
//                               trans.idTransaksi == transaction.idTransaksi);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Transaksi dihapus'),
//                           backgroundColor: AppColors.redFlame,
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.delete, size: 20),
//                     label: const Text('Hapus'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.redFlame,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
