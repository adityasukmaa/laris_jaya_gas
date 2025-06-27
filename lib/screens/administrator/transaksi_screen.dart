// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
// import 'package:laris_jaya_gas/utils/constants.dart';

// class TransaksiScreen extends StatelessWidget {
//   final TransaksiController controller = Get.put(TransaksiController());
//   final _formKey = GlobalKey<FormState>();

//   TransaksiScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isLargeScreen = MediaQuery.of(context).size.width > 600;
//     return Scaffold(
//       backgroundColor: AppColors.greyBackground,
//       appBar: _buildAppBar(),
//       body: Obx(() => _buildBody(context, isLargeScreen)),
//       floatingActionButton: _buildFAB(),
//     );
//   }

//   AppBar _buildAppBar() {
//     return AppBar(
//       backgroundColor: AppColors.primaryBlue,
//       title: const Text('Buat Transaksi',
//           style: TextStyle(color: AppColors.white)),
//       iconTheme: const IconThemeData(color: AppColors.white),
//       elevation: 4,
//     );
//   }

//   Widget _buildBody(BuildContext context, bool isLargeScreen) {
//     if (controller.isLoading.value) {
//       return const Center(
//           child: CircularProgressIndicator(color: AppColors.primaryBlue));
//     }
//     if (controller.errorMessage.isNotEmpty) {
//       return _buildErrorState(context);
//     }
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(AppSizes.padding),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildPelangganSection(),
//             const SizedBox(height: AppSizes.padding),
//             _buildTanggalTransaksi(),
//             const SizedBox(height: AppSizes.padding),
//             _buildTabungSection(context),
//             const SizedBox(height: AppSizes.padding),
//             _buildDetailTransaksi(isLargeScreen),
//             const SizedBox(height: AppSizes.padding),
//             _buildPembayaranSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             controller.errorMessage.value,
//             style: const TextStyle(color: AppColors.redFlame, fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: controller.fetchPelanggan,
//             style: _buttonStyle(),
//             child: const Text('Coba Lagi',
//                 style: TextStyle(color: AppColors.white, fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPelangganSection() {
//     return Obx(() => DropdownButtonFormField<String>(
//           value: controller.selectedPelanggan.value.isEmpty
//               ? null
//               : controller.selectedPelanggan.value,
//           decoration: InputDecoration(
//             labelText: 'Pilih Pelanggan',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: AppColors.white,
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           ),
//           items: controller.pelangganList.map((pelanggan) {
//             final id = pelanggan.idAkun ?? pelanggan.idPerorangan;
//             final nama = pelanggan.namaLengkap ??
//                 pelanggan.email ??
//                 pelanggan.namaPerusahaan ??
//                 '-';
//             return DropdownMenuItem(value: '$id', child: Text(nama));
//           }).toList(),
//           onChanged: (value) {
//             if (value != null) {
//               controller.selectedPelanggan.value = value;
//             }
//           },
//           validator: (value) =>
//               value == null ? 'Pilih pelanggan terlebih dahulu' : null,
//         ));
//   }

//   Widget _buildTanggalTransaksi() {
//     return Text(
//       'Tanggal Transaksi: ${DateTime.now().toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].substring(0, 8)}',
//       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//     );
//   }

//   Widget _buildTabungSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Kode Tabung',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.white,
//                 ),
//                 onChanged: (value) => controller.kodeTabung.value = value,
//                 onFieldSubmitted: (value) => controller.validasiTabung(value),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () => _navigateToScanner(context),
//               style: _buttonStyle(),
//               child: const Text('Scan QR',
//                   style: TextStyle(color: AppColors.white)),
//             ),
//           ],
//         ),
//         Obx(() => controller.tabungData.isNotEmpty
//             ? _buildTabungResult(context)
//             : const SizedBox.shrink()),
//       ],
//     );
//   }

//   Widget _buildTabungResult(BuildContext context) {
//     final tabung = controller.tabungData[0];
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Tabung: ${tabung['kode_tabung']} (${tabung['nama_jenis']})'),
//             Text('Harga: Rp ${tabung['harga']})'),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: controller.selectedJenisTransaksi.value.isEmpty
//                   ? null
//                   : controller.selectedJenisTransaksi.value,
//               decoration: InputDecoration(
//                 labelText: 'Jenis Transaksi',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 filled: true,
//                 fillColor: AppColors.white,
//               ),
//               items: (tabung['opsi_transaksi'] as List<dynamic>)
//                   .map<DropdownMenuItem<String>>(
//                       (opsi) => DropdownMenuItem<String>(
//                             value: opsi['nama'] as String,
//                             child: Text(opsi['nama'] as String),
//                           ))
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   controller.selectedJenisTransaksi.value = value;
//                 }
//               },
//               validator: (value) =>
//                   value == null ? 'Pilih jenis transaksi' : null,
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   controller.tambahDetail(
//                       tabung, controller.selectedJenisTransaksi.value);
//                 }
//               },
//               style: _buttonStyle(),
//               child: const Text('Tambah ke Transaksi',
//                   style: TextStyle(color: AppColors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailTransaksi(bool isLargeScreen) {
//     return Obx(() => Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Detail Transaksi',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 8),
//             controller.details.isEmpty
//                 ? const Text('Belum ada tabung ditambahkan.',
//                     style: TextStyle(color: Colors.grey))
//                 : isLargeScreen
//                     ? _buildDetailDataTable()
//                     : _buildDetailListView(),
//             const SizedBox(height: 8),
//             Text('Total Transaksi: Rp ${controller.totalTransaksi.value}',
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           ],
//         ));
//   }

//   Widget _buildDetailDataTable() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         columnSpacing: 16,
//         dataRowHeight: 60,
//         headingRowColor:
//             WidgetStateProperty.all(AppColors.primaryBlue.withOpacity(0.1)),
//         columns: const [
//           DataColumn(
//               label: Text('Kode Tabung',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           DataColumn(
//               label:
//                   Text('Jenis', style: TextStyle(fontWeight: FontWeight.bold))),
//           DataColumn(
//               label:
//                   Text('Harga', style: TextStyle(fontWeight: FontWeight.bold))),
//           DataColumn(
//               label:
//                   Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
//         ],
//         rows: controller.details.asMap().entries.map((entry) {
//           final index = entry.key;
//           final detail = entry.value;
//           return DataRow(cells: [
//             DataCell(Text(detail['id_tabung'].toString())),
//             DataCell(Text(detail['id_jenis_transaksi'] == 1
//                 ? 'Peminjaman'
//                 : 'Isi Ulang')),
//             DataCell(Text('Rp ${detail['harga']}')),
//             DataCell(IconButton(
//               icon: const Icon(Icons.delete, color: AppColors.redFlame),
//               onPressed: () => controller.hapusDetail(index),
//             )),
//           ]);
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildDetailListView() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: controller.details.length,
//       itemBuilder: (context, index) {
//         final detail = controller.details[index];
//         return Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
//           margin: const EdgeInsets.symmetric(vertical: 4),
//           child: ListTile(
//             title: Text('Tabung ID: ${detail['id_tabung']}'),
//             subtitle: Text(
//                 'Jenis: ${detail['id_jenis_transaksi'] == 1 ? 'Peminjaman' : 'Isi Ulang'}\nHarga: Rp ${detail['harga']}'),
//             trailing: IconButton(
//               icon: const Icon(Icons.delete, color: AppColors.redFlame),
//               onPressed: () => controller.hapusDetail(index),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPembayaranSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Pembayaran',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         Obx(() => DropdownButtonFormField<String>(
//               value: controller.metodePembayaran.value,
//               decoration: InputDecoration(
//                 labelText: 'Metode Pembayaran',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 filled: true,
//                 fillColor: AppColors.white,
//               ),
//               items: const [
//                 DropdownMenuItem(value: 'tunai', child: Text('Tunai')),
//                 DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
//               ],
//               onChanged: (value) {
//                 if (value != null) {
//                   controller.metodePembayaran.value = value;
//                 }
//               },
//               validator: (value) =>
//                   value == null ? 'Pilih metode pembayaran' : null,
//             )),
//         const SizedBox(height: 8),
//         TextFormField(
//           decoration: InputDecoration(
//             labelText: 'Jumlah Dibayar (Rp)',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: AppColors.white,
//           ),
//           keyboardType: TextInputType.number,
//           onChanged: (value) =>
//               controller.jumlahDibayar.value = double.tryParse(value) ?? 0,
//           validator: (value) =>
//               value == null || value.isEmpty ? 'Masukkan jumlah dibayar' : null,
//         ),
//       ],
//     );
//   }

//   FloatingActionButton _buildFAB() {
//     return FloatingActionButton(
//       onPressed: () {
//         if (_formKey.currentState!.validate()) {
//           controller.buatTransaksi();
//         }
//       },
//       backgroundColor: AppColors.secondary,
//       elevation: 6,
//       child: const Icon(Icons.save, color: AppColors.white),
//       tooltip: 'Simpan Transaksi',
//     );
//   }

//   void _navigateToScanner(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ScannerScreen(
//           onScan: (barcode) {
//             if (barcode.barcodes.isNotEmpty) {
//               controller.validasiTabung(barcode.barcodes.first.rawValue ?? '');
//             }
//           },
//         ),
//       ),
//     );
//   }

//   ButtonStyle _buttonStyle() {
//     return ElevatedButton.styleFrom(
//       backgroundColor: AppColors.primaryBlue,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//     );
//   }
// }

// class ScannerScreen extends StatelessWidget {
//   final Function(BarcodeCapture) onScan;

//   const ScannerScreen({super.key, required this.onScan});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code',
//             style: TextStyle(color: AppColors.white)),
//         backgroundColor: AppColors.primaryBlue,
//         iconTheme: const IconThemeData(color: AppColors.white),
//       ),
//       body: MobileScanner(
//         onDetect: (barcodeCapture) {
//           onScan(barcodeCapture);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
// }
