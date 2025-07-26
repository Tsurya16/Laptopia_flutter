import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/logout.dart';
import 'package:laptopia/pages/edit_profile.dart';
import '../auth/update_pass.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFb79ced),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('lib/images/icon_putih.png'),
        ),
        title: Text('Admin Dashboard'),
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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selamat datang, Admin",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Gunakan menu di atas untuk mengelola profil atau keluar."),
            SizedBox(height: 30),
            Card(
              elevation: 3,
              // ignore: deprecated_member_use
              color: Color(0xFFb79ced).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.laptop, color: Color(0xFFb79ced)),
                title: Text("Manajemen Produk Laptop"),
                subtitle: Text("Tambah, edit, dan hapus data laptop"),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}