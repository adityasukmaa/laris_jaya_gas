import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white, // Background putih
        foregroundColor: AppColors.blackText,
        minimumSize: const Size(double.infinity, 50), // Lebar penuh
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(
            color: AppColors.blackText, width: 1), // Border hitam
        elevation: 2, // Bayangan halus
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.blackText,
        ),
      ),
    );
  }
}
