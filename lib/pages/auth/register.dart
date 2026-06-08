import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Hapus import yang tidak lagi dibutuhkan karena menggunakan named routes
// import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void register() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final token = data['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      Get.snackbar("Sukses", "Registrasi berhasil");
      Get.offNamed('/login'); // Menggunakan named route
    } else {
      Get.snackbar("Gagal", data['message'] ?? 'Terjadi kesalahan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
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
              onPressed: register,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFb79ced)),
              child: Text('Register', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}