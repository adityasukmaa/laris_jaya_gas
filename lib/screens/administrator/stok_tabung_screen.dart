// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:laris_jaya_gas/controllers/stok_tabung_controller.dart';
// import 'package:laris_jaya_gas/models/tabung_model.dart';

// class StokTabungScreen extends StatelessWidget {
//   const StokTabungScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final StokTabungController controller = Get.put(StokTabungController());

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Stok Tabung'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: controller.selectedJenis.value,
//                       decoration: InputDecoration(
//                         labelText: 'Jenis Tabung',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: ['Semua', '3kg', '12kg']
//                           .map((jenis) => DropdownMenuItem(
//                                 value: jenis,
//                                 child: Text(jenis),
//                               ))
//                           .toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           controller.selectedJenis.value = value;
//                           controller.applyFilter();
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: controller.selectedStatus.value,
//                       decoration: InputDecoration(
//                         labelText: 'Status Tabung',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: ['Semua', 'Tersedia', 'Dipinjam']
//                           .map((status) => DropdownMenuItem(
//                                 value: status,
//                                 child: Text(status),
//                               ))
//                           .toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           controller.selectedStatus.value = value;
//                           controller.applyFilter();
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: controller.filteredTabungList.isEmpty
//                   ? const Center(child: Text('Tidak ada tabung tersedia.'))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: controller.filteredTabungList.length,
//                       itemBuilder: (context, index) {
//                         final Tabung tabung =
//                             controller.filteredTabungList[index];
//                         return Card(
//                           elevation: 2,
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           child: ListTile(
//                             title: Text(tabung.kodeTabung),
//                             subtitle: Text(
//                               'Jenis: ${tabung.jenisTabung?.namaJenis ?? 'Unknown'} | Status: ${tabung.statusTabung?.statusTabung ?? 'Unknown'}',
//                             ),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.qr_code_scanner),
//                               onPressed: () {
//                                 Get.toNamed('/administrator/qr-scan',
//                                     arguments: {
//                                       'onTabungSelected':
//                                           (Map<String, dynamic> data) {
//                                         print(
//                                             'Tabung selected: ${data['tabung'].kodeTabung}');
//                                       },
//                                       'selectedTabungs': [],
//                                     });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
