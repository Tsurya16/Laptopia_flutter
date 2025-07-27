import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/logout.dart';
// Hapus import halaman spesifik karena menggunakan named routes
// import 'package:laptopia/pages/edit_profile.dart';
// import '../auth/update_pass.dart';
// import 'package:laptopia/pages/home/product_list_admin.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFb79ced),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('lib/images/icon_putih.png'),
        ),
        title: const Text('Laptopia'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                showDialog(context: context, builder: (_) => const LogoutPage());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat datang, Admin",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Gunakan menu di bawah ini untuk mengelola CRUD Produk Laptop."),
            const SizedBox(height: 30),
            Card(
              elevation: 3,
              // Menggunakan nilai heksadesimal dengan alpha untuk opacity 10%
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.laptop, color: Color.fromARGB(255, 0, 0, 0)),
                title: const Text(
                      "Manajemen Produk Laptop",
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), 
                    ),
                    subtitle: const Text(
                      "Tambah, edit, dan hapus data laptop",
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), 
                    ),
                onTap: () {
                  Get.toNamed('/product_list_admin'); // Menggunakan named route
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}