import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/transaksi_controller.dart';
import '../../utils/dummy_data.dart';
import '../../utils/formatters.dart';

class DashboardPelangganScreen extends StatelessWidget {
  const DashboardPelangganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final transaksiController = Get.put(TransaksiController());
    final pelangganData = DummyData.pelangganData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${pelangganData['name']}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(pelangganData['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${pelangganData['email']}'),
                    Text('Phone: ${pelangganData['phone']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaksi Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: transaksiController.transaksiList.length,
                    itemBuilder: (context, index) {
                      final transaksi =
                          transaksiController.transaksiList[index];
                      return Card(
                        child: ListTile(
                          title: Text('Kode Tabung: ${transaksi.kodeTabung}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Tanggal Pinjam: ${formatDate(transaksi.tanggalPeminjaman)}'),
                              Text(
                                  'Jatuh Tempo: ${transaksi.tanggalJatuhTempo != null ? formatDate(transaksi.tanggalJatuhTempo!) : '-'}'),
                            ],
                          ),
                          trailing: Text(transaksi.status),
                        ),
                      );
                    },
                  )),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/pelanggan/ajukan-peminjaman');
              },
              child: const Text('Ajukan Peminjaman'),
            ),
          ],
        ),
      ),
    );
  }
}
