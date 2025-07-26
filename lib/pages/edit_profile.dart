import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatelessWidget {
  EditProfilePage({super.key});
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  void updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar("Error", "Token tidak ditemukan. Silakan login ulang.");
      return;
    }

    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/update-profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': nameController.text,
        'email': emailController.text,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Get.snackbar("Berhasil", data['message'] ?? "Profil berhasil diperbarui");
    } else {
      Get.snackbar("Gagal", data['message'] ?? "Gagal memperbarui profil");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFb79ced)),
              child: Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
