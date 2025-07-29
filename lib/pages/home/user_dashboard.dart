import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/logout.dart';
import 'package:laptopia/pages/auth/laptops.dart'; // Pastikan path ini benar

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<dynamic> _laptops = [];
  bool _isLoading = true;

  // Ubah tipe String? menjadi String dan inisialisasi dengan string kosong
  String _userName = '';
  String _userEmail = '';

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchUser(); // Ambil data user saat inisialisasi state
    _fetchLaptops(); // Ambil data laptop saat inisialisasi state
  }

  Future<void> _fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'Token tidak ditemukan. Silakan login ulang.');
      // Fallback jika token tidak ada
      setState(() {
        _userName = 'Pengguna Tidak Dikenal';
        _userEmail = 'Tidak Ada Email';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // *** PERBAIKAN PENTING DI SINI ***
          // Akses data['user']['name'] dan data['user']['email']
          // Berdasarkan respons API dari Postman yang Anda tunjukkan
          _userName = data['user']['name'] ?? 'Nama Tidak Ditemukan';
          _userEmail = data['user']['email'] ?? 'Email Tidak Ditemukan';
        });
      } else {
        Get.snackbar('Error', 'Gagal mengambil data user: ${response.statusCode}');
        // Fallback jika fetch gagal
        setState(() {
          _userName = 'Gagal Memuat Nama';
          _userEmail = 'Gagal Memuat Email';
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan jaringan: $e');
      // Fallback jika ada error jaringan
      setState(() {
        _userName = 'Kesalahan Jaringan';
        _userEmail = 'Kesalahan Jaringan';
      });
    }
  }

  Future<void> _fetchLaptops() async {
    setState(() {
      _isLoading = true;
    });
    final laptops = await LaptopApiService.fetchLaptops();
    setState(() {
      _laptops = laptops;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFb79ced),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('lib/images/icon_putih.png'),
        ),
        title: const Text('Laptopia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Get.toNamed('/cart');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                showDialog(context: context, builder: (_) => const LogoutPage());
              } else if (value == 'edit_profile') {
                Get.toNamed('/edit_profile');
              } else if (value == 'ganti_password') {
                Get.toNamed('/update_password');
              }
            },
            itemBuilder: (context) => [
              // Info Profil (Tidak dapat diklik)
              PopupMenuItem<String>(
                enabled: false, // Penting: membuat item ini tidak bisa diklik
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName, // Sekarang tidak perlu ?? 'Loading Name...' lagi
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _userEmail, // Sekarang tidak perlu ?? 'Loading Email...' lagi
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(), // Pemisah visual

              // Menu Lainnya (Dapat diklik)
              const PopupMenuItem(value: 'edit_profile', child: Text('Edit Profile')),
              const PopupMenuItem(value: 'ganti_password', child: Text('Ganti Password')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            icon: const Icon(Icons.person, color: Colors.white), // Icon untuk tombol pop-up
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _laptops.isEmpty
              ? const Center(child: Text('Tidak ada produk tersedia saat ini.'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await _fetchUser(); // Refresh data user saat pull-to-refresh
                    await _fetchLaptops();
                  },
                  child: ListView(
                    children: [
                      // Bagian ini menampilkan informasi user di body halaman, bukan di pop-up menu
                     
                      // List Laptop (tetap sama)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _laptops.length,
                        itemBuilder: (context, index) {
                          final laptop = _laptops[index];

                          String formattedHarga = 'N/A';
                          if (laptop['harga'] != null) {
                            double price = (laptop['harga'] is int) ? laptop['harga'].toDouble() : laptop['harga'];
                            formattedHarga = _currencyFormatter.format(price);
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed('/product_detail_user/${laptop['id']}');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    laptop['gambar'] != null &&
                                            Uri.tryParse(laptop['gambar'])?.hasAbsolutePath == true
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.network(
                                              laptop['gambar'],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.laptop, size: 100, color: Colors.grey),
                                            ),
                                          )
                                        : const Icon(Icons.laptop, size: 100, color: Colors.grey),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            laptop['nama_laptop'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Harga: $formattedHarga',
                                            style: const TextStyle(fontSize: 16, color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}