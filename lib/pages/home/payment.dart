import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laptopia/pages/home/cart.dart'; // Sesuaikan path

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? paymentCategory; // "E-Wallet" atau "Bank"
  String? selectedPaymentMethod;
  final TextEditingController numberController = TextEditingController();

  final List<String> ewallets = ['DANA', 'OVO', 'ShopeePay'];
  final List<String> banks = [
    'BCA', 'Mandiri', 'BRI', 'BNI', 'BTN',
    'CIMB Niaga', 'Permata', 'Danamon', 'Bank Jago', 'Maybank'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
        backgroundColor: const Color(0xFFb79ced),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Pilih Kategori Pembayaran:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text("E-Wallet"),
              value: "E-Wallet",
              groupValue: paymentCategory,
              onChanged: (value) {
                setState(() {
                  paymentCategory = value;
                  selectedPaymentMethod = null;
                  numberController.clear();
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("Bank"),
              value: "Bank",
              groupValue: paymentCategory,
              onChanged: (value) {
                setState(() {
                  paymentCategory = value;
                  selectedPaymentMethod = null;
                  numberController.clear();
                });
              },
            ),

            if (paymentCategory == "E-Wallet") ...[
              const SizedBox(height: 16),
              const Text("Pilih E-Wallet:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...ewallets.map((ewallet) => RadioListTile<String>(
                    title: Text(ewallet),
                    value: ewallet,
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() => selectedPaymentMethod = value);
                    },
                  )),
            ],

            if (paymentCategory == "Bank") ...[
              const SizedBox(height: 16),
              const Text("Pilih Bank:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...banks.map((bank) => RadioListTile<String>(
                    title: Text(bank),
                    value: bank,
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() => selectedPaymentMethod = value);
                    },
                  )),
            ],

            if (selectedPaymentMethod != null) ...[
              const SizedBox(height: 20),
              Text(
                paymentCategory == "E-Wallet" ? 'Nomor HP:' : 'Nomor Rekening:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan nomor yang sesuai',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFb79ced),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  if (numberController.text.isEmpty) {
                    Get.snackbar("Gagal", "Nomor tidak boleh kosong", backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }

                  Get.defaultDialog(
                    title: "Pembayaran Berhasil",
                    middleText: "Terima kasih telah melakukan pembelian!",
                    textConfirm: "OK",
                    onConfirm: () {
                      final cartController = Get.find<CartController>();
                      cartController.clearCart();
                      Get.offAllNamed('/user_dashboard');
                    },
                    buttonColor: Color(0xFFb79ced),
                  );
                },
                child: const Text(
                  "Konfirmasi Pembayaran",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
