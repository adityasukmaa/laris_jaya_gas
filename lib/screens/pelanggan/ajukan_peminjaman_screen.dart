// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:laris_jaya_gas/models/transaksi_model.dart';
// import '../../controllers/tabung_controller.dart';
// import '../../controllers/transaksi_controller.dart';

// class AjukanPeminjamanScreen extends StatefulWidget {
//   const AjukanPeminjamanScreen({super.key});

//   @override
//   _AjukanPeminjamanScreenState createState() => _AjukanPeminjamanScreenState();
// }

// class _AjukanPeminjamanScreenState extends State<AjukanPeminjamanScreen> {
//   final _formKey = GlobalKey<FormState>();
//   DateTime _selectedDate = DateTime.now();
//   String? _selectedTabung;
//   String? _jumlahTabung;
//   final tabungController = Get.find<TabungController>();
//   final transaksiController = Get.find<TransaksiController>();

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2026),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   DateTime _calculateDueDate() {
//     return _selectedDate.add(const Duration(days: 7));
//   }

//   void _submitPeminjaman() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       final newTransaksi = Transaksi(
//         idTransaksi: 'TR${DateTime.now().millisecondsSinceEpoch}',
//         idPelanggan: 'PL001',
//         kodeTabung: _selectedTabung!,
//         jumlahTabung: int.parse(_jumlahTabung!),
//         tanggalPeminjaman: _selectedDate,
//         tanggalJatuhTempo: _calculateDueDate(),
//         status: 'pending',
//       );
//       transaksiController.transaksiList.add(newTransaksi);
//       Get.snackbar('Sukses', 'Peminjaman berhasil diajukan');
//       Get.offNamed('/pelanggan/dashboard');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ajukan Peminjaman'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: () => _selectDate(context),
//                 child: AbsorbPointer(
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Tanggal Peminjaman',
//                       border: const OutlineInputBorder(),
//                       suffixIcon: const Icon(Icons.calendar_today),
//                     ),
//                     controller: TextEditingController(
//                       text: DateFormat('dd/MM/yyyy').format(_selectedDate),
//                     ),
//                     validator: (value) => null,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Pilih Tabung',
//                   border: OutlineInputBorder(),
//                 ),
//                 value: _selectedTabung,
//                 items: tabungController.tabungList
//                     .where((tabung) => tabung.status == 'tersedia')
//                     .map((tabung) {
//                   return DropdownMenuItem<String>(
//                     value: tabung.kodeTabung,
//                     child: Text(tabung.kodeTabung),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedTabung = value;
//                   });
//                 },
//                 validator: (value) => value == null ? 'Pilih tabung' : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: 'Jumlah Tabung',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Wajib diisi';
//                   if (int.tryParse(value) == null || int.parse(value) <= 0)
//                     return 'Harus angka positif';
//                   return null;
//                 },
//                 onSaved: (value) => _jumlahTabung = value,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitPeminjaman,
//                 child: const Text('Ajukan'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
