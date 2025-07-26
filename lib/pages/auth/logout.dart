import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token'); // Hapus token dari lokal
        Get.offAll(() => LoginPage());
        Get.snackbar("Berhasil", "Logout berhasil");
      } else {
        Get.snackbar("Gagal", "Logout gagal: ${response.body}");
      }
    } else {
      Get.snackbar("Error", "Token tidak ditemukan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Logout"),
      content: Text("Apakah kamu yakin ingin logout?"),
      actions: [
        TextButton(child: Text("Batal"), onPressed: () => Get.back()),
        TextButton(
          onPressed: logout,
          child: Text("Logout"),
        ),
      ],
    );
  }
}