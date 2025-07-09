import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/login_page.dart';
import 'pages/swap_page.dart';
import 'pages/confirmation_page.dart';
import 'pages/success_page.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Put AuthController globally at app startup
  Get.put(AuthController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Crypto Swap App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => AuthWrapper()), // ✅ route เริ่มต้น
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/swap', page: () => SwapPage()),
        GetPage(name: '/confirmation', page: () => ConfirmationPage()),
        GetPage(name: '/success', page: () => SuccessPage()),
      ],
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(
      builder: (controller) {
        if (controller.user.value != null) {
          return SwapPage(); 
        } else {
          return LoginPage(); 
        }
      },
    );
  }
}
