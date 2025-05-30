// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:laris_jaya_gas/controllers/auth_controller.dart';
// import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
// import 'package:laris_jaya_gas/utils/constants.dart';
// import 'package:laris_jaya_gas/utils/dummy_data.dart';

// class DashboardPelangganScreen extends StatelessWidget {
//   const DashboardPelangganScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.find<AuthController>();
//     final transaksiController = Get.put(TransaksiController());
//     final pelangganData = DummyData.pelangganData;
//     final pelangganId = DummyData.peroranganList
//         .firstWhere((p) => p.namaLengkap == pelangganData['name'])
//         .idPerorangan;

//     // Filter transaksi berdasarkan idPerorangan pelanggan
//     transaksiController.transaksiList
//         .where((transaksi) => transaksi.idPerorangan == pelangganId)
//         .toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Halo, ${pelangganData['name']}'),
//         backgroundColor: AppColors.primaryBlue,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               authController.logout();
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListTile(
//                 title: Text(
//                   pelangganData['name'],
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Email: ${pelangganData['email']}',
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     Text(
//                       'Phone: ${pelangganData['phone']}',
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Transaksi Anda',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: Obx(() {
//                 final filteredList = transaksiController.transaksiList
//                     .where((transaksi) => transaksi.idPerorangan == pelangganId)
//                     .toList();
//                 if (filteredList.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'Tidak ada transaksi ditemukan',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   );
//                 }
//                 return ListView.builder(
//                   itemCount: filteredList.length,
//                   itemBuilder: (context, index) {
//                     final transaksi = filteredList[index];
//                     return Card(
//                       elevation: 2,
//                       margin: const EdgeInsets.only(bottom: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: ListTile(
//                         title: Text(
//                           'Kode Tabung: ${transaksi.detailTransaksis?.isNotEmpty == true ? transaksi.detailTransaksis!.first.tabung?.kodeTabung ?? 'Unknown' : 'Unknown'}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Tanggal Transaksi: ${DateFormat('dd MMMM yyyy').format(transaksi.tanggalTransaksi)}',
//                               style: const TextStyle(
//                                   fontSize: 14, color: Colors.grey),
//                             ),
//                             Text(
//                               'Jatuh Tempo: ${transaksi.tanggalJatuhTempo != null ? DateFormat('dd MMMM yyyy').format(transaksi.tanggalJatuhTempo!) : '-'}',
//                               style: const TextStyle(
//                                   fontSize: 14, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                         trailing: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: transaksi.statusTransaksi?.status ==
//                                     'success'
//                                 ? Colors.green.withOpacity(0.1)
//                                 : transaksi.statusTransaksi?.status == 'pending'
//                                     ? Colors.orange.withOpacity(0.1)
//                                     : Colors.red.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             transaksi.statusTransaksi?.status ?? 'Unknown',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color:
//                                   transaksi.statusTransaksi?.status == 'success'
//                                       ? Colors.green
//                                       : transaksi.statusTransaksi?.status ==
//                                               'pending'
//                                           ? Colors.orange
//                                           : Colors.red,
//                             ),
//                           ),
//                         ),
//                         onTap: () {
//                           Get.toNamed(
//                             '/administrator/detail-transaksi',
//                             arguments: transaksi,
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 Get.toNamed('/pelanggan/ajukan-peminjaman');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryBlue,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'Ajukan Peminjaman',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
