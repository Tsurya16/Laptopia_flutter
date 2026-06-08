import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePassPage extends StatelessWidget {
  UpdatePassPage({super.key});
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();

  void updatePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar("Error", "Token tidak ditemukan. Silakan login ulang.");
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/update-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'old_password': oldPassController.text,
        'new_password': newPassController.text,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Get.snackbar("Berhasil", data['message'] ?? "Password berhasil diubah");
    } else {
      Get.snackbar("Gagal", data['message'] ?? "Gagal mengubah password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ganti Password"),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Get.previousRoute.isNotEmpty) {
              Get.back();
            } else {
              Get.offAllNamed('/user_dashboard');
            }
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password Lama'),
            ),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password Baru'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updatePassword,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFb79ced)),
              child: Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
