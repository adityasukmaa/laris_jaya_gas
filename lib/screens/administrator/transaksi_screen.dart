import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:laris_jaya_gas/models/tagihan_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/services/database_service.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Transaksi> _transaksis = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransaksis();
  }

  Future<void> _fetchTransaksis() async {
    setState(() => _isLoading = true);
    try {
      final transaksis = await _databaseService.fetchTransaksiWithRelations();
      setState(() {
        _transaksis =
            transaksis.isNotEmpty ? transaksis : DummyData.transaksiList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _transaksis = DummyData.transaksiList;
        _isLoading = false;
      });
      Get.snackbar('Error', 'Gagal memuat transaksi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showBayarAngsuranDialog(Transaksi transaksi) {
    final tagihan = DummyData.tagihanList.firstWhere(
      (t) => t.idTransaksi == transaksi.idTransaksi,
      orElse: () => Tagihan(
        idTagihan: '',
        idTransaksi: transaksi.idTransaksi,
        jumlahDibayar: 0,
        sisa: transaksi.detailTransaksis?.firstOrNull?.totalTransaksi ?? 0.0,
        status: 'belum_lunas',
        tanggalBayarTagihan: null,
        hariKeterlambatan: 0,
        periodeKe: 0,
        keterangan: '',
      ),
    );

    final TextEditingController angsuranController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bayar Angsuran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sisa Tagihan: Rp ${tagihan.sisa.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: angsuranController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Angsuran',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah Angsuran harus diisi';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Jumlah Angsuran harus berupa angka positif';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final angsuran = double.parse(angsuranController.text);
                if (angsuran > tagihan.sisa) {
                  Get.snackbar(
                    'Error',
                    'Jumlah angsuran melebihi sisa tagihan.',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                final newSisa = tagihan.sisa - angsuran;
                final today = DateTime.now();
                final jatuhTempo = transaksi.tanggalJatuhTempo ?? today;
                final hariKeterlambatan = today.isAfter(jatuhTempo)
                    ? today.difference(jatuhTempo).inDays
                    : 0;
                final periodeKe =
                    hariKeterlambatan > 0 ? (hariKeterlambatan ~/ 30) + 1 : 0;

                final updatedTagihan = Tagihan(
                  idTagihan: tagihan.idTagihan.isEmpty
                      ? 'TGH${(DummyData.tagihanList.length + 1).toString().padLeft(3, '0')}'
                      : tagihan.idTagihan,
                  idTransaksi: transaksi.idTransaksi,
                  jumlahDibayar: tagihan.jumlahDibayar + angsuran,
                  sisa: newSisa < 0 ? 0 : newSisa,
                  status: newSisa <= 0 ? 'lunas' : 'belum_lunas',
                  tanggalBayarTagihan: newSisa <= 0 ? today : null,
                  hariKeterlambatan: hariKeterlambatan,
                  periodeKe: periodeKe,
                  keterangan:
                      'Angsuran tanggal ${DateFormat('dd MMMM yyyy').format(today)}',
                );

                if (tagihan.idTagihan.isEmpty) {
                  DummyData.tagihanList.add(updatedTagihan);
                } else {
                  final index = DummyData.tagihanList
                      .indexWhere((t) => t.idTagihan == tagihan.idTagihan);
                  DummyData.tagihanList[index] = updatedTagihan;
                }

                if (newSisa <= 0) {
                  final peminjaman = DummyData.peminjamanList.firstWhere((p) =>
                      p.idDetailTransaksi ==
                      transaksi.detailTransaksis!.first.idDetailTransaksi);
                  peminjaman.statusPinjam = 'selesai';
                  final tabung = transaksi.detailTransaksis!.first.tabung!;
                  tabung.idStatusTabung = 'STG001';
                  tabung.statusTabung = DummyData.statusTabungList
                      .firstWhere((s) => s.idStatusTabung == 'STG001');
                }

                Get.back();
                _fetchTransaksis();
                Get.snackbar(
                  'Sukses',
                  'Pembayaran angsuran berhasil dicatat',
                  backgroundColor: AppColors.primaryBlue,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Bayar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double paddingVertical = screenHeight * 0.02;
    final double fontSizeTitle = screenWidth * 0.045;
    final double fontSizeSubtitle = screenWidth * 0.035;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Transaksi',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: paddingVertical,
                  horizontal: paddingVertical,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _transaksis.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada transaksi ditemukan',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : Column(
                            children: _transaksis.map((transaksi) {
                              final isPeminjaman = transaksi
                                      .detailTransaksis
                                      ?.firstOrNull
                                      ?.jenisTransaksi
                                      ?.namaJenisTransaksi ==
                                  'peminjaman';
                              final tagihan = DummyData.tagihanList.firstWhere(
                                (t) => t.idTransaksi == transaksi.idTransaksi,
                                orElse: () => Tagihan(
                                  idTagihan: '',
                                  idTransaksi: transaksi.idTransaksi,
                                  jumlahDibayar: 0,
                                  sisa: transaksi.detailTransaksis?.firstOrNull
                                          ?.totalTransaksi ??
                                      0.0,
                                  status: 'belum_lunas',
                                  tanggalBayarTagihan: null,
                                  hariKeterlambatan: 0,
                                  periodeKe: 0,
                                  keterangan: '',
                                ),
                              );

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            transaksi.idTransaksi,
                                            style: TextStyle(
                                              fontSize: fontSizeTitle,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (isPeminjaman && tagihan.sisa > 0)
                                            GestureDetector(
                                              onTap: () =>
                                                  _showBayarAngsuranDialog(
                                                      transaksi),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Bayar Angsuran',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pelanggan: ${transaksi.perusahaan?.namaPerusahaan ?? transaksi.perorangan?.namaLengkap ?? "Unknown"}',
                                        style: TextStyle(
                                          fontSize: fontSizeSubtitle,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Jenis: ${transaksi.detailTransaksis?.firstOrNull?.jenisTransaksi?.namaJenisTransaksi ?? "Unknown"}',
                                        style: TextStyle(
                                          fontSize: fontSizeSubtitle,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Status: ${transaksi.statusTransaksi?.status ?? "Unknown"}',
                                            style: TextStyle(
                                              fontSize: fontSizeSubtitle,
                                              fontWeight: FontWeight.w500,
                                              color: transaksi.statusTransaksi
                                                          ?.status ==
                                                      'success'
                                                  ? Colors.green
                                                  : transaksi.statusTransaksi
                                                              ?.status ==
                                                          'pending'
                                                      ? Colors.orange
                                                      : Colors.red,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: transaksi.statusTransaksi
                                                          ?.status ==
                                                      'success'
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : transaksi.statusTransaksi
                                                              ?.status ==
                                                          'pending'
                                                      ? Colors.orange
                                                          .withOpacity(0.1)
                                                      : Colors.red
                                                          .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              transaksi.statusTransaksi
                                                      ?.status ??
                                                  "Unknown",
                                              style: TextStyle(
                                                fontSize:
                                                    fontSizeSubtitle * 0.8,
                                                color: transaksi.statusTransaksi
                                                            ?.status ==
                                                        'success'
                                                    ? Colors.green
                                                    : transaksi.statusTransaksi
                                                                ?.status ==
                                                            'pending'
                                                        ? Colors.orange
                                                        : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isPeminjaman) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Sisa Tagihan: Rp ${tagihan.sisa.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: fontSizeSubtitle,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        'Detail Tabung:',
                                        style: TextStyle(
                                          fontSize: fontSizeSubtitle,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ...?transaksi.detailTransaksis
                                          ?.map((detail) => Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                  'Tabung: ${detail.tabung?.kodeTabung} (${detail.tabung?.jenisTabung?.namaJenis ?? "Unknown"}) - Rp ${detail.harga.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: fontSizeSubtitle,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              )),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/administrator/tambah-transaksi')
              ?.then((_) => _fetchTransaksis());
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
