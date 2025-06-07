// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
// import 'package:laris_jaya_gas/models/detail_transaksi_model.dart';
// import 'package:laris_jaya_gas/models/jenis_transaksi_model.dart';
// import 'package:laris_jaya_gas/models/perorangan_model.dart';
// import 'package:laris_jaya_gas/models/perusahaan_model.dart';
// import 'package:laris_jaya_gas/models/status_tabung_model.dart';
// import 'package:laris_jaya_gas/models/status_transaksi_model.dart';
// import 'package:laris_jaya_gas/models/tagihan_model.dart';
// import 'package:laris_jaya_gas/models/transaksi_model.dart';
// import 'package:laris_jaya_gas/utils/constants.dart';
// import 'package:laris_jaya_gas/utils/dummy_data.dart';

// class DetailTransaksiScreen extends StatelessWidget {
//   final Transaksi transaksi;

//   const DetailTransaksiScreen({super.key, required this.transaksi});

//   @override
//   Widget build(BuildContext context) {
//     final tagihan = DummyData.tagihanList.firstWhere(
//       (t) => t.idTransaksi == transaksi.idTransaksi,
//       orElse: () => Tagihan(
//         idTagihan: '',
//         idTransaksi: transaksi.idTransaksi,
//         jumlahDibayar: 0,
//         sisa: transaksi.detailTransaksis?.isNotEmpty == true
//             ? (transaksi.detailTransaksis!.first.totalTransaksi)
//             : 0.0,
//         status: 'belum_lunas',
//         tanggalBayarTagihan: null,
//         hariKeterlambatan: 0,
//         periodeKe: 0,
//         keterangan: '',
//       ),
//     );

//     String pelangganInfo = 'Unknown';
//     if (transaksi.idPerorangan != null) {
//       final perorangan = DummyData.peroranganList.firstWhere(
//         (p) => p.idPerorangan == transaksi.idPerorangan,
//         orElse: () => Perorangan(
//           idPerorangan: '',
//           namaLengkap: 'Unknown',
//           nik: '',
//           noTelepon: '',
//           alamat: '',
//           idPerusahaan: null,
//         ),
//       );
//       pelangganInfo = perorangan.namaLengkap;
//     } else if (transaksi.idPerusahaan != null) {
//       final perusahaan = DummyData.perusahaanList.firstWhere(
//         (p) => p.idPerusahaan == transaksi.idPerusahaan,
//         orElse: () => Perusahaan(
//           idPerusahaan: '',
//           namaPerusahaan: 'Unknown',
//           alamatPerusahaan: '',
//           emailPerusahaan: '',
//         ),
//       );
//       pelangganInfo = perusahaan.namaPerusahaan;
//     }

//     final isPeminjaman = transaksi.detailTransaksis?.isNotEmpty == true
//         ? (transaksi.detailTransaksis!.first.jenisTransaksi
//                     ?.namaJenisTransaksi ??
//                 '') ==
//             'peminjaman'
//         : false;

//     final TransaksiController _controller = Get.find<TransaksiController>();

//     void _showBayarAngsuranDialog() {
//       final TextEditingController angsuranController = TextEditingController();

//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('Bayar Angsuran'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Sisa Tagihan: Rp ${tagihan.sisa.toStringAsFixed(2)}'),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: angsuranController,
//                   decoration: InputDecoration(
//                     labelText: 'Jumlah Angsuran',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Jumlah Angsuran harus diisi';
//                     }
//                     final parsedValue = double.tryParse(value);
//                     if (parsedValue == null || parsedValue <= 0) {
//                       return 'Jumlah Angsuran harus berupa angka positif';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Batal'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   final angsuran =
//                       double.tryParse(angsuranController.text) ?? 0.0;
//                   if (angsuran > tagihan.sisa) {
//                     Get.snackbar(
//                       'Error',
//                       'Jumlah angsuran melebihi sisa tagihan.',
//                       backgroundColor: Colors.red,
//                       colorText: Colors.white,
//                     );
//                     return;
//                   }
//                   final newSisa = tagihan.sisa - angsuran;
//                   final today = DateTime.now();
//                   final jatuhTempo = transaksi.tanggalJatuhTempo ?? today;
//                   final hariKeterlambatan = today.isAfter(jatuhTempo)
//                       ? today.difference(jatuhTempo).inDays
//                       : 0;
//                   final periodeKe =
//                       hariKeterlambatan > 0 ? (hariKeterlambatan ~/ 30) + 1 : 0;

//                   final updatedTagihan = Tagihan(
//                     idTagihan: tagihan.idTagihan.isEmpty
//                         ? 'TGH${(DummyData.tagihanList.length + 1).toString().padLeft(3, '0')}'
//                         : tagihan.idTagihan,
//                     idTransaksi: transaksi.idTransaksi,
//                     jumlahDibayar: tagihan.jumlahDibayar + angsuran,
//                     sisa: newSisa < 0 ? 0 : newSisa,
//                     status: newSisa <= 0 ? 'lunas' : 'belum_lunas',
//                     tanggalBayarTagihan: newSisa <= 0 ? today : null,
//                     hariKeterlambatan: hariKeterlambatan,
//                     periodeKe: periodeKe,
//                     keterangan:
//                         'Angsuran tanggal ${DateFormat('dd MMMM yyyy').format(today)}',
//                   );

//                   if (tagihan.idTagihan.isEmpty) {
//                     DummyData.tagihanList.add(updatedTagihan);
//                   } else {
//                     final index = DummyData.tagihanList
//                         .indexWhere((t) => t.idTagihan == tagihan.idTagihan);
//                     DummyData.tagihanList[index] = updatedTagihan;
//                   }

//                   if (newSisa <= 0) {
//                     transaksi.idStatusTransaksi = 'STS001';
//                     transaksi.statusTransaksi = DummyData.statusTransaksiList
//                         .firstWhere((s) => s.idStatusTransaksi == 'STS001',
//                             orElse: () => StatusTransaksi(
//                                 idStatusTransaksi: 'STS001',
//                                 status: 'success'));

//                     String idDetailTransaksi =
//                         transaksi.detailTransaksis?.isNotEmpty == true
//                             ? transaksi
//                                 .detailTransaksis!.first.idDetailTransaksi
//                             : '';
//                     final peminjamanIndex = DummyData.peminjamanList.indexWhere(
//                         (p) => p.idDetailTransaksi == idDetailTransaksi);
//                     if (peminjamanIndex != -1) {
//                       final peminjaman =
//                           DummyData.peminjamanList[peminjamanIndex];
//                       peminjaman.statusPinjam = 'selesai';
//                       peminjaman.tanggalKembali = today;
//                     }

//                     final tabung =
//                         transaksi.detailTransaksis?.isNotEmpty == true
//                             ? transaksi.detailTransaksis!.first.tabung
//                             : null;
//                     if (tabung != null) {
//                       tabung.idStatusTabung = 1; // Assuming 'STG001' maps to int 1
//                       tabung.statusTabung = DummyData.statusTabungList
//                           .firstWhere((s) => s.idStatusTabung == 1,
//                               orElse: () => StatusTabung(
//                                   idStatusTabung: 1,
//                                   statusTabung: 'tersedia'));
//                     }
//                   }

//                   Get.back();
//                   Get.back();
//                   // _controller
//                   //     .refreshTransaksiList(); // Perbarui data melalui controller
//                   Get.snackbar(
//                     'Sukses',
//                     'Pembayaran angsuran berhasil dicatat',
//                     backgroundColor: AppColors.primaryBlue,
//                     colorText: Colors.white,
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryBlue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Bayar'),
//               ),
//             ],
//           );
//         },
//       );
//     }

//     void _showIsiUlangTabungDialog() {
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('Isi Ulang Tabung'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Pilih tabung untuk diisi ulang:'),
//                 const SizedBox(height: 16),
//                 ...(transaksi.detailTransaksis ?? []).map((detail) {
//                   final tabung = detail.tabung;
//                   if (tabung != null) {
//                     final hargaIsiUlang =
//                         detail.harga; // Menggunakan harga peminjaman
//                     return ListTile(
//                       title: Text(
//                           'Tabung: ${tabung.kodeTabung} (${tabung.jenisTabung?.namaJenis ?? "Unknown"})'),
//                       subtitle:
//                           Text('Harga: Rp ${hargaIsiUlang.toStringAsFixed(2)}'),
//                       onTap: () {
//                         final today = DateTime.now();
//                         final newTransaksiId =
//                             'TRX${(DummyData.transaksiList.length + 1).toString().padLeft(3, '0')}';
//                         final newDetailTransaksiId =
//                             'DTL${(DummyData.transaksiList.length + 1).toString().padLeft(3, '0')}';

//                         final newTransaksi = Transaksi(
//                           idTransaksi: newTransaksiId,
//                           tanggalTransaksi: today,
//                           waktuTransaksi: DateFormat('HH:mm:ss').format(today),
//                           jumlahDibayar: 0,
//                           metodePembayaran: 'Tunai',
//                           idStatusTransaksi: 'STS002',
//                           statusTransaksi: DummyData.statusTransaksiList
//                               .firstWhere(
//                                   (s) => s.idStatusTransaksi == 'STS002',
//                                   orElse: () => StatusTransaksi(
//                                       idStatusTransaksi: 'STS002',
//                                       status: 'pending')),
//                           detailTransaksis: [
//                             DetailTransaksi(
//                               idDetailTransaksi: newDetailTransaksiId,
//                               tabung: tabung,
//                               jenisTransaksi: DummyData.jenisTransaksiList
//                                   .firstWhere(
//                                       (jt) =>
//                                           jt.namaJenisTransaksi == 'isi ulang',
//                                       orElse: () => JenisTransaksi(
//                                           idJenisTransaksi: 'JTR002',
//                                           namaJenisTransaksi: 'isi ulang')),
//                               harga: hargaIsiUlang,
//                               totalTransaksi: hargaIsiUlang,
//                               idTransaksi: '',
//                               idTabung: '',
//                               idJenisTransaksi: '',
//                             ),
//                           ],
//                         );

//                         DummyData.transaksiList.add(newTransaksi);

//                         final newTagihan = Tagihan(
//                           idTagihan:
//                               'TGH${(DummyData.tagihanList.length + 1).toString().padLeft(3, '0')}',
//                           idTransaksi: newTransaksiId,
//                           jumlahDibayar: 0,
//                           sisa: hargaIsiUlang,
//                           status: 'belum_lunas',
//                           tanggalBayarTagihan: null,
//                           hariKeterlambatan: 0,
//                           periodeKe: 0,
//                           keterangan:
//                               'Pengisian ulang tabung ${tabung.kodeTabung}',
//                         );
//                         DummyData.tagihanList.add(newTagihan);

//                         tabung.idStatusTabung = 1; // Assuming 'STG001' maps to int 1
//                         tabung.statusTabung = DummyData.statusTabungList
//                             .firstWhere((s) => s.idStatusTabung == 1,
//                                 orElse: () => StatusTabung(
//                                     idStatusTabung: 1,
//                                     statusTabung: 'tersedia'));

//                         Get.back();
//                         Get.back();
//                         // _controller
//                         //     .refreshTransaksiList(); // Perbarui data melalui controller
//                         Get.snackbar(
//                           'Sukses',
//                           'Permintaan pengisian ulang tabung ${tabung.kodeTabung} telah dicatat. Silakan bayar tagihan.',
//                           backgroundColor: AppColors.primaryBlue,
//                           colorText: Colors.white,
//                         );
//                       },
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 }),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Batal'),
//               ),
//             ],
//           );
//         },
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
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
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'ID Transaksi: ${transaksi.idTransaksi}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Tanggal: ${DateFormat('dd MMMM yyyy').format(transaksi.tanggalTransaksi)}',
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     Text(
//                       'Waktu: ${transaksi.waktuTransaksi}',
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Pelanggan: $pelangganInfo',
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Jenis: ${transaksi.detailTransaksis?.isNotEmpty == true ? (transaksi.detailTransaksis!.first.jenisTransaksi?.namaJenisTransaksi ?? "Unknown") : "Unknown"}',
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Text(
//                           'Status: ${transaksi.statusTransaksi?.status ?? "Unknown"}',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: (transaksi.statusTransaksi?.status ??
//                                         'Unknown') ==
//                                     'success'
//                                 ? Colors.green
//                                 : (transaksi.statusTransaksi?.status ??
//                                             'Unknown') ==
//                                         'pending'
//                                     ? Colors.orange
//                                     : Colors.red,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: (transaksi.statusTransaksi?.status ??
//                                         'Unknown') ==
//                                     'success'
//                                 ? Colors.green.withOpacity(0.1)
//                                 : (transaksi.statusTransaksi?.status ??
//                                             'Unknown') ==
//                                         'pending'
//                                     ? Colors.orange.withOpacity(0.1)
//                                     : Colors.red.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             transaksi.statusTransaksi?.status ?? "Unknown",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: (transaksi.statusTransaksi?.status ??
//                                           'Unknown') ==
//                                       'success'
//                                   ? Colors.green
//                                   : (transaksi.statusTransaksi?.status ??
//                                               'Unknown') ==
//                                           'pending'
//                                       ? Colors.orange
//                                       : Colors.red,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     if (isPeminjaman) ...[
//                       Text(
//                         'Sisa Tagihan: Rp ${tagihan.sisa.toStringAsFixed(2)}',
//                         style:
//                             const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       Text(
//                         'Jumlah Dibayar: Rp ${tagihan.jumlahDibayar.toStringAsFixed(2)}',
//                         style:
//                             const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       if (tagihan.hariKeterlambatan > 0)
//                         Text(
//                           'Hari Keterlambatan: ${tagihan.hariKeterlambatan}',
//                           style:
//                               const TextStyle(fontSize: 14, color: Colors.red),
//                         ),
//                       if (tagihan.tanggalBayarTagihan != null)
//                         Text(
//                           'Tanggal Lunas: ${DateFormat('dd MMMM yyyy').format(tagihan.tanggalBayarTagihan!)}',
//                           style:
//                               const TextStyle(fontSize: 14, color: Colors.grey),
//                         ),
//                     ],
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Detail Tabung:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ...(transaksi.detailTransaksis ?? []).map(
//                       (detail) => Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Kode Tabung: ${detail.tabung?.kodeTabung ?? "Unknown"}',
//                               style: const TextStyle(
//                                   fontSize: 14, color: Colors.grey),
//                             ),
//                             Text(
//                               'Jenis Tabung: ${detail.tabung?.jenisTabung?.namaJenis ?? "Unknown"}',
//                               style: const TextStyle(
//                                   fontSize: 14, color: Colors.grey),
//                             ),
//                             Text(
//                               'Harga: Rp ${(detail.harga).toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                   fontSize: 14, color: Colors.grey),
//                             ),
//                             Text(
//                               'Total: Rp ${(detail.totalTransaksi).toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                   fontSize: 14, color: Colors.grey),
//                             ),
//                             Text(
//                               'Status Tabung: ${detail.tabung?.statusTabung?.statusTabung ?? "Unknown"}',
//                               style: const TextStyle(
//                                   fontSize: 14, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (isPeminjaman &&
//                 tagihan.sisa > 0 &&
//                 (transaksi.statusTransaksi?.status ?? '') == 'pending')
//               ElevatedButton(
//                 onPressed: _showBayarAngsuranDialog,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.secondary,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'Bayar Angsuran',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             if (isPeminjaman &&
//                 transaksi.detailTransaksis?.isNotEmpty == true &&
//                 transaksi.statusTransaksi?.status == 'success')
//               ElevatedButton(
//                 onPressed: _showIsiUlangTabungDialog,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'Isi Ulang Tabung',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
