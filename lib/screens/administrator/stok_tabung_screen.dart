import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/stok_tabung_controller.dart';
import '../../utils/dummy_data.dart';

class StokTabungScreen extends StatelessWidget {
  final Color primaryBlue = const Color(0xFF0172B2);
  final Color darkBlue = const Color(0xFF001848);

  StokTabungScreen({super.key});

  // Daftar jenis tabung untuk dropdown
  final List<String> jenisTabungList = [
    'Semua',
    'Oksigen',
    'Nitrogen',
    'Argon',
    'Acetelyne',
    'Dinitrogen Oksida'
  ];
  final List<String> statusTabungList = ['Semua', 'Tersedia', 'Dipinjam'];

  @override
  Widget build(BuildContext context) {
    final StokTabungController controller = Get.put(StokTabungController());

    // Dapatkan tinggi dan lebar layar untuk penyesuaian responsif
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double paddingVertical = screenHeight * 0.02; // 2% dari tinggi layar
    final double dropdownHeight =
        screenHeight * 0.07; // Tinggi maksimum dropdown
    final double maxDropdownWidth =
        screenWidth * 0.47; // 47% untuk ruang tambahan

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Stok Tabung', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: paddingVertical, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, darkBlue],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Tabung Tersedia : ${DummyData.tabungList.where((tabung) => tabung.status == 'Tersedia').length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Tabung Keseluruhan : ${DummyData.tabungList.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxDropdownWidth),
                      height: dropdownHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryBlue),
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Obx(() => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Jenis Tabung',
                              labelStyle:
                                  TextStyle(color: primaryBlue, fontSize: 14),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.category,
                                  color: primaryBlue, size: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            ),
                            value: controller.selectedJenis.value,
                            items: jenisTabungList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 14,
                                      fontWeight: value ==
                                              controller.selectedJenis.value
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedJenis.value = value;
                              }
                            },
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.arrow_drop_down,
                                color: primaryBlue, size: 24),
                            isExpanded: true,
                            selectedItemBuilder: (BuildContext context) {
                              return jenisTabungList
                                  .map<Widget>((String value) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              }).toList();
                            },
                            style: TextStyle(color: darkBlue, fontSize: 14),
                            menuMaxHeight: screenHeight * 0.3,
                            elevation: 8,
                            borderRadius: BorderRadius.circular(10),
                            itemHeight: 48,
                          )),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxDropdownWidth),
                      height: dropdownHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryBlue),
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Obx(() => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Status Tabung',
                              labelStyle:
                                  TextStyle(color: primaryBlue, fontSize: 14),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.check_circle,
                                  color: primaryBlue, size: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            ),
                            value: controller.selectedStatus.value,
                            items: statusTabungList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 14,
                                      fontWeight: value ==
                                              controller.selectedStatus.value
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedStatus.value = value;
                              }
                            },
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.arrow_drop_down,
                                color: primaryBlue, size: 24),
                            isExpanded: true,
                            selectedItemBuilder: (BuildContext context) {
                              return statusTabungList
                                  .map<Widget>((String value) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              }).toList();
                            },
                            style: TextStyle(color: darkBlue, fontSize: 14),
                            menuMaxHeight: screenHeight * 0.3,
                            elevation: 8,
                            borderRadius: BorderRadius.circular(5),
                            itemHeight: 48,
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controller.applyFilter();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: const LinearBorder(),
                ),
                child: const Text('Terapkan Filter',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredTabungList.length,
                    itemBuilder: (context, index) {
                      final tabung = controller.filteredTabungList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: tabung.status == 'Tersedia'
                            ? Colors.grey[200]
                            : Colors.blue[100],
                        child: ListTile(
                          title: Text('Kode : ${tabung.kodeTabung}'),
                          subtitle: Text('Jenis : ${tabung.jenisTabung}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tabung.status,
                                style: TextStyle(
                                  color: tabung.status == 'Tersedia'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: primaryBlue, size: 20),
                                onPressed: () {
                                  Get.toNamed('/administrator/edit-tabung',
                                      arguments: tabung.kodeTabung);
                                },
                                tooltip: 'Edit Tabung',
                              ),
                            ],
                          ),
                          onTap: () {
                            Get.toNamed('/administrator/detail-tabung',
                                arguments: tabung.kodeTabung);
                          },
                        ),
                      );
                    },
                  )),
              const SizedBox(height: 80), // Tambahan padding bawah untuk FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/administrator/tambah-tabung');
        },
        backgroundColor: darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
