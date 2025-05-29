import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isCompact; // Tambahkan parameter untuk mode kompak

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isCompact = false, // Default false, artinya tombol akan penuh
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        minimumSize: isCompact
            ? const Size(
                100, 40) // Lebar dan tinggi lebih kecil untuk mode kompak
            : const Size(double.infinity, 50), // Lebar penuh untuk mode normal
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:
              isCompact ? 14 : 16, // Ukuran font lebih kecil di mode kompak
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
