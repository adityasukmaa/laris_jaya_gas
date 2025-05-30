import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
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
  final TransaksiController _controller = Get.put(TransaksiController());
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
        _controller.filteredTransaksiList.value = _transaksis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _transaksis = DummyData.transaksiList;
        _controller.filteredTransaksiList.value = _transaksis;
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
        sisa: transaksi.detailTransaksis?.isNotEmpty ?? false
            ? transaksi.detailTransaksis!.first.totalTransaksi ?? 0.0
            : 0.0,
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
    final double paddingVertical = screenHeight * 0.02;

    // Daftar jenis transaksi untuk dropdown berdasarkan dummy data
    final List<String> jenisTransaksiList = [
      'Semua',
      ...DummyData.jenisTransaksiList
          .map((jt) => jt.namaJenisTransaksi)
          .toList(),
    ];

    // Daftar status transaksi untuk dropdown berdasarkan dummy data
    final List<String> statusTransaksiList = [
      'Semua',
      ...DummyData.statusTransaksiList.map((st) => st.status).toList(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                    vertical: paddingVertical, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rekap dengan Obx terpisah
                    Obx(() => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.secondary
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Transaksi Berjalan: ${_controller.totalTransaksiBerjalan}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Transaksi Bulan Ini: ${_controller.totalTransaksiBulanIni}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => DropdownButtonFormField<String>(
                                value: _controller.selectedJenisTransaksi.value,
                                decoration: InputDecoration(
                                  labelText: 'Jenis Transaksi',
                                  labelStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.primaryBlue),
                                  ),
                                ),
                                items: jenisTransaksiList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontWeight: value ==
                                                _controller
                                                    .selectedJenisTransaksi
                                                    .value
                                            ? FontWeight.normal
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _controller.selectedJenisTransaksi.value =
                                        value;
                                  }
                                },
                              )),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() => DropdownButtonFormField<String>(
                                value:
                                    _controller.selectedStatusTransaksi.value,
                                decoration: InputDecoration(
                                  labelText: 'Status Transaksi',
                                  labelStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.primaryBlue),
                                  ),
                                ),
                                items: statusTransaksiList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontWeight: value ==
                                                _controller
                                                    .selectedStatusTransaksi
                                                    .value
                                            ? FontWeight.normal
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _controller.selectedStatusTransaksi.value =
                                        value;
                                  }
                                },
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _controller.applyFilter();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Daftar transaksi dengan Obx terpisah
                    Obx(() => ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _controller.filteredTransaksiList.length,
                          itemBuilder: (context, index) {
                            final transaksi =
                                _controller.filteredTransaksiList[index];
                            final isPeminjaman =
                                transaksi.detailTransaksis?.isNotEmpty ?? false
                                    ? transaksi
                                            .detailTransaksis!
                                            .first
                                            .jenisTransaksi
                                            ?.namaJenisTransaksi ==
                                        'peminjaman'
                                    : false;
                            final tagihan = DummyData.tagihanList.firstWhere(
                              (t) => t.idTransaksi == transaksi.idTransaksi,
                              orElse: () => Tagihan(
                                idTagihan: '',
                                idTransaksi: transaksi.idTransaksi,
                                jumlahDibayar: 0,
                                sisa: transaksi.detailTransaksis?.isNotEmpty ??
                                        false
                                    ? transaksi.detailTransaksis!.first
                                            .totalTransaksi ??
                                        0.0
                                    : 0.0,
                                status: 'belum_lunas',
                                tanggalBayarTagihan: null,
                                hariKeterlambatan: 0,
                                periodeKe: 0,
                                keterangan: '',
                              ),
                            );

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          transaksi.idTransaksi,
                                          style: const TextStyle(
                                            fontSize: 16,
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
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Jenis: ${transaksi.detailTransaksis?.isNotEmpty ?? false ? transaksi.detailTransaksis!.first.jenisTransaksi?.namaJenisTransaksi ?? "Unknown" : "Unknown"}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Status: ${transaksi.statusTransaksi?.status ?? "Unknown"}',
                                          style: TextStyle(
                                            fontSize: 14,
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
                                                ? Colors.green.withOpacity(0.1)
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
                                            transaksi.statusTransaksi?.status ??
                                                "Unknown",
                                            style: TextStyle(
                                              fontSize: 12,
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      'Detail Tabung:',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ...transaksi.detailTransaksis
                                            ?.map((detail) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: Text(
                                                    'Tabung: ${detail.tabung?.kodeTabung} (${detail.tabung?.jenisTabung?.namaJenis ?? "Unknown"}) - Rp ${detail.harga.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )) ??
                                        [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Text(
                                              'Tidak ada detail tabung',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
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
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
