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

class AjukanIsiUlangScreen extends StatefulWidget {
  const AjukanIsiUlangScreen({super.key});

  @override
  State<AjukanIsiUlangScreen> createState() => _AjukanIsiUlangScreenState();
}

class _AjukanIsiUlangScreenState extends State<AjukanIsiUlangScreen> {
  final AuthController? authController = Get.find<AuthController>();
  final RxString selectedJenisTabung = RxString('');
  int jumlahTabung = 1;
  String metodePembayaran = 'Tunai'; // Hanya tunai untuk isi ulang
  final _formKey = GlobalKey<FormState>();
  List<JenisTabung> jenisTabungList = [];
  Map<String, int> stokTabung = {};

  @override
  void initState() {
    super.initState();
    if (authController == null) {
      Get.snackbar(
          'Error', 'AuthController tidak tersedia. Silakan coba lagi.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }
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
              tabung.statusTabung?.statusTabung ==
                  'kosong') // Hanya tabung kosong untuk isi ulang
          .length;
      stokTabung[jenis.idJenisTabung] = stok;
    }
  }

  void submitIsiUlang() {
    if (authController == null || authController!.userId.value == null) {
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
      final isiUlangId =
          'IUL${DummyData.peminjamanList.length + 1}'.padLeft(6, '0');

      // Ambil data jenis tabung dan harga isi ulang
      final selectedJenisTabungData = DummyData.jenisTabungList
          .firstWhere((j) => j.idJenisTabung == selectedJenisTabung.value);
      final harga = selectedJenisTabungData.harga; // Harga isi ulang
      final totalTransaksi = harga * jumlahTabung;

      // Pilih tabung kosong untuk diisi ulang
      final availableTabungs = DummyData.tabungList
          .where((t) =>
              t.idJenisTabung == selectedJenisTabung.value &&
              t.statusTabung?.statusTabung == 'kosong')
          .toList();
      if (availableTabungs.length < jumlahTabung) {
        Get.snackbar(
            'Error', 'Stok tabung kosong tidak cukup untuk isi ulang.');
        return;
      }

      // Tambah transaksi ke transaksiList
      final transaksi = Transaksi(
        idTransaksi: transaksiId,
        idAkun: authController!.userId.value!,
        idPerorangan: null,
        idPerusahaan: null,
        tanggalTransaksi: DateTime.now(),
        waktuTransaksi: TimeOfDay.now().format(context),
        jumlahDibayar: 0,
        metodePembayaran: metodePembayaran,
        idStatusTransaksi: 'STS002', // Pending
        tanggalJatuhTempo: DateTime.now()
            .add(const Duration(days: 7)), // 7 hari untuk pengambilan
        akun: DummyData.akunList
            .firstWhere((a) => a.idAkun == authController!.userId.value!),
        statusTransaksi: DummyData.statusTransaksiList
            .firstWhere((s) => s.idStatusTransaksi == 'STS002'),
        detailTransaksis: [],
      );
      DummyData.transaksiList.add(transaksi);

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
          idJenisTransaksi: 'JTR002', // Isi ulang
          harga: harga,
          totalTransaksi: harga,
          batasWaktuPeminjaman: DateTime.now().add(const Duration(days: 7)),
          tabung: tabung,
          jenisTransaksi: DummyData.jenisTransaksiList
              .firstWhere((j) => j.idJenisTransaksi == 'JTR002'),
        );
        DummyData.detailTransaksiList.add(detailTransaksi);
        detailTransaksis.add(detailTransaksi);

        // Update status tabung menjadi 'tersedia' setelah isi ulang
        final tabungIndex = DummyData.tabungList
            .indexWhere((t) => t.idTabung == tabung.idTabung);
        DummyData.tabungList[tabungIndex] = Tabung(
          idTabung: tabung.idTabung,
          kodeTabung: tabung.kodeTabung,
          idJenisTabung: tabung.idJenisTabung,
          idStatusTabung: 'STG001', // Tersedia
          jenisTabung: tabung.jenisTabung,
          statusTabung: DummyData.statusTabungList
              .firstWhere((s) => s.idStatusTabung == 'STG001'),
        );
      }

      // Update detailTransaksis di transaksi
      transaksi.detailTransaksis = detailTransaksis;

      // Tambah entri isi ulang ke peminjamanList (meskipun dinamakan peminjamanList, digunakan untuk tracking)
      DummyData.peminjamanList.add(
        Peminjaman(
          idPeminjaman: isiUlangId,
          idDetailTransaksi: detailTransaksis.first.idDetailTransaksi,
          tanggalPinjam: DateTime.now(),
          statusPinjam: 'selesai', // Proses isi ulang langsung selesai
          tanggalKembali: DateTime.now(),
        ),
      );

      // Tambah tagihan
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
          keterangan: 'Isi ulang tabung',
        ),
      );

      // Tambah notifikasi pengingat pengambilan
      final notifikasiId =
          'NOT${DummyData.notifikasiList.length + 1}'.padLeft(6, '0');
      DummyData.notifikasiList.add(
        Notifikasi(
          idNotifikasi: notifikasiId,
          idTagihan: tagihanId,
          idTemplate: 'TMP001',
          tanggalTerjadwal:
              DateTime.now().add(const Duration(days: 7)), // Pengingat 7 hari
          statusBaca: false,
          waktuDikirim: '09:00:00',
          template: DummyData.notifikasiTemplateList
              .firstWhere((t) => t.idTemplate == 'TMP001'),
        ),
      );

      // Redirect
      Get.snackbar(
        'Sukses',
        'Pengajuan isi ulang berhasil. Menunggu konfirmasi admin.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(AppRoutes.dashboardPelanggan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Isi Ulang'),
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
                          '${jenis.namaJenis} (Stok Kosong: ${stokTabung[jenis.idJenisTabung] ?? 0})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedJenisTabung.value = value;
                      setState(() {
                        jumlahTabung = 1; // Reset jumlah tabung
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
                    final jumlah = int.parse(value);
                    if (jumlah <= 0) {
                      return 'Masukkan angka yang valid';
                    }
                    if (selectedJenisTabung.value.isNotEmpty) {
                      final stok = stokTabung[selectedJenisTabung.value] ?? 0;
                      if (jumlah > stok) {
                        return 'Jumlah tabung melebihi stok kosong tersedia ($stok)';
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
                  items: ['Tunai'].map((metode) {
                    return DropdownMenuItem<String>(
                      value: metode,
                      child: Text(metode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        metodePembayaran = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: submitIsiUlang,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Ajukan Isi Ulang',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
