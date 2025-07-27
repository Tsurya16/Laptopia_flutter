import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // <--- Tambahkan import ini
import '../auth/logout.dart';
import 'package:laptopia/pages/auth/laptops.dart'; // Pastikan path ini benar untuk LaptopApiService

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<dynamic> _laptops = [];
  bool _isLoading = true;

  // Buat formatter untuk mata uang Rupiah
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', // Lokale Indonesia
    symbol: 'Rp ',  // Simbol Rupiah
    decimalDigits: 0, // Tidak ada angka di belakang koma untuk harga bulat
  );

  @override
  void initState() {
    super.initState();
    _fetchLaptops();
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
      Get.toNamed('/cart'); // Pastikan route '/cart' sudah terdaftar
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
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit_profile', child: Text('Edit Profile')),
              PopupMenuItem(value: 'ganti_password', child: Text('Ganti Password')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _laptops.isEmpty
              ? const Center(child: Text('Tidak ada produk tersedia saat ini.'))
              : RefreshIndicator(
                  onRefresh: _fetchLaptops,
                  child: ListView.builder(
                    itemCount: _laptops.length,
                    itemBuilder: (context, index) {
                      final laptop = _laptops[index];

                      // Format harga di sini
                      String formattedHarga = 'N/A'; // Default value if price is null or invalid
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
                                laptop['gambar'] != null && Uri.tryParse(laptop['gambar'])?.hasAbsolutePath == true
                                    ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.network(
                                            laptop['gambar'],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.laptop, size: 100, color: Colors.grey),
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
                                        'Harga: $formattedHarga', // Gunakan harga yang sudah diformat
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
                ),
    );
  }
}