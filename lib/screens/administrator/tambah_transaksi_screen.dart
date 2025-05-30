import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/detail_transaksi_model.dart';
import 'package:laris_jaya_gas/models/jenis_transaksi_model.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:laris_jaya_gas/models/peminjaman_model.dart';
import 'package:laris_jaya_gas/models/tagihan_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

class TambahTransaksiScreen extends StatefulWidget {
  const TambahTransaksiScreen({super.key});

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController noTeleponController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController jumlahDibayarController = TextEditingController();

  List<Map<String, dynamic>> selectedTabungs = [];
  String? selectedMetodePembayaran = 'tunai';
  MobileScannerController scannerController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool isScanning = false;

  @override
  void dispose() {
    scannerController.dispose();
    namaController.dispose();
    nikController.dispose();
    noTeleponController.dispose();
    alamatController.dispose();
    jumlahDibayarController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    final String? kodeTabung = barcodeCapture.barcodes.first.rawValue;
    if (kodeTabung != null) {
      final tabung = DummyData.tabungList.firstWhere(
        (t) => t.kodeTabung == kodeTabung,
        orElse: () => Tabung(
          idTabung: '',
          kodeTabung: '',
          idJenisTabung: '',
          idStatusTabung: '',
        ),
      );

      if (tabung.idTabung!.isEmpty) {
        Get.snackbar(
          'Error',
          'Tabung tidak ditemukan!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else if (tabung.statusTabung?.statusTabung == 'Dipinjam') {
        Get.snackbar(
          'Peringatan',
          'Tabung ${tabung.kodeTabung} sedang dipinjam!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (selectedTabungs
          .any((t) => t['tabung'].kodeTabung == kodeTabung)) {
        Get.snackbar(
          'Peringatan',
          'Tabung ${tabung.kodeTabung} sudah dipilih!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        _showJenisTransaksiDialog(tabung);
      }
      setState(() {
        isScanning = false;
        scannerController.stop();
      });
    }
  }

  void _showJenisTransaksiDialog(Tabung tabung) {
    String? selectedJenisTransaksi =
        DummyData.jenisTransaksiList.first.namaJenisTransaksi;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pilih Jenis Transaksi untuk ${tabung.kodeTabung}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedJenisTransaksi,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items:
                        DummyData.jenisTransaksiList.map((JenisTransaksi jt) {
                      return DropdownMenuItem<String>(
                        value: jt.namaJenisTransaksi,
                        child: Text(jt.namaJenisTransaksi),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedJenisTransaksi = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Jenis Transaksi harus dipilih';
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
                    if (selectedJenisTransaksi != null) {
                      setState(() {
                        selectedTabungs.add({
                          'tabung': tabung,
                          'jenisTransaksi': selectedJenisTransaksi,
                        });
                      });
                      Get.back();
                    }
                  },
                  child: const Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeTabung(int index) {
    setState(() {
      selectedTabungs.removeAt(index);
    });
  }

  void _addTransaksi() {
    if (_formKey.currentState!.validate() &&
        selectedTabungs.isNotEmpty &&
        selectedMetodePembayaran != null) {
      if (DummyData.peroranganList.any((p) => p.nik == nikController.text)) {
        Get.snackbar(
          'Error',
          'NIK sudah terdaftar, silakan gunakan NIK lain',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      if (DummyData.peroranganList
          .any((p) => p.noTelepon == noTeleponController.text)) {
        Get.snackbar(
          'Error',
          'Nomor Telepon sudah terdaftar, silakan gunakan nomor lain',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final newPerorangan = Perorangan(
        idPerorangan:
            'PRG${(DummyData.peroranganList.length + 1).toString().padLeft(3, '0')}',
        namaLengkap: namaController.text,
        nik: nikController.text,
        noTelepon: noTeleponController.text,
        alamat: alamatController.text,
        idPerusahaan: null,
      );
      DummyData.peroranganList.add(newPerorangan);

      final newTransaksi = Transaksi(
        idTransaksi:
            'TRX${(DummyData.transaksiList.length + 1).toString().padLeft(3, '0')}',
        idAkun: null,
        idPerorangan: newPerorangan.idPerorangan,
        idPerusahaan: null,
        tanggalTransaksi: DateTime.now(),
        waktuTransaksi: TimeOfDay.now().format(context),
        jumlahDibayar: double.parse(jumlahDibayarController.text),
        metodePembayaran: selectedMetodePembayaran!,
        idStatusTransaksi: 'STS002',
        tanggalJatuhTempo:
            selectedTabungs.any((t) => t['jenisTransaksi'] == 'peminjaman')
                ? DateTime.now().add(const Duration(days: 30))
                : null,
        statusTransaksi: DummyData.statusTransaksiList
            .firstWhere((s) => s.idStatusTransaksi == 'STS002'),
        detailTransaksis: [],
      );

      double totalTransaksi = 0.0;
      for (var tabungData in selectedTabungs) {
        final tabung = tabungData['tabung'] as Tabung;
        final jenisTransaksiName = tabungData['jenisTransaksi'] as String;
        final jenisTransaksi = DummyData.jenisTransaksiList
            .firstWhere((jt) => jt.namaJenisTransaksi == jenisTransaksiName);
        final harga = tabung.jenisTabung?.harga ?? 0.0;
        totalTransaksi += harga;

        final newDetailTransaksi = DetailTransaksi(
          idDetailTransaksi:
              'DTX${(DummyData.detailTransaksiList.length + 1).toString().padLeft(3, '0')}',
          idTransaksi: newTransaksi.idTransaksi,
          idTabung: tabung.idTabung!,
          idJenisTransaksi: jenisTransaksi.idJenisTransaksi,
          harga: harga,
          totalTransaksi: harga,
          batasWaktuPeminjaman: jenisTransaksiName == 'peminjaman'
              ? DateTime.now().add(const Duration(days: 30))
              : null,
          tabung: tabung,
          jenisTransaksi: jenisTransaksi,
        );

        (newTransaksi.detailTransaksis ??= []).add(newDetailTransaksi);
        DummyData.detailTransaksiList.add(newDetailTransaksi);

        if (jenisTransaksiName == 'peminjaman') {
          final newPeminjaman = Peminjaman(
            idPeminjaman:
                'PJM${(DummyData.peminjamanList.length + 1).toString().padLeft(3, '0')}',
            idDetailTransaksi: newDetailTransaksi.idDetailTransaksi,
            tanggalPinjam: DateTime.now(),
            statusPinjam: 'aktif', tanggalKembali: null,
          );
          DummyData.peminjamanList.add(newPeminjaman);
        }

        tabung.idStatusTabung =
            jenisTransaksiName == 'peminjaman' ? 'STG002' : 'STG001';
        tabung.statusTabung = DummyData.statusTabungList
            .firstWhere((s) => s.idStatusTabung == tabung.idStatusTabung);
      }

      if (selectedTabungs.any((t) => t['jenisTransaksi'] == 'peminjaman')) {
        final newTagihan = Tagihan(
          idTagihan:
              'TGH${(DummyData.tagihanList.length + 1).toString().padLeft(3, '0')}',
          idTransaksi: newTransaksi.idTransaksi,
          jumlahDibayar: double.parse(jumlahDibayarController.text),
          sisa: totalTransaksi - double.parse(jumlahDibayarController.text),
          status:
              totalTransaksi - double.parse(jumlahDibayarController.text) <= 0
                  ? 'lunas'
                  : 'belum_lunas',
          tanggalBayarTagihan: null,
          hariKeterlambatan: 0,
          periodeKe: 0,
          keterangan: 'Pembayaran awal',
        );
        DummyData.tagihanList.add(newTagihan);
      }

      DummyData.transaksiList.add(newTransaksi);

      Get.back();
      Get.snackbar(
        'Sukses',
        'Transaksi berhasil dicatat',
        backgroundColor: AppColors.primaryBlue,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Harap lengkapi semua field dan pilih minimal satu tabung.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Tambah Transaksi',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Lengkap harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nikController,
                decoration: InputDecoration(
                  labelText: 'NIK',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIK harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noTeleponController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Telepon harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Tabung (Scan QR Code)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isScanning = true;
                  });
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Scan QR Code'),
                        content: SizedBox(
                          width: 300,
                          height: 300,
                          child: MobileScanner(
                            controller: scannerController,
                            onDetect: _onDetect,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              scannerController.stop();
                              setState(() {
                                isScanning = false;
                              });
                              Get.back();
                            },
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              scannerController.toggleTorch();
                            },
                            child: const Text('Toggle Flash'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (selectedTabungs.isNotEmpty) ...[
                const Text(
                  'Tabung yang Dipilih:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...selectedTabungs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tabungData = entry.value;
                  final tabung = tabungData['tabung'] as Tabung;
                  final jenisTransaksi = tabungData['jenisTransaksi'] as String;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Tabung: ${tabung.kodeTabung}'),
                      subtitle: Text('Jenis Transaksi: $jenisTransaksi'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTabung(index),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 16),
              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedMetodePembayaran,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'tunai', child: Text('Tunai')),
                  DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMetodePembayaran = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Metode Pembayaran harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: jumlahDibayarController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Dibayar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah Dibayar harus diisi';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Jumlah Dibayar harus berupa angka positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _addTransaksi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Simpan Transaksi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
