import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/tabung_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class TambahTransaksiScreen extends StatefulWidget {
  const TambahTransaksiScreen({super.key});

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCustomerType = 'perorangan_tanpa_akun';
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController noTeleponController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController jumlahDibayarController = TextEditingController();
  String? selectedPeroranganId;
  String? selectedPerusahaanId;
  List<Map<String, dynamic>> selectedTabungs = [];
  String? selectedMetodePembayaran = 'tunai';
  late ApiService apiService;
  List<Tabung> availableTabungs = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      apiService = ApiService(prefs);
      _fetchAvailableTabungs();
    });
  }

  Future<void> _fetchAvailableTabungs() async {
    availableTabungs = await apiService.getAllTabungs();
    setState(() {});
  }

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    noTeleponController.dispose();
    alamatController.dispose();
    jumlahDibayarController.dispose();
    super.dispose();
  }

  void _onTabungSelected(Map<String, dynamic> tabungData) {
    setState(() {
      selectedTabungs.add(tabungData);
    });
  }

  void _removeTabung(int index) {
    setState(() {
      selectedTabungs.removeAt(index);
    });
  }

  void _addTransaksi() async {
    if (_formKey.currentState!.validate() &&
        selectedTabungs.isNotEmpty &&
        selectedMetodePembayaran != null) {
      String? idPelanggan;
      String? idAkun;

      if (selectedCustomerType == 'perorangan_tanpa_akun') {
        idPelanggan = 'PRG${DateTime.now().millisecondsSinceEpoch}';
      } else if (selectedCustomerType == 'perorangan_dengan_akun') {
        idPelanggan = selectedPeroranganId;
        idAkun = Get.find<AuthController>().akunId.value;
      } else if (selectedCustomerType == 'perusahaan_dengan_akun') {
        idPelanggan = selectedPerusahaanId;
        idAkun = Get.find<AuthController>().akunId.value;
      }

      final transaksiData = {
        'id_akuns': idAkun != null ? int.parse(idAkun) : null,
        'id_perorangan':
            selectedCustomerType!.contains('perorangan') ? idPelanggan : null,
        'id_perusahaan': selectedCustomerType == 'perusahaan_dengan_akun'
            ? idPelanggan
            : null,
        'jumlah_dibayar': double.parse(jumlahDibayarController.text),
        'metode_pembayaran': selectedMetodePembayaran!,
        'detail_transaksis': selectedTabungs.map((tabungData) {
          final tabung = tabungData['tabung'] as Tabung;
          return {
            'id_tabung': tabung.idTabung,
            'id_jenis_transaksi':
                tabungData['jenisTransaksi'] == 'peminjaman' ? 1 : 2,
            'harga': tabung.jenisTabung?.harga ?? 0.0,
          };
        }).toList(),
      };

      final success = await apiService.createTransaksi(transaksiData);
      if (success) {
        Get.back();
        Get.snackbar('Sukses', 'Transaksi berhasil dicatat',
            backgroundColor: AppColors.primaryBlue, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Gagal menyimpan transaksi',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar('Error', 'Lengkapi semua field dan pilih tabung',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _selectTabungManually() {
    String? selectedTabungId;
    String? selectedJenisTransaksi;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Pilih Tabung Secara Manual'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedTabungId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      labelText: 'Pilih Tabung',
                    ),
                    items: availableTabungs
                        .where((tabung) =>
                            tabung.statusTabung?.statusTabung == 'tersedia' &&
                            !selectedTabungs.any((t) =>
                                t['tabung'].kodeTabung == tabung.kodeTabung))
                        .map((tabung) {
                      return DropdownMenuItem<String>(
                        value: tabung.idTabung,
                        child: Text(
                            '${tabung.kodeTabung} (${tabung.jenisTabung?.namaJenis})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedTabungId = value;
                        selectedJenisTransaksi = null;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Tabung harus dipilih' : null,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedJenisTransaksi,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      labelText: 'Jenis Transaksi',
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'peminjaman', child: Text('Peminjaman')),
                      DropdownMenuItem(
                          value: 'isi ulang', child: Text('Isi Ulang')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedJenisTransaksi = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Jenis Transaksi harus dipilih' : null,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    if (selectedTabungId != null &&
                        selectedJenisTransaksi != null) {
                      final tabung = availableTabungs
                          .firstWhere((t) => t.idTabung == selectedTabungId);
                      setState(() {
                        selectedTabungs.add({
                          'tabung': tabung,
                          'jenisTransaksi': selectedJenisTransaksi,
                        });
                      });
                      Get.back();
                    } else {
                      Get.snackbar('Error', 'Pilih tabung dan jenis transaksi!',
                          backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  child: Text('Pilih'),
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Tambah Transaksi', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipe Pelanggan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCustomerType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  labelText: 'Tipe Pelanggan',
                ),
                items: [
                  DropdownMenuItem(
                      value: 'perorangan_tanpa_akun',
                      child: Text('Perorangan Tanpa Akun')),
                  DropdownMenuItem(
                      value: 'perorangan_dengan_akun',
                      child: Text('Perorangan Dengan Akun')),
                  DropdownMenuItem(
                      value: 'perusahaan_dengan_akun',
                      child: Text('Perusahaan Dengan Akun')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCustomerType = value;
                    selectedPeroranganId = null;
                    selectedPerusahaanId = null;
                  });
                },
                validator: (value) =>
                    value == null ? 'Tipe Pelanggan harus dipilih' : null,
              ),
              SizedBox(height: 16),
              if (selectedCustomerType == 'perorangan_tanpa_akun') ...[
                TextFormField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama Lengkap harus diisi' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: nikController,
                  decoration: InputDecoration(
                    labelText: 'NIK',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'NIK harus diisi' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: noTeleponController,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nomor Telepon harus diisi' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: alamatController,
                  decoration: InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Alamat harus diisi' : null,
                ),
              ],
              SizedBox(height: 16),
              Text('Pilih Tabung',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(AppRoutes.qrScan, arguments: {
                          'onTabungSelected': _onTabungSelected,
                          'selectedTabungs': selectedTabungs,
                        });
                      },
                      icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                      label: Text('Scan QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectTabungManually,
                      icon: Icon(Icons.list, color: Colors.white),
                      label: Text('Pilih Manual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (selectedTabungs.isNotEmpty) ...[
                Text('Tabung yang Dipilih:',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                ...selectedTabungs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tabungData = entry.value;
                  final tabung = tabungData['tabung'] as Tabung;
                  final jenisTransaksi = tabungData['jenisTransaksi'] as String;
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Tabung: ${tabung.kodeTabung}'),
                      subtitle: Text('Jenis Transaksi: $jenisTransaksi'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTabung(index),
                      ),
                    ),
                  );
                }),
              ],
              SizedBox(height: 16),
              Text('Metode Pembayaran',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedMetodePembayaran,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  labelText: 'Metode Pembayaran',
                ),
                items: [
                  DropdownMenuItem(value: 'tunai', child: Text('Tunai')),
                  DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMetodePembayaran = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Metode Pembayaran harus dipilih' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: jumlahDibayarController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Dibayar',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null
                        ? 'Jumlah Dibayar harus valid'
                        : null,
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _addTransaksi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    minimumSize: Size(double.infinity, 50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Simpan Transaksi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
