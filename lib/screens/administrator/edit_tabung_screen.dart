// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
// import 'package:laris_jaya_gas/models/status_tabung_model.dart';
// import 'package:laris_jaya_gas/models/tabung_model.dart';
// import 'package:laris_jaya_gas/utils/constants.dart';
// import '../../utils/dummy_data.dart';

// class EditTabungScreen extends StatefulWidget {
//   const EditTabungScreen({super.key, required String kodeTabung});

//   @override
//   State<EditTabungScreen> createState() => _EditTabungScreenState();
// }

// class _EditTabungScreenState extends State<EditTabungScreen> {
//   final Color primaryBlue = const Color(0xFF0172B2); // Warna utama aplikasi
//   final Color darkBlue = const Color(0xFF001848); // Warna sekunder aplikasi

//   // Daftar opsi untuk dropdown jenis tabung dan status tabung dari DummyData
//   final List<String> jenisTabungList =
//       DummyData.jenisTabungList.map((jenis) => jenis.namaJenis).toList();
//   final List<String> statusTabungList =
//       DummyData.statusTabungList.map((status) => status.statusTabung).toList();

//   // Controller untuk form input
//   final TextEditingController kodeTabungController = TextEditingController();
//   final _formKey = GlobalKey<FormState>(); // Key untuk validasi form
//   String? selectedJenis; // Variabel untuk menyimpan jenis tabung yang dipilih
//   String? selectedStatus; // Variabel untuk menyimpan status tabung yang dipilih
//   String? kodeTabung; // Kode tabung yang diterima dari argumen

//   @override
//   void initState() {
//     super.initState();
//     // Ambil kode tabung dari argumen navigasi
//     kodeTabung = Get.arguments as String?;
//     if (kodeTabung != null) {
//       // Cari tabung berdasarkan kode
//       final tabung = DummyData.tabungList.firstWhere(
//         (tabung) => tabung.kodeTabung == kodeTabung,
//         orElse: () => Tabung(
//           idTabung: '',
//           kodeTabung: '',
//           idJenisTabung: null,
//           idStatusTabung: null,
//           jenisTabung: JenisTabung(
//               idJenisTabung: 0, kodeJenis: '', namaJenis: '', harga: 0.0),
//           statusTabung: StatusTabung(idStatusTabung: 0, statusTabung: ''),
//         ),
//       );
//       kodeTabungController.text = tabung.kodeTabung;
//       selectedJenis = tabung.jenisTabung?.namaJenis;
//       selectedStatus = tabung.statusTabung?.statusTabung;
//     }
//   }

//   @override
//   void dispose() {
//     kodeTabungController.dispose();
//     super.dispose();
//   }

//   // Fungsi untuk menyimpan perubahan tabung
//   void _saveTabung() {
//     if (_formKey.currentState!.validate()) {
//       // Validasi berhasil, simpan perubahan tabung
//       final index = DummyData.tabungList
//           .indexWhere((tabung) => tabung.kodeTabung == kodeTabung);
//       if (index != -1) {
//         // Cari idJenisTabung dan idStatusTabung berdasarkan pilihan pengguna
//         final selectedJenisTabung = DummyData.jenisTabungList.firstWhere(
//           (jenis) => jenis.namaJenis == selectedJenis,
//           orElse: () => JenisTabung(
//               idJenisTabung: 0, kodeJenis: '', namaJenis: '', harga: 0.0),
//         );
//         final selectedStatusTabung = DummyData.statusTabungList.firstWhere(
//           (status) => status.statusTabung == selectedStatus,
//           orElse: () => StatusTabung(idStatusTabung: 0, statusTabung: ''),
//         );

//         final updatedTabung = Tabung(
//           idTabung: DummyData.tabungList[index].idTabung,
//           kodeTabung: kodeTabungController.text,
//           idJenisTabung: selectedJenisTabung.idJenisTabung,
//           idStatusTabung: selectedStatusTabung.idStatusTabung,
//           jenisTabung: selectedJenisTabung,
//           statusTabung: selectedStatusTabung,
//         );
//         DummyData.tabungList[index] = updatedTabung;

//         Get.back(); // Kembali ke halaman sebelumnya
//         Get.snackbar('Sukses', 'Tabung berhasil diperbarui',
//             backgroundColor: AppColors.whiteSemiTransparent,
//             colorText: Colors.black);
//       } else {
//         Get.snackbar('Error', 'Tabung tidak ditemukan',
//             backgroundColor: Colors.red, colorText: Colors.white);
//       }
//     }
//   }

//   // Fungsi untuk membatalkan edit
//   void _cancelEdit() {
//     Get.back(); // Kembali ke halaman sebelumnya tanpa menyimpan
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Dapatkan tinggi dan lebar layar untuk penyesuaian responsif
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double paddingVertical = screenHeight * 0.02; // 2% dari tinggi layar

//     return Scaffold(
//       backgroundColor: Colors.white, // Konsistensi dengan TambahTabungScreen
//       appBar: AppBar(
//         backgroundColor: primaryBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text('Edit Tabung', style: TextStyle(color: Colors.white)),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding:
//               EdgeInsets.symmetric(vertical: paddingVertical, horizontal: 24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//                 // Input untuk Kode Tabung (readonly)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Kode Tabung',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: kodeTabungController,
//                       readOnly: true, // Kode tabung tidak boleh diubah
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderSide:
//                               const BorderSide(color: Color(0xFFD0D5DD)),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         prefixIcon: const Icon(Icons.tag,
//                             size: 20, color: Color(0xFFD0D5DD)),
//                         hintText: 'Masukkan kode tabung (contoh: OXY023)',
//                         hintStyle: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Dropdown untuk Jenis Tabung
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Jenis Tabung',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     DropdownButtonFormField<String>(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderSide:
//                               const BorderSide(color: Color(0xFFD0D5DD)),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         prefixIcon: const Icon(Icons.category,
//                             size: 20, color: Color(0xFFD0D5DD)),
//                         hintText: 'Pilih Jenis',
//                         hintStyle: const TextStyle(fontSize: 14),
//                       ),
//                       value: selectedJenis,
//                       items: jenisTabungList.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(
//                             value,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedJenis = value; // Perbarui nilai jenis tabung
//                         });
//                       },
//                       dropdownColor: Colors.white,
//                       icon: const Icon(Icons.arrow_drop_down,
//                           color: Color(0xFFD0D5DD), size: 24),
//                       isExpanded: true,
//                       style: const TextStyle(fontSize: 14, color: Colors.black),
//                       menuMaxHeight: screenHeight * 0.3,
//                       elevation: 8,
//                       validator: (value) {
//                         if (value == null) {
//                           return 'Jenis Tabung harus dipilih';
//                         }
//                         return null;
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Dropdown untuk Status Tabung
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Status Tabung',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     DropdownButtonFormField<String>(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderSide:
//                               const BorderSide(color: Color(0xFFD0D5DD)),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         prefixIcon: const Icon(Icons.check_circle_outline,
//                             size: 20, color: Color(0xFFD0D5DD)),
//                         hintText: 'Pilih Status',
//                         hintStyle: const TextStyle(fontSize: 14),
//                       ),
//                       value: selectedStatus,
//                       items: statusTabungList.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(
//                             value,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedStatus =
//                               value; // Perbarui nilai status tabung
//                         });
//                       },
//                       dropdownColor: Colors.white,
//                       icon: const Icon(Icons.arrow_drop_down,
//                           color: Color(0xFFD0D5DD), size: 24),
//                       isExpanded: true,
//                       style: const TextStyle(fontSize: 14, color: Colors.black),
//                       menuMaxHeight: screenHeight * 0.3,
//                       elevation: 8,
//                       validator: (value) {
//                         if (value == null) {
//                           return 'Status Tabung harus dipilih';
//                         }
//                         return null;
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 // Tombol Simpan dan Batal
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: _cancelEdit,
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           side: BorderSide(color: AppColors.secondary),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: Text(
//                           'Batal',
//                           style: TextStyle(
//                               color: AppColors.secondary, fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _saveTabung,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: darkBlue,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: const Text(
//                           'Simpan',
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20), // Padding bawah
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
