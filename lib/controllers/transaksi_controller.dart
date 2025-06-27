import 'package:get/get.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/models/transaksi_model.dart';
import 'package:laris_jaya_gas/services/api_service.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class TransaksiController extends GetxController {
  final ApiService _apiService = ApiService();
  final transaksiList = <Transaksi>[].obs;
  final filteredTransaksiList = <Transaksi>[].obs;
  final selectedStatusTransaksi = 'Semua'.obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var pelangganList = <Perorangan>[].obs;

  // --- STATE UNTUK FORM ---
  final selectedPelanggan = ''.obs;
  final selectedPelangganData = Rx<Perorangan?>(null);
  var details = <Map<String, dynamic>>[].obs;
  var totalTransaksi = 0.0.obs;
  var metodePembayaran = 'tunai'.obs;
  var jumlahDibayar = 0.0.obs;

  // --- STATE BARU UNTUK PILIH MANUAL ---
  final availableTubes = <Tabung>[].obs;

  @override
  void onInit() {
    fetchPelanggan();
    fetchAllTransaksi();
    fetchAvailableTubes();
    super.onInit();
  }

  // --- FUNGSI BARU: Mengambil tabung yang tersedia ---
  // Mengambil tabung yang tersedia untuk fitur "Pilih Manual"
  Future<void> fetchAvailableTubes() async {
    try {
      isLoading(true);
      final response = await _apiService.getTabungTersedia();
      availableTubes.assignAll(response);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data tabung tersedia: $e',
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
    } finally {
      isLoading(false);
    }
  }

  // --- FUNGSI UTAMA UNTUK VALIDASI KODE TABUNG ---
  Future<Tabung?> validateAndGetTabung(String kode) async {
    try {
      isLoading(true);
      final tabung = await _apiService.getTabungByKode(kode);

      // Pengecekan 1: Tabung tidak ditemukan sama sekali
      if (tabung == null) {
        throw Exception('Tabung dengan kode $kode tidak ditemukan');
      }

      // --- PERBAIKAN DI SINI ---
      // Pengecekan 2: Status tabung tidak "tersedia"
      if (tabung.statusTabung?.statusTabung != 'tersedia') {
        // Ambil status aktual dari tabung
        final statusAktual =
            tabung.statusTabung?.statusTabung ?? 'tidak diketahui';
        // Buat pesan error yang lebih spesifik
        throw Exception(
            'Tabung ${tabung.kodeTabung} tidak bisa digunakan. Status: $statusAktual.');
      }
      // --- AKHIR PERBAIKAN ---

      // Pengecekan 3: Tabung sudah ada di daftar rincian
      if (details.any((d) => d['kode_tabung'] == tabung.kodeTabung)) {
        throw Exception(
            'Tabung ${tabung.kodeTabung} sudah ada di dalam rincian');
      }

      // Jika semua validasi lolos, kembalikan objek tabung
      return tabung;
    } catch (e) {
      // Menghilangkan "Exception: " dari pesan agar lebih bersih di Snackbar
      Get.snackbar(
          'Error Validasi', e.toString().replaceFirst("Exception: ", ""),
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAllTransaksi() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _apiService.getAllTransaksi();
      print('Fetched ${response.length} transaksi');
      transaksiList.assignAll(response);
      applyFilter();
    } catch (e) {
      errorMessage('Error: ${e.toString()}');
      print('Error fetching transactions: $e');
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
    } finally {
      isLoading(false);
    }
  }

  void applyFilter() {
    if (selectedStatusTransaksi.value == 'Semua') {
      filteredTransaksiList.assignAll(transaksiList);
    } else {
      filteredTransaksiList.assignAll(transaksiList
          .where((transaksi) =>
              (transaksi.statusTransaksi ?? '').toLowerCase() ==
              selectedStatusTransaksi.value.toLowerCase())
          .toList());
    }
    print('Filtered Transaksi List: ${filteredTransaksiList.length} items');
  }

  Future<void> fetchPelanggan() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _apiService.getAllPelanggan();
      pelangganList.assignAll(response);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
    } finally {
      isLoading(false);
    }
  }

  // Fungsi untuk menambahkan item ke rincian transaksi
  void tambahDetail(Tabung tabung, String jenisTransaksi) {
    final idJenisTransaksi = jenisTransaksi == 'Peminjaman' ? '1' : '2';
    final harga = tabung.jenisTabung?.harga ?? 0.0;

    final detail = {
      'id_tabung': tabung.idTabung,
      'id_jenis_transaksi': idJenisTransaksi,
      'harga': harga,
      'kode_tabung': tabung.kodeTabung,
      'nama_jenis': tabung.jenisTabung?.namaJenis,
      'tipe_transaksi_display': jenisTransaksi, // Untuk ditampilkan di UI
    };
    details.add(detail);
    totalTransaksi.value += harga;
  }

  // Fungsi untuk menghapus item dari rincian transaksi
  void hapusDetail(int index) {
    totalTransaksi.value -= details[index]['harga'] as double;
    details.removeAt(index);
  }

  void resetForm() {
    selectedPelanggan('');
    selectedPelangganData.value = null;
    details.clear();
    totalTransaksi(0.0);
    jumlahDibayar(0.0);
    metodePembayaran('tunai');
  }

  Future<void> buatTransaksi() async {
    if (details.isEmpty) {
      Get.snackbar('Error', 'Tambahkan setidaknya satu tabung',
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
      return;
    }
    if (selectedPelanggan.value.isEmpty) {
      Get.snackbar('Error', 'Pilih pelanggan terlebih dahulu',
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
      return;
    }
    if (metodePembayaran.value.isEmpty) {
      Get.snackbar('Error', 'Pilih metode pembayaran',
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
      return;
    }

    try {
      isLoading(true);
      errorMessage('');

      final pelanggan = pelangganList.firstWhere(
        (p) =>
            p.idAkun.toString() == selectedPelanggan.value ||
            p.idPerorangan.toString() == selectedPelanggan.value,
        orElse: () => throw Exception('Pelanggan tidak ditemukan'),
      );
      final payload = {
        'tipe_pelanggan': pelanggan.idAkun != null
            ? 'perorangan_dengan_akun'
            : 'perorangan_tanpa_akun',
        if (pelanggan.idAkun == null)
          'pelanggan': {
            'nama_lengkap': pelanggan.namaLengkap,
            'nik': pelanggan.nik,
            'no_telepon': pelanggan.noTelepon,
            'alamat': pelanggan.alamat,
          },
        'id_akun': pelanggan.idAkun?.toString(),
        'id_perorangan': pelanggan.idPerorangan?.toString(),
        'id_perusahaan': pelanggan.idPerusahaan?.toString(),
        'jumlah_dibayar': jumlahDibayar.value,
        'metode_pembayaran': metodePembayaran.value,
        'detail_transaksis': details
            .map((detail) => {
                  'id_tabung': detail['id_tabung'],
                  'id_jenis_transaksi': detail['id_jenis_transaksi'],
                  'harga': detail['harga'],
                })
            .toList(),
        'keterangan': 'Transaksi dibuat melalui aplikasi',
      };

      final transaksi = await _apiService.createTransaksi(payload);
      transaksiList.insert(0, transaksi);
      resetForm();
      Get.toNamed('/administrator/transaksi');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchTransaksi() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _apiService.getAllTransaksi();
      transaksiList.assignAll(response);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRiwayatTransaksi() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _apiService.getRiwayatTransaksi();
      transaksiList.assignAll(response);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateTransaksi(String id, Map<String, dynamic> payload) async {
    try {
      isLoading(true);
      errorMessage('');
      final transaksi = await _apiService.updateTransaksi(id, payload);
      final index = transaksiList.indexWhere((t) => t.idTransaksi == id);
      if (index != -1) {
        transaksiList[index] = transaksi;
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.redFlame, colorText: AppColors.white);
    } finally {
      isLoading(false);
    }
  }
}
