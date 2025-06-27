import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/controllers/transaksi_controller.dart';
import 'package:laris_jaya_gas/models/perorangan_model.dart';
import 'package:laris_jaya_gas/models/tabung_model.dart';
import 'package:laris_jaya_gas/utils/constants.dart';

class TambahTransaksiScreen extends StatelessWidget {
  TambahTransaksiScreen({super.key});

  final TransaksiController controller = Get.find<TransaksiController>();
  final _formKey = GlobalKey<FormState>();
  final _jumlahDibayarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Panggil resetForm saat halaman pertama kali dibangun
    // Dijalankan setelah frame pertama selesai untuk menghindari konflik state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetForm();
    });

    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        title: const Text('Tambah Transaksi Baru'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('1. Informasi Pelanggan'),
              _buildPelangganDropdown(),

              // --- TAMBAHKAN BAGIAN INI ---
              // Widget ini akan muncul/hilang secara dinamis
              Obx(() {
                if (controller.selectedPelangganData.value == null) {
                  return const SizedBox
                      .shrink(); // Sembunyikan jika tidak ada pelanggan dipilih
                }
                return _buildDetailPelangganCard(
                    controller.selectedPelangganData.value!);
              }),
              // --- AKHIR BAGIAN TAMBAHAN ---

              const SizedBox(height: AppSizes.padding * 1.5),

              _buildSectionTitle('2. Tambah Tabung'),
              _buildTambahTabungSection(context), // Menggunakan metode baru
              const SizedBox(height: AppSizes.padding),
              _buildDetailTransaksiList(),
              const SizedBox(height: AppSizes.padding * 1.5),
              _buildSectionTitle('3. Rincian Pembayaran'),
              _buildRincianPembayaran(),
              const SizedBox(height: AppSizes.padding * 2),
              _buildSimpanButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildPelangganDropdown() {
    return Obx(() {
      if (controller.pelangganList.isEmpty) {
        return const Center(child: Text("Memuat data pelanggan..."));
      }
      return DropdownButtonFormField<String>(
        decoration: _inputDecoration('Pilih Pelanggan'),
        isExpanded: true,
        hint: const Text('Pilih salah satu pelanggan'),
        value: controller.selectedPelanggan.value.isEmpty
            ? null
            : controller.selectedPelanggan.value,
        items: controller.pelangganList.map((pelanggan) {
          return DropdownMenuItem<String>(
            value: pelanggan.idPerorangan.toString(),
            child: Text(pelanggan.namaLengkap ?? 'Tanpa Nama'),
          );
        }).toList(),
        onChanged: (value) {
          // --- UBAH BAGIAN INI ---
          if (value != null) {
            // Simpan ID pelanggan
            controller.selectedPelanggan.value = value;
            // Cari dan simpan seluruh objek pelanggan ke state baru
            try {
              controller.selectedPelangganData.value = controller.pelangganList
                  .firstWhere((p) => p.idPerorangan.toString() == value);
            } catch (e) {
              controller.selectedPelangganData.value = null;
            }
          }
          // --- AKHIR PERUBAHAN ---
        },
        validator: (value) =>
            value == null || value.isEmpty ? 'Pelanggan wajib dipilih' : null,
      );
    });
  }

  // --- TAMBAHKAN WIDGET BARU INI ---
  Widget _buildDetailPelangganCard(Perorangan pelanggan) {
    return Card(
      margin: const EdgeInsets.only(top: AppSizes.padding),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Detail Pelanggan Terpilih",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 16),
            _buildInfoRow(Icons.person_outline, "Nama", pelanggan.namaLengkap),
            _buildInfoRow(Icons.credit_card_outlined, "NIK", pelanggan.nik),
            _buildInfoRow(
                Icons.phone_outlined, "No. Telepon", pelanggan.noTelepon),
            _buildInfoRow(
                Icons.location_on_outlined, "Alamat", pelanggan.alamat),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text("$label: ", style: TextStyle(color: Colors.grey[700])),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  // --- AKHIR WIDGET BARU ---

  // ... (Sisa kode: _buildTambahTabungSection, _buildDetailTransaksiList, dll. tetap sama)

  // --- WIDGET BARU: Menggantikan _buildTambahTabungSection yang lama ---
  Widget _buildTambahTabungSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
                label: const Text('Scan Kode QR'),
                onPressed: () async {
                  // 1. Pindah ke halaman scan dan tunggu hasilnya
                  final result =
                      await Get.toNamed('/administrator/qr-scan-tabung');

                  // 2. Jika ada hasil scan (bukan null)
                  if (result != null && result is String) {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    // 3. Panggil controller untuk validasi kode
                    final tabung =
                        await controller.validateAndGetTabung(result);
                    Get.back(); // Tutup loading dialog

                    // 4. Jika validasi berhasil dan tabung ditemukan
                    if (tabung != null) {
                      // 5. Tampilkan dialog konfirmasi jenis transaksi
                      _showJenisTransaksiDialog(context, tabung);
                    }
                  }
                },
                style: _buttonStyle(AppColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list_alt, color: AppColors.white),
                label: const Text('Pilih Manual'),
                onPressed: () => _showPilihManualDialog(context),
                style: _buttonStyle(AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG BARU UNTUK PILIH MANUAL ---
  void _showPilihManualDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Tabung Tersedia'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.availableTubes.isEmpty) {
              return const Text('Tidak ada tabung yang tersedia saat ini.');
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.availableTubes.length,
              itemBuilder: (_, index) {
                final tabung = controller.availableTubes[index];
                final sudahDipilih = controller.details
                    .any((d) => d['kode_tabung'] == tabung.kodeTabung);
                return ListTile(
                  title: Text(tabung.kodeTabung ?? 'Tanpa Kode'),
                  subtitle: Text(tabung.jenisTabung?.namaJenis ?? '-'),
                  trailing: Text('Rp ${tabung.jenisTabung?.harga ?? 0}'),
                  enabled: !sudahDipilih,
                  tileColor: sudahDipilih ? Colors.grey.shade300 : null,
                  onTap: sudahDipilih
                      ? null
                      : () {
                          Get.back();
                          _showJenisTransaksiDialog(context, tabung);
                        },
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal'))
        ],
      ),
    );
  }

  // --- DIALOG BARU UNTUK KONFIRMASI JENIS TRANSAKSI ---
  void _showJenisTransaksiDialog(BuildContext context, Tabung tabung) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pilih Jenis Transaksi'),
        content:
            Text('Pilih jenis transaksi untuk tabung ${tabung.kodeTabung}:'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: const Text('Isi Ulang'),
            onPressed: () {
              controller.tambahDetail(tabung, 'Isi Ulang');
              Get.back();
            },
            style: _buttonStyle(AppColors.secondary),
          ),
          ElevatedButton(
            child: const Text('Peminjaman'),
            onPressed: () {
              controller.tambahDetail(tabung, 'Peminjaman');
              Get.back();
            },
            style: _buttonStyle(AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTransaksiList() {
    return Obx(() {
      if (controller.details.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Belum ada tabung yang ditambahkan.',
                style: TextStyle(color: Colors.grey)),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.details.length,
        itemBuilder: (context, index) {
          final detail = controller.details[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: detail['id_jenis_transaksi'] == '1'
                    ? AppColors.primaryBlue
                    : AppColors.secondary,
                child: Icon(
                  detail['id_jenis_transaksi'] == '1'
                      ? Icons.undo
                      : Icons.local_gas_station,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text('Tabung: ${detail['kode_tabung']}'),
              subtitle: Text(
                  'Jenis: ${detail['id_jenis_transaksi'] == '1' ? 'Peminjaman' : 'Isi Ulang'} - Rp ${detail['harga']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.redFlame),
                onPressed: () => controller.hapusDetail(index),
              ),
            ),
          );
        },
      );
    });
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12));
  }

  Widget _buildRincianPembayaran() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Obx(() => Text(
                  'Total: Rp ${controller.totalTransaksi.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Metode Pembayaran'),
              value: controller.metodePembayaran.value,
              items: const [
                DropdownMenuItem(value: 'tunai', child: Text('Tunai')),
                DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.metodePembayaran.value = value;
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jumlahDibayarController,
              decoration: _inputDecoration('Jumlah Dibayar'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                controller.jumlahDibayar.value = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- PERUBAHAN UTAMA DI SINI ---
  Widget _buildSimpanButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.isLoading.value ? null : () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.secondary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.secondary, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          // Memanggil fungsi yang benar
                          controller.buatTransaksi();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2),
                      )
                    : const Text('Buat Transaksi',
                        style: TextStyle(color: AppColors.white, fontSize: 16)),
              )),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
