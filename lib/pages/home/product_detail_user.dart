import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // <--- Tambahkan import ini
import 'package:laptopia/pages/home/cart.dart';


// Model Product disesuaikan dengan struktur JSON API yang baru
class Product {
  final int id;
  final String name;
  final String description; // Ini akan diisi dari 'spesifikasi'
  final double price;
  final String imageUrl; // Ini akan diisi dari 'gambar'

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['nama_laptop'] as String, // Mengambil dari 'nama_laptop'
      description: json['spesifikasi'] as String, // Mengambil dari 'spesifikasi'
      price: double.parse(json['harga'].toString()), // Mengambil dari 'harga'
      imageUrl: json['gambar'] as String? ?? 'https://via.placeholder.com/150', // Mengambil dari 'gambar', handle null
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_laptop': name,
      'spesifikasi': description,
      'harga': price,
      'gambar': imageUrl,
    };
  }
}

class ProductDetailUserPage extends StatefulWidget {
  const ProductDetailUserPage({super.key});

  @override
  State<ProductDetailUserPage> createState() => _ProductDetailUserPageState();
}

class _ProductDetailUserPageState extends State<ProductDetailUserPage> {
  int? productId;
  Product? product;
  bool _isLoading = true;
  String _errorMessage = '';

  // Buat formatter untuk mata uang Rupiah
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', // Lokale Indonesia
    symbol: 'Rp ',  // Simbol Rupiah
    decimalDigits: 0, // Tidak ada angka di belakang koma untuk harga bulat
  );

  @override
  void initState() {
    super.initState();
    final idString = Get.parameters['id'];
    if (idString != null) {
      productId = int.tryParse(idString);
      if (productId != null) {
        _fetchProductDetail();
      } else {
        _handleErrorAndRedirect('ID Produk tidak valid di URL.');
      }
    } else {
      _handleErrorAndRedirect('ID Produk tidak ditemukan di URL.');
    }
  }

  void _handleErrorAndRedirect(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("Error", message);
      Get.offAllNamed('/user_dashboard');
    });
  }

  Future<void> _fetchProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _handleErrorAndRedirect("Token tidak ditemukan. Silakan login ulang.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/laptops/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      dynamic responseBody;
      try {
        responseBody = json.decode(response.body);
        debugPrint('API Response for $productId: $responseBody');
      } catch (e) {
        _errorMessage = 'Error decoding JSON: $e, Raw response: ${response.body}';
        setState(() {});
        return;
      }

      if (response.statusCode == 200) {
        if (responseBody is Map<String, dynamic>) {
            product = Product.fromJson(responseBody);
        } else {
          _errorMessage = 'Respon API bukan format objek JSON yang diharapkan.';
        }
      } else if (response.statusCode == 404) {
          _errorMessage = responseBody['message'] ?? 'Produk dengan ID $productId tidak ditemukan.';
      } else if (response.statusCode == 401) {
          _handleErrorAndRedirect("Sesi berakhir. Silakan login ulang.");
          return;
      }
      else {
        _errorMessage = responseBody['message'] ?? 'Gagal memuat detail produk: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'Koneksi gagal saat memuat detail produk: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

final CartController cartController = Get.find<CartController>();
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Produk"),
        backgroundColor: const Color(0xFFb79ced),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (productId != null) {
                                  _fetchProductDetail();
                              } else {
                                  Get.offAllNamed('/user_dashboard');
                              }
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
          : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // padding bawah ditambah agar tombol tidak ketutup
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double width = constraints.maxWidth;
                              double height = width * 9 / 16;
                              double maxHeight = 250;
                              return SizedBox(
                                width: width,
                                height: height > maxHeight ? maxHeight : height,
                                child: Image.network(
                                  product!.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            product!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currencyFormatter.format(product!.price),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            product!.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                            label: const Text(
                              "Tambah ke Keranjang",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFb79ced),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            onPressed: () {
                              cartController.addToCart(product!);
                              Get.snackbar(
                                "Berhasil",
                                "Produk ditambahkan ke keranjang",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFb79ced),
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
