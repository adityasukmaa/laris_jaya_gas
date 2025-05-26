import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/secondary_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Laris Jaya Gas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Selamat Datang Kembali',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            CircleAvatar(
              radius: screenWidth / 2 - 10,
              backgroundColor: const Color.fromARGB(255, 247, 247, 247),
              child: Image.asset(
                'assets/images/logo_jernih.png',
                height: 212,
                width: 181,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red, size: 50);
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Masuk',
                    onPressed: () {
                      Get.toNamed('/login'); // Navigasi manual ke halaman login
                    },
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Daftar',
                    onPressed: () {
                      Get.toNamed(
                          '/register'); // Navigasi manual ke halaman register
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
