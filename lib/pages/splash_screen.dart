import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Tidak perlu import halaman spesifik jika menggunakan named routes
// import 'package:laptopia/pages/auth/login.dart';
// import 'package:laptopia/pages/home/admin_dashboard.dart';
// import 'package:laptopia/pages/home/user_dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      bool isValidToken = await _validateToken(token);

      if (isValidToken) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/user'), // Asumsikan ada endpoint /api/user untuk profile
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          final role = userData['user']['role']; // Pastikan struktur JSON sesuai

          if (role == 'user') {
            Get.offAllNamed('/user_dashboard'); // Menggunakan named route
          } else {
            Get.offAllNamed('/admin_dashboard'); // Menggunakan named route
          }
        } else {
          // Gagal mengambil profile atau token tidak valid di backend
          await prefs.remove('token'); // Hapus token kadaluarsa
          Get.offAllNamed('/login'); // Menggunakan named route
        }
      } else {
        // Token tidak valid secara lokal
        await prefs.remove('token');
        Get.offAllNamed('/login'); // Menggunakan named route
      }
    } else {
      // Tidak ada token, arahkan ke halaman login
      Get.offAllNamed('/login'); // Menggunakan named route
    }
  }

  // Fungsi untuk validasi token ke backend
  Future<bool> _validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/user'), // Ganti jika endpoint user profile berbeda
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200; // Jika 200 OK, token dianggap valid
    } catch (e) {
      debugPrint('Error validating token: $e'); // Menggunakan debugPrint()
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Tampilkan loading saat cek status login
      ),
    );
  }
}