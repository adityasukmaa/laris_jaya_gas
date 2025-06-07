// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/notifikasi_controller.dart';

// class NotifikasiScreen extends StatelessWidget {
//   final NotifikasiController notifikasiController = Get.find<NotifikasiController>();

//   NotifikasiScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifikasi')),
//       body: Obx(() => notifikasiController.isLoading.value
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               padding: const EdgeInsets.all(16.0),
//               itemCount: notifikasiController.notifikasiList.length,
//               itemBuilder: (context, index) {
//                 final notifikasi = notifikasiController.notifikasiList[index];
//                 return ListTile(
//                   title: Text(notifikasi.template?.judul ?? 'N/A'),
//                   subtitle: Text(notifikasi.template?.isi ?? 'N/A'),
//                   trailing: notifikasi.statusBaca
//                       ? const Icon(Icons.check, color: Colors.green)
//                       : IconButton(
//                           icon: const Icon(Icons.mark_email_read),
//                           onPressed: () => notifikasiController.markAsRead(notifikasi.idNotifikasi),
//                         ),
//                 );
//               },
//             )),
//     );
//   }
// }