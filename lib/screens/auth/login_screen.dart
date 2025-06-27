import 'dart:convert'; // Impor untuk menggunakan jsonDecode
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laris_jaya_gas/routes/app_routes.dart'; // Impor AppRoutes
import '../../controllers/auth_controller.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Menjalankan reset state setelah frame pertama selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthController authController = Get.find<AuthController>();
      authController.errorMessage.value = '';
    });
  }

  @override
  void dispose() {
    // Tidak perlu reset state di sini lagi
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- HELPER BARU UNTUK PARSING PESAN ERROR ---
  String _parseErrorMessage(String rawError) {
    // Contoh error: "Exception: Forbidden: Access denied - {"success":false,"message":"Akun Anda belum aktif. Silakan hubungi admin."}"
    try {
      // Periksa apakah pesan error mengandung objek JSON
      if (rawError.contains('{') && rawError.contains('}')) {
        final jsonStart = rawError.indexOf('{');
        final jsonString = rawError.substring(jsonStart);
        final decodedJson = jsonDecode(jsonString);
        // Kembalikan value dari key 'message' jika ada, atau pesan default jika tidak
        return decodedJson['message'] ??
            'Terjadi kesalahan yang tidak diketahui.';
      }
    } catch (e) {
      // Jika parsing gagal, bersihkan pesan error dari prefix "Exception: "
      return rawError.replaceFirst('Exception: ', '');
    }
    // Jika tidak ada JSON, bersihkan pesan error dari prefix "Exception: "
    return rawError.replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 8),
                        _buildForgotPassword(),
                        const SizedBox(height: 32),
                        Obx(() => authController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryButton(
                                label: 'Masuk',
                                onPressed: () => _handleSignIn(authController),
                              )),
                        const SizedBox(height: 12),
                        // --- PERBAIKAN TAMPILAN ERROR DI SINI ---
                        Obx(() {
                          final rawError = authController.errorMessage.value;
                          if (rawError.isNotEmpty) {
                            // Gunakan helper untuk mendapatkan pesan yang bersih
                            final cleanMessage = _parseErrorMessage(rawError);
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Center(
                                // Ditambahkan Center agar lebih rapi
                                child: Text(
                                  cleanMessage,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        const Spacer(),
                        _buildSignUpPrompt(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.email_outlined,
                size: 20, color: Color(0xFFD0D5DD)),
            hintText: 'Masukkan email Anda',
            hintStyle: const TextStyle(fontSize: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email tidak boleh kosong';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email tidak valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.lock_outline,
                size: 20, color: Color(0xFFD0D5DD)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: const Color(0xFF667085),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            hintText: 'Masukkan password Anda',
            hintStyle: const TextStyle(fontSize: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            if (value.length < 8) {
              return 'Password minimal 8 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Get.snackbar('Info', 'Fitur lupa password belum tersedia');
        },
        child: const Text(
          'Lupa Password?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0172B2),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF667085),
          ),
          children: [
            const TextSpan(text: 'Belum punya akun? '),
            TextSpan(
              text: 'Daftar disini',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0172B2),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Menggunakan AppRoutes untuk navigasi yang aman dan konsisten
                  Get.toNamed(AppRoutes.register);
                },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignIn(AuthController authController) async {
    // Bersihkan error lama sebelum mencoba login lagi
    authController.errorMessage.value = '';

    if (!_formKey.currentState!.validate()) return;

    await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    // Tidak perlu menampilkan snackbar di sini jika pesan error sudah ditampilkan oleh Obx
  }
}
