import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'payment.dart';
import 'package:laptopia/pages/home/product_detail_user.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };
}

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  void saveCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartData =
        cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart', cartData);
  }

  void loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartData = prefs.getStringList('cart') ?? [];

    cartItems.value = cartData.map((itemJson) {
      Map<String, dynamic> data = jsonDecode(itemJson);
      return CartItem.fromJson(data);
    }).toList();
  }

  void clearCart() {
  cartItems.clear();
  saveCart(); // update ke SharedPreferences juga
  }

  void addToCart(Product product) {
    var index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      cartItems[index].quantity++;
    } else {
      cartItems.add(CartItem(product: product));
    }
    saveCart();
  }

  void removeFromCart(CartItem item) {
    cartItems.remove(item);
    saveCart();
  }

  void increaseQty(CartItem item) {
    item.quantity++;
    cartItems.refresh();
    saveCart();
  }

  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
      saveCart();
    }
  }

  double get total => cartItems.fold(
      0, (sum, item) => sum + item.product.price * item.quantity);
}

// Helper untuk format ke rupiah
String formatRupiah(double value) {
  final formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatCurrency.format(value);
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
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
      body: Obx(() => cartController.cartItems.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartController.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartController.cartItems[index];
                      return ListTile(
                        leading: Image.network(item.product.imageUrl,
                            width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(item.product.name),
                        subtitle: Text(
                            '${formatRupiah(item.product.price)} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  cartController.decreaseQty(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  cartController.increaseQty(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  cartController.removeFromCart(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: ${formatRupiah(cartController.total)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFb79ced),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                        onPressed: () => Get.to(() => const PaymentPage()),
                        child: const Text(
                          'Beli Sekarang',
                          style: TextStyle(color: Colors.white),
                          ),
                      ),
                    ],
                  ),
                )
              ],
            )),
    );
  }
}
