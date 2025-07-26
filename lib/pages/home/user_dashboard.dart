import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/logout.dart';
import '../auth/update_pass.dart';
import 'package:laptopia/pages/edit_profile.dart'; // pastikan ini diimport

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFb79ced),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('lib/images/icon_putih.png'),
        ),
        title: Text('User Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                showDialog(context: context, builder: (_) => LogoutPage());
              } else if (value == 'edit_profile') {
                Get.to(() => EditProfilePage());
              } else if (value == 'ganti_password') {
                Get.to(() => UpdatePassPage());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit_profile', child: Text('Edit Profile')),
              PopupMenuItem(value: 'ganti_password', child: Text('Ganti Password')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            icon: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Selamat datang di Dashboard Pengguna",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
