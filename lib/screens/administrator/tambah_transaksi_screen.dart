import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/detail_transaksi_model.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/perusahaan_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/models/peminjaman_model.dart';
import 'package:laris_jaya_gas/models/tagihan_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';

class TambahTransaksiScreen extends StatefulWidget {
  const TambahTransaksiScreen({super.key});

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCustomerType =
      'perorangan_tanpa_akun'; // Default tipe pelanggan
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController noTeleponController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController jumlahDibayarController = TextEditingController();
  String? selectedPeroranganId; // Untuk memilih perorangan dengan akun
  String? selectedPerusahaanId; // Untuk memilih perusahaan dengan akun
  final TextEditingController namaPerusahaanController =
      TextEditingController();
  final TextEditingController noTeleponPerusahaanController =
      TextEditingController();

  List<Map<String, dynamic>> selectedTabungs = [];
  String? selectedMetodePembayaran = 'tunai';

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    noTeleponController.dispose();
    alamatController.dispose();
    jumlahDibayarController.dispose();
    namaPerusahaanController.dispose();
    noTeleponPerusahaanController.dispose();
    super.dispose();
  }

  void _onTabungSelected(Map<String, dynamic> tabungData) {
    print('Callback onTabungSelected called with: $tabungData'); // Log callback
    setState(() {
      selectedTabungs.add(tabungData);
      print('Updated selectedTabungs: $selectedTabungs'); // Log setelah update
    });
  }

  void _removeTabung(int index) {
    setState(() {
      selectedTabungs.removeAt(index);
      print(
          'Tabung removed at index $index, new list: $selectedTabungs'); // Log setelah hapus
    });
  }

  void _addTransaksi() {
    print(
        'Adding transaction with selectedTabungs: $selectedTabungs'); // Log sebelum simpan
    if (_formKey.currentState!.validate() &&
        selectedTabungs.isNotEmpty &&
        selectedMetodePembayaran != null) {
      String? idPelanggan;
      String? idAkun = null;

      // Tentukan tipe pelanggan dan ID
      if (selectedCustomerType == 'perorangan_tanpa_akun') {
        if (DummyData.peroranganList.any((p) => p.nik == nikController.text)) {
          Get.snackbar(
            'Error',
            'NIK sudah terdaftar, silakan gunakan NIK lain',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
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
            duration: const Duration(seconds: 3),
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
        idPelanggan = newPerorangan.idPerorangan;
      } else if (selectedCustomerType == 'perorangan_dengan_akun') {
        if (selectedPeroranganId == null) {
          Get.snackbar(
            'Error',
            'Silakan pilih perorangan dengan akun',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }
        idPelanggan = selectedPeroranganId;
        idAkun =
            'AKN001'; // Placeholder untuk akun, sesuaikan dengan logika autentikasi
      } else if (selectedCustomerType == 'perusahaan_dengan_akun') {
        if (selectedPerusahaanId == null) {
          Get.snackbar(
            'Error',
            'Silakan pilih perusahaan dengan akun',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }
        idPelanggan = selectedPerusahaanId;
        idAkun =
            'AKN002'; // Placeholder untuk akun, sesuaikan dengan logika autentikasi
      }

      final newTransaksi = Transaksi(
        idTransaksi:
            'TRX${(DummyData.transaksiList.length + 1).toString().padLeft(3, '0')}',
        idAkun: idAkun,
        idPerorangan: selectedCustomerType == 'perorangan_tanpa_akun' ||
                selectedCustomerType == 'perorangan_dengan_akun'
            ? idPelanggan
            : null,
        idPerusahaan: selectedCustomerType == 'perusahaan_dengan_akun'
            ? idPelanggan
            : null,
        tanggalTransaksi: DateTime.now(),
        waktuTransaksi: TimeOfDay.now().format(context),
        jumlahDibayar: double.parse(jumlahDibayarController.text),
        metodePembayaran: selectedMetodePembayaran!,
        idStatusTransaksi: 'STS002', // Pending
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
            statusPinjam: 'aktif',
            tanggalKembali: null,
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
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Error',
        'Harap lengkapi semua field dan pilih minimal satu tabung.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _selectTabungManually() {
    String? selectedTabungId;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pilih Tabung Secara Manual'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedTabungId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: 'Pilih Tabung',
                    ),
                    items: DummyData.tabungList
                        .where((tabung) =>
                            tabung.statusTabung?.statusTabung != 'dipinjam')
                        .map((Tabung tabung) {
                      return DropdownMenuItem<String>(
                        value: tabung.idTabung,
                        child: Text(
                            '${tabung.kodeTabung} (${tabung.jenisTabung?.namaJenis ?? 'Unknown'})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTabungId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Tabung harus dipilih';
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
                    if (selectedTabungId != null) {
                      final tabung = DummyData.tabungList.firstWhere(
                        (t) => t.idTabung == selectedTabungId,
                      );
                      if (!selectedTabungs.any(
                          (t) => t['tabung'].kodeTabung == tabung.kodeTabung)) {
                        _showInitialTransactionDialog(tabung);
                      } else {
                        Get.snackbar(
                          'Peringatan',
                          'Tabung ${tabung.kodeTabung} sudah dipilih sebelumnya!',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                      }
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

  void _showInitialTransactionDialog(Tabung tabung) {
    String? selectedJenisTransaksi;

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
                      labelText: 'Jenis Transaksi',
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'peminjaman',
                        child: const Text('Peminjaman'),
                      ),
                      DropdownMenuItem(
                        value: 'isi ulang',
                        child: const Text('Isi Ulang'),
                      ),
                    ],
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
                        print(
                            'Manually added tabung: ${tabung.kodeTabung}, new list: $selectedTabungs'); // Log setelah tambah manual
                      });
                      Get.back();
                    } else {
                      Get.snackbar(
                        'Error',
                        'Harap pilih jenis transaksi!',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
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
              const Text(
                'Tipe Pelanggan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCustomerType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Tipe Pelanggan',
                ),
                items: [
                  DropdownMenuItem(
                    value: 'perorangan_tanpa_akun',
                    child: const Text('Perorangan Tanpa Akun'),
                  ),
                  DropdownMenuItem(
                    value: 'perorangan_dengan_akun',
                    child: const Text('Perorangan Dengan Akun'),
                  ),
                  DropdownMenuItem(
                    value: 'perusahaan_dengan_akun',
                    child: const Text('Perusahaan Dengan Akun'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCustomerType = value;
                    selectedPeroranganId = null;
                    selectedPerusahaanId = null;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Tipe Pelanggan harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (selectedCustomerType == 'perorangan_tanpa_akun') ...[
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
              ] else if (selectedCustomerType == 'perorangan_dengan_akun') ...[
                DropdownButtonFormField<String>(
                  value: selectedPeroranganId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Perorangan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: DummyData.peroranganList.map((Perorangan p) {
                    return DropdownMenuItem<String>(
                      value: p.idPerorangan,
                      child: Text('${p.namaLengkap} (NIK: ${p.nik})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPeroranganId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Perorangan harus dipilih';
                    }
                    return null;
                  },
                ),
              ] else if (selectedCustomerType == 'perusahaan_dengan_akun') ...[
                DropdownButtonFormField<String>(
                  value: selectedPerusahaanId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Perusahaan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: DummyData.perusahaanList.map((Perusahaan p) {
                    return DropdownMenuItem<String>(
                      value: p.idPerusahaan,
                      child: Text('${p.namaPerusahaan}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPerusahaanId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Perusahaan harus dipilih';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Pilih Tabung',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print(
                            'Navigating to QRScanScreen with selectedTabungs: $selectedTabungs'); // Log sebelum navigasi
                        Get.toNamed(AppRoutes.qrScan, arguments: {
                          'onTabungSelected': _onTabungSelected,
                          'selectedTabungs': selectedTabungs,
                        });
                      },
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Colors.white),
                      label: const Text('Scan QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectTabungManually,
                      icon: const Icon(Icons.list, color: Colors.white),
                      label: const Text('Pilih Manual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
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
                  labelText: 'Metode Pembayaran',
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
                    backgroundColor: AppColors.secondary,
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
