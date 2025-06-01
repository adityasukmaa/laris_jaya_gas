import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
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
        _controller.filteredTransaksiList.value =
            _transaksis.whereType<Transaksi>().toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _transaksis = DummyData.transaksiList;
        _controller.filteredTransaksiList.value =
            _transaksis.whereType<Transaksi>().toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingVertical = screenHeight * 0.02;

    final List<String> jenisTransaksiList = [
      'Semua',
      ...DummyData.jenisTransaksiList
          .map((jt) => jt.namaJenisTransaksi)
          .toList(),
    ];

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
                    Obx(() => ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _controller.filteredTransaksiList.length,
                          itemBuilder: (context, index) {
                            final transaksi =
                                _controller.filteredTransaksiList[index];
                            final isPeminjaman =
                                transaksi.detailTransaksis?.isNotEmpty == true
                                    ? (transaksi
                                                .detailTransaksis!
                                                .first
                                                .jenisTransaksi
                                                ?.namaJenisTransaksi ??
                                            '') ==
                                        'peminjaman'
                                    : false;
                            final tagihan = DummyData.tagihanList.firstWhere(
                              (t) => t.idTransaksi == transaksi.idTransaksi,
                              orElse: () => Tagihan(
                                idTagihan: '',
                                idTransaksi: transaksi.idTransaksi,
                                jumlahDibayar: 0,
                                sisa: transaksi.detailTransaksis?.isNotEmpty ==
                                        true
                                    ? (transaksi
                                        .detailTransaksis!.first.totalTransaksi)
                                    : 0.0,
                                status: 'belum_lunas',
                                tanggalBayarTagihan: null,
                                hariKeterlambatan: 0,
                                periodeKe: 0,
                                keterangan: '',
                              ),
                            );

                            String pelangganInfo = 'Unknown';
                            if (transaksi.idPerorangan != null) {
                              final perorangan = DummyData.peroranganList
                                  .firstWhere(
                                      (p) =>
                                          p.idPerorangan ==
                                          transaksi.idPerorangan,
                                      orElse: () => Perorangan(
                                            idPerorangan: '',
                                            namaLengkap: 'Unknown',
                                            nik: '',
                                            noTelepon: '',
                                            alamat: '',
                                            idPerusahaan: null,
                                          ));
                              pelangganInfo = perorangan.namaLengkap;
                            } else if (transaksi.idPerusahaan != null) {
                              final perusahaan = DummyData.perusahaanList
                                  .firstWhere(
                                      (p) =>
                                          p.idPerusahaan ==
                                          transaksi.idPerusahaan,
                                      orElse: () => Perusahaan(
                                            idPerusahaan: '',
                                            namaPerusahaan: 'Unknown',
                                            alamatPerusahaan: '',
                                            emailPerusahaan: '',
                                          ));
                              pelangganInfo = perusahaan.namaPerusahaan;
                            }

                            return GestureDetector(
                              onTap: () {
                                Get.toNamed('/administrator/detail-transaksi',
                                        arguments: transaksi)
                                    ?.then((_) => _fetchTransaksis());
                              },
                              child: Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 8),
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
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pelanggan: $pelangganInfo',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Jenis: ${transaksi.detailTransaksis?.isNotEmpty == true ? (transaksi.detailTransaksis!.first.jenisTransaksi?.namaJenisTransaksi ?? "Unknown") : "Unknown"}',
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
                                              color: (transaksi.statusTransaksi
                                                              ?.status ??
                                                          'Unknown') ==
                                                      'success'
                                                  ? Colors.green
                                                  : (transaksi.statusTransaksi
                                                                  ?.status ??
                                                              'Unknown') ==
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
                                              color: (transaksi.statusTransaksi
                                                              ?.status ??
                                                          'Unknown') ==
                                                      'success'
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : (transaksi.statusTransaksi
                                                                  ?.status ??
                                                              'Unknown') ==
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
                                                fontSize: 12,
                                                color: (transaksi
                                                                .statusTransaksi
                                                                ?.status ??
                                                            'Unknown') ==
                                                        'success'
                                                    ? Colors.green
                                                    : (transaksi.statusTransaksi
                                                                    ?.status ??
                                                                'Unknown') ==
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
                                    ],
                                  ),
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
        onPressed: () async {
          try {
            await Get.toNamed('/administrator/tambah-transaksi');
            _fetchTransaksis();
          } catch (e) {
            Get.snackbar(
              'Error',
              'Gagal membuka halaman tambah transaksi: $e',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
