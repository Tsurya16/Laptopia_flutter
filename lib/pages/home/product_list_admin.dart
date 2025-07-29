// home/product_list_admin.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:laptopia/pages/auth/laptops.dart';

class ProductListAdminPage extends StatefulWidget {
  const ProductListAdminPage({super.key});

  @override
  State<ProductListAdminPage> createState() => _ProductListAdminPageState();
}

class _ProductListAdminPageState extends State<ProductListAdminPage> {
  List<dynamic> _laptops = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchLaptops();
  }

  Future<void> _fetchLaptops() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final laptops = await LaptopApiService.fetchLaptops();
      setState(() {
        _laptops = laptops;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching laptops in ProductListAdminPage: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data produk: $e';
        _isLoading = false;
      });
    }
  }

  void showAddEditLaptopDialog({Map<String, dynamic>? laptop}) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController namaLaptopController =
        TextEditingController(text: laptop?['nama_laptop'] ?? '');
    final TextEditingController hargaController =
        TextEditingController(text: laptop?['harga']?.toString() ?? '');
    final TextEditingController spesifikasiController =
        TextEditingController(text: laptop?['spesifikasi'] ?? '');
    final TextEditingController gambarController =
        TextEditingController(text: laptop?['gambar'] ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(laptop == null ? 'Tambah Produk Baru' : 'Edit Produk'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaLaptopController,
                  decoration: const InputDecoration(labelText: 'Nama Laptop'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama laptop tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Harga harus angka';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: spesifikasiController,
                  decoration: const InputDecoration(labelText: 'Spesifikasi'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Spesifikasi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: gambarController,
                  decoration: const InputDecoration(labelText: 'URL Gambar (Opsional)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final Map<String, dynamic> data = {
                  'nama_laptop': namaLaptopController.text,
                  'harga': double.parse(hargaController.text),
                  'spesifikasi': spesifikasiController.text,
                  'gambar': gambarController.text.isNotEmpty ? gambarController.text : null,
                };

                bool success;
                if (laptop == null) {
                  success = await LaptopApiService.addLaptop(data);
                } else {
                  success = await LaptopApiService.updateLaptop(laptop['id'], data);
                }

                if (success) {
                  Get.back(); // <--- PERUBAHAN: Tutup dialog jika sukses
                  _fetchLaptops(); // Kemudian refresh daftar
                }
              }
            },
            child: Text(laptop == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }
void deleteLaptop(int id, int index) async {
  bool success = await LaptopApiService.deleteLaptop(id);
  if (success) {
  } else {
    setState(() {
      _laptops.removeAt(index);
    });
    await _fetchLaptops();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk Laptop'),
        backgroundColor: const Color(0xFFb79ced),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.offAllNamed('/admin_dashboard');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showAddEditLaptopDialog(),
          ),
        ],
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
                            onPressed: _fetchLaptops,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
          : _laptops.isEmpty
              ? const Center(child: Text('Tidak ada produk. Tambahkan produk baru!'))
              : RefreshIndicator(
                  onRefresh: _fetchLaptops,
                  child: ListView.builder(
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              laptop['gambar'] != null && Uri.tryParse(laptop['gambar'])?.hasAbsolutePath == true
                                  ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                          laptop['gambar'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.laptop, size: 80, color: Colors.grey),
                                        ),
                                      )
                                  : const Icon(Icons.laptop, size: 80, color: Colors.grey),
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
                                    const SizedBox(height: 4),
                                    Text(
                                      'Harga: $formattedHarga',
                                      style: const TextStyle(fontSize: 16, color: Colors.green),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Spesifikasi: ${laptop['spesifikasi']}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => showAddEditLaptopDialog(laptop: laptop),
                                  ),
                                  IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteLaptop(laptop['id'], index), // Tambahkan index
                                ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

    );
  }
}