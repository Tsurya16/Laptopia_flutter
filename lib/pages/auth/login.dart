import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


import '../home/admin_dashboard.dart';
import '../home/user_dashboard.dart';
import 'register.dart';
import 'package:laptopia/custom/custom_appbar.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final role = data['user']['role'];
      final token = data['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token); // Simpan token ke SharedPreferences

      Get.snackbar("Sukses", "Login berhasil");

      if (role == 'user') {
        Get.offAll(() => UserDashboard());
      } else {
        Get.offAll(() => AdminDashboard());
      }
    } else {
      Get.snackbar(
        'Login Gagal',
        data['message'] ?? 'Email atau password salah',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("lib/images/icon_ungu.png", width: 200, height: 200),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFb79ced),
              ),
              onPressed: login,
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => RegisterPage());
              },
              child: const Text("Belum punya akun? Daftar"),
            ),
          ],
        ),
      ),
    );
  }
}
