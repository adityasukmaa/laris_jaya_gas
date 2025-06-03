import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/auth_controller.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart';
import 'package:laris_jaya_gas/utils/constants.dart';
import 'package:laris_jaya_gas/utils/dummy_data.dart';
import 'package:laris_jaya_gas/models/jenis_tabung_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/models/detail_transaksi_model.dart';
import 'package:laris_jaya_gas/models/peminjaman_model.dart';
import 'package:laris_jaya_gas/models/tagihan_model.dart';
import 'package:laris_jaya_gas/models/notifikasi_model.dart';

class AjukanPeminjamanScreen extends StatefulWidget {
  const AjukanPeminjamanScreen({super.key});

  @override
  State<AjukanPeminjamanScreen> createState() => _AjukanPeminjamanScreenState();
}

class _AjukanPeminjamanScreenState extends State<AjukanPeminjamanScreen> {
  final AuthController authController = Get.find<AuthController>();
  final RxString selectedJenisTabung = RxString('');
  int jumlahTabung = 1;
  String metodePembayaran = 'Transfer';
  bool isAngsuran = false;
  int jumlahAngsuran = 1;
  String? nomorRekening;
  final _formKey = GlobalKey<FormState>();
  List<JenisTabung> jenisTabungList = [];
  Map<String, int> stokTabung = {};

  @override
  void initState() {
    super.initState();
    loadJenisTabung();
    calculateStokTabung();
  }

  void loadJenisTabung() {
    jenisTabungList = DummyData.jenisTabungList;
  }

  void calculateStokTabung() {
    for (var jenis in jenisTabungList) {
      int stok = DummyData.tabungList
          .where((tabung) =>
              tabung.idJenisTabung == jenis.idJenisTabung &&
              tabung.statusTabung?.statusTabung == 'tersedia')
          .length;
      stokTabung[jenis.idJenisTabung] = stok;
    }
  }

  void submitPeminjaman() {
    if (authController.akunId.value.isEmpty) {
      Get.snackbar(
          'Error', 'User tidak terautentikasi. Silakan login kembali.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (_formKey.currentState!.validate() &&
        selectedJenisTabung.value.isNotEmpty) {
      _formKey.currentState!.save();

      // Generate IDs
      final transaksiId =
          'TR${DummyData.transaksiList.length + 1}'.padLeft(6, '0');
      final peminjamanId =
          'PIN${DummyData.peminjamanList.length + 1}'.padLeft(6, '0');

      // Ambil data jenis tabung dan harga
      JenisTabung? selectedJenisTabungData;
      try {
        selectedJenisTabungData = DummyData.jenisTabungList.firstWhere(
          (j) => j.idJenisTabung == selectedJenisTabung.value,
          orElse: () => throw StateError('Jenis tabung tidak ditemukan'),
        );
      } catch (e) {
        Get.snackbar('Error', 'Jenis tabung tidak ditemukan.');
        return;
      }
      final harga = selectedJenisTabungData.harga;
      final totalTransaksi = harga * jumlahTabung;

      // Simulasi pemilihan tabung oleh admin (ambil tabung yang tersedia)
      final availableTabungs = DummyData.tabungList
          .where((t) =>
              t.idJenisTabung == selectedJenisTabung.value &&
              t.statusTabung?.statusTabung == 'tersedia')
          .toList();
      if (availableTabungs.length < jumlahTabung) {
        Get.snackbar('Error', 'Stok tabung tidak cukup.');
        return;
      }

      // Validasi akun
      dynamic akun;
      try {
        akun = DummyData.akunList.firstWhere(
          (a) => a.idAkun == authController.akunId.value,
          orElse: () => throw StateError('Akun tidak ditemukan'),
        );
      } catch (e) {
        Get.snackbar('Error', 'Akun pengguna tidak ditemukan.');
        return;
      }

      // Validasi status transaksi
      dynamic statusTransaksi;
      try {
        statusTransaksi = DummyData.statusTransaksiList.firstWhere(
          (s) => s.idStatusTransaksi == 'STS002',
          orElse: () => throw StateError('Status transaksi tidak ditemukan'),
        );
      } catch (e) {
        Get.snackbar('Error', 'Status transaksi tidak ditemukan.');
        return;
      }

      // Tambah transaksi ke transaksiList
      final transaksi = Transaksi(
        idTransaksi: transaksiId,
        idAkun: authController.akunId.value,
        idPerorangan: null,
        idPerusahaan: null,
        tanggalTransaksi: DateTime.now(),
        waktuTransaksi: TimeOfDay.now().format(context),
        jumlahDibayar: 0,
        metodePembayaran: metodePembayaran,
        idStatusTransaksi: 'STS002', // Pending
        tanggalJatuhTempo: DateTime.now().add(const Duration(days: 30)),
        akun: akun,
        statusTransaksi: statusTransaksi,
        detailTransaksis: [],
      );
      DummyData.transaksiList.add(transaksi);

      // Validasi jenis transaksi
      dynamic jenisTransaksi;
      try {
        jenisTransaksi = DummyData.jenisTransaksiList.firstWhere(
          (j) => j.idJenisTransaksi == 'JTR001',
          orElse: () => throw StateError('Jenis transaksi tidak ditemukan'),
        );
      } catch (e) {
        Get.snackbar('Error', 'Jenis transaksi tidak ditemukan.');
        return;
      }

      // Validasi status tabung
      dynamic statusTabung;
      try {
        statusTabung = DummyData.statusTabungList.firstWhere(
          (s) => s.idStatusTabung == 'STG002',
          orElse: () => throw StateError('Status tabung tidak ditemukan'),
        );
      } catch (e) {
        Get.snackbar('Error', 'Status tabung tidak ditemukan.');
        return;
      }

      // Tambah detail transaksi untuk setiap tabung
      final detailTransaksis = <DetailTransaksi>[];
      for (int i = 0; i < jumlahTabung; i++) {
        final tabung = availableTabungs[i];
        final detailId =
            'DTL${DummyData.detailTransaksiList.length + 1}'.padLeft(8, '0');
        final detailTransaksi = DetailTransaksi(
          idDetailTransaksi: detailId,
          idTransaksi: transaksiId,
          idTabung: tabung.idTabung!,
          idJenisTransaksi: 'JTR001', // Peminjaman
          harga: harga,
          totalTransaksi: harga,
          batasWaktuPeminjaman: DateTime.now().add(const Duration(days: 30)),
          tabung: tabung,
          jenisTransaksi: jenisTransaksi,
        );
        DummyData.detailTransaksiList.add(detailTransaksi);
        detailTransaksis.add(detailTransaksi);

        // Update status tabung menjadi 'dipinjam'
        final tabungIndex = DummyData.tabungList
            .indexWhere((t) => t.idTabung == tabung.idTabung);
        DummyData.tabungList[tabungIndex] = Tabung(
          idTabung: tabung.idTabung,
          kodeTabung: tabung.kodeTabung,
          idJenisTabung: tabung.idJenisTabung,
          idStatusTabung: 'STG002', // Dipinjam
          jenisTabung: tabung.jenisTabung,
          statusTabung: statusTabung,
        );
      }

      // Update detailTransaksis di transaksi
      transaksi.detailTransaksis = detailTransaksis;

      // Tambah peminjaman ke peminjamanList
      DummyData.peminjamanList.add(
        Peminjaman(
          idPeminjaman: peminjamanId,
          idDetailTransaksi: detailTransaksis.first.idDetailTransaksi,
          tanggalPinjam: DateTime.now(),
          statusPinjam: 'aktif',
          tanggalKembali: null,
        ),
      );

      // Validasi template notifikasi
      dynamic notifikasiTemplate;
      try {
        notifikasiTemplate = DummyData.notifikasiTemplateList.firstWhere(
          (t) => t.idTemplate == 'TMP001',
          orElse: () => throw StateError('Template notifikasi tidak ditemukan'),
        );
      } catch (e) {
        Get.snackbar('Error', 'Template notifikasi tidak ditemukan.');
        return;
      }

      // Tambah tagihan untuk setiap angsuran (jika tunai dengan angsuran)
      if (metodePembayaran == 'Tunai' && isAngsuran) {
        final angsuranPerBulan = totalTransaksi / jumlahAngsuran;
        for (int i = 1; i <= jumlahAngsuran; i++) {
          final tagihanId =
              'TAG${DummyData.tagihanList.length + 1}'.padLeft(6, '0');
          DummyData.tagihanList.add(
            Tagihan(
              idTagihan: tagihanId,
              idTransaksi: transaksiId,
              jumlahDibayar: 0,
              sisa: angsuranPerBulan,
              status: 'belum_lunas',
              tanggalBayarTagihan: null,
              hariKeterlambatan: 0,
              periodeKe: i,
              keterangan: 'Angsuran ke-$i | Pembayaran Tunai',
            ),
          );

          // Tambah notifikasi pengingat untuk setiap angsuran
          final notifikasiId =
              'NOT${DummyData.notifikasiList.length + 1}'.padLeft(6, '0');
          final tanggalJatuhTempoAngsuran =
              DateTime.now().add(Duration(days: 30 * i));
          DummyData.notifikasiList.add(
            Notifikasi(
              idNotifikasi: notifikasiId,
              idTagihan: tagihanId,
              idTemplate: 'TMP001',
              tanggalTerjadwal:
                  tanggalJatuhTempoAngsuran.subtract(const Duration(days: 3)),
              statusBaca: false,
              waktuDikirim: '09:00:00',
              template: notifikasiTemplate,
            ),
          );
        }
      } else {
        // Pembayaran tunai tanpa angsuran atau transfer
        final tagihanId =
            'TAG${DummyData.tagihanList.length + 1}'.padLeft(6, '0');
        DummyData.tagihanList.add(
          Tagihan(
            idTagihan: tagihanId,
            idTransaksi: transaksiId,
            jumlahDibayar: 0,
            sisa: totalTransaksi,
            status: 'belum_lunas',
            tanggalBayarTagihan: null,
            hariKeterlambatan: 0,
            periodeKe: 0,
            keterangan: metodePembayaran == 'Tunai'
                ? 'Pembayaran penuh | Tunai'
                : 'Pembayaran penuh | Transfer',
          ),
        );

        // Tambah notifikasi pengingat
        final notifikasiId =
            'NOT${DummyData.notifikasiList.length + 1}'.padLeft(6, '0');
        DummyData.notifikasiList.add(
          Notifikasi(
            idNotifikasi: notifikasiId,
            idTagihan: tagihanId,
            idTemplate: 'TMP001',
            tanggalTerjadwal: DateTime.now().add(const Duration(days: 27)),
            statusBaca: false,
            waktuDikirim: '09:00:00',
            template: notifikasiTemplate,
          ),
        );
      }

      // Redirect ke halaman pembayaran atau dashboard
      if (metodePembayaran == 'Transfer') {
        // Simulasi data Midtrans
        final midtransOrderId =
            'ORDER-$transaksiId-${DateTime.now().millisecondsSinceEpoch}';
        final midtransPaymentUrl =
            'https://app.sandbox.midtrans.com/snap/v1/transactions/$midtransOrderId';
        Get.snackbar(
          'Sukses',
          'Pengajuan peminjaman berhasil. Silakan lakukan pembayaran.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.to(PaymentScreen(paymentUrl: midtransPaymentUrl));
      } else {
        Get.snackbar(
          'Sukses',
          'Pengajuan peminjaman berhasil. Menunggu konfirmasi admin.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.dashboardPelanggan);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ajukan Peminjaman',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Jenis Tabung',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedJenisTabung.value.isNotEmpty
                      ? selectedJenisTabung.value
                      : null,
                  hint: const Text('Pilih jenis tabung'),
                  items: jenisTabungList.map((jenis) {
                    return DropdownMenuItem<String>(
                      value: jenis.idJenisTabung,
                      child: Text(
                          '${jenis.namaJenis} (Stok: ${stokTabung[jenis.idJenisTabung] ?? 0})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedJenisTabung.value = value;
                      setState(() {
                        jumlahTabung = 1;
                      });
                    }
                  },
                  validator: (value) => value == null
                      ? 'Pilih jenis tabung terlebih dahulu'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Jumlah Tabung',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: jumlahTabung.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan jumlah tabung',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan jumlah tabung';
                    }
                    final jumlah = int.tryParse(value);
                    if (jumlah == null || jumlah <= 0) {
                      return 'Masukkan angka yang valid';
                    }
                    if (selectedJenisTabung.value.isNotEmpty) {
                      final stok = stokTabung[selectedJenisTabung.value] ?? 0;
                      if (jumlah > stok) {
                        return 'Jumlah tabung melebihi stok tersedia ($stok)';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) {
                    jumlahTabung = int.parse(value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: metodePembayaran,
                  items: ['Transfer', 'Tunai'].map((metode) {
                    return DropdownMenuItem<String>(
                      value: metode,
                      child: Text(metode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        metodePembayaran = value;
                        if (value == 'Tunai') {
                          isAngsuran = false; // Reset angsuran untuk tunai
                          nomorRekening = null; // Reset nomor rekening
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (metodePembayaran == 'Transfer') ...[
                  const Text(
                    'Pilih Opsi Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Bayar dengan angsuran'),
                    value: isAngsuran,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          isAngsuran = value;
                        });
                      }
                    },
                  ),
                  if (isAngsuran) ...[
                    const Text(
                      'Jumlah Angsuran',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: jumlahAngsuran.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan jumlah angsuran',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan jumlah angsuran';
                        }
                        final jumlah = int.tryParse(value);
                        if (jumlah == null || jumlah <= 0) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        jumlahAngsuran = int.parse(value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nomor Rekening',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan nomor rekening',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan nomor rekening';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        nomorRekening = value;
                      },
                    ),
                  ],
                ] else ...[
                  CheckboxListTile(
                    title: const Text('Bayar dengan angsuran'),
                    value: isAngsuran,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          isAngsuran = value;
                        });
                      }
                    },
                  ),
                  if (isAngsuran) ...[
                    const Text(
                      'Jumlah Angsuran',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: jumlahAngsuran.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan jumlah angsuran',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan jumlah angsuran';
                        }
                        final jumlah = int.tryParse(value);
                        if (jumlah == null || jumlah <= 0) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        jumlahAngsuran = int.parse(value!);
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: submitPeminjaman,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Ajukan Peminjaman',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping), label: 'Peminjaman'),
          BottomNavigationBarItem(
              icon: Icon(Icons.refresh), label: 'Isi Ulang'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Tagihan'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed('/pelanggan/dashboard');
              break;
            case 1:
              Get.toNamed('/pelanggan/ajukan-peminjaman');
              break;
            case 2:
              Get.toNamed('/pelanggan/ajukan-isi-ulang');
              break;
            case 3:
              Get.toNamed('/pelanggan/tagihan');
              break;
          }
        },
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.paymentUrl});

  final String paymentUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Silakan lakukan pembayaran melalui link berikut:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              paymentUrl,
              style: const TextStyle(fontSize: 14, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.dashboardPelanggan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Kembali ke Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
