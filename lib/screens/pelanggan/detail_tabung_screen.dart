import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tabung_controller.dart';

class DetailTabungScreen extends StatelessWidget {
  final String kodeTabung;

  const DetailTabungScreen({super.key, required this.kodeTabung});

  @override
  Widget build(BuildContext context) {
    final tabungController = Get.find<TabungController>();
    final tabung = tabungController.tabungList
        .firstWhere((t) => t.kodeTabung == kodeTabung);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tabung'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kode Tabung: ${tabung.kodeTabung}',
                    style: const TextStyle(fontSize: 16)),
                Text('Jenis: ${tabung.jenisTabung}',
                    style: const TextStyle(fontSize: 16)),
                Text('Status: ${tabung.status}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
