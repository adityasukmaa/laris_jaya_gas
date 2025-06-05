import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/auth_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Only initialize AuthController
  Get.put(AuthController()..prefs = prefs);

  final initialRoute = prefs.getString('auth_token') != null &&
          prefs.getString('auth_token')!.isNotEmpty
      ? prefs.getString('user_role') == 'administrator'
          ? '/administrator/dashboard'
          : '/pelanggan/dashboard'
      : '/';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String? initialRoute;

  const MyApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laris Jaya Gas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}
