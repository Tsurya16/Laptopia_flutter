import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <-- Tambahkan ini
import 'pages/auth/login.dart';

void main() => runApp(LaptopiaApp());

class LaptopiaApp extends StatelessWidget {
  const LaptopiaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // <-- GANTI dari MaterialApp ke GetMaterialApp
      title: 'Laptopia',
      theme: ThemeData(
        primaryColor: Color(0xFFb79ced),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFb79ced),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
