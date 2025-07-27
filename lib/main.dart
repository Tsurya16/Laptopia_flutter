import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/splash_screen.dart';
import 'pages/auth/login.dart';
import 'pages/auth/register.dart';
import 'pages/home/admin_dashboard.dart';
import 'pages/home/user_dashboard.dart';
import 'pages/home/product_list_admin.dart';
import 'pages/home/product_detail_user.dart';
import 'pages/edit_profile.dart';
import 'pages/auth/update_pass.dart';
import 'pages/home/cart.dart'; // ⬅️ CartPage + CartController ada di sini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inject CartController + load data dari SharedPreferences
  final cartController = Get.put(CartController());
  cartController.loadCart();

  runApp(const LaptopiaApp());
}

class LaptopiaApp extends StatelessWidget {
  const LaptopiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laptopia',
      theme: ThemeData(
        primaryColor: const Color(0xFFb79ced),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFb79ced),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/cart', page: () => const CartPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/admin_dashboard', page: () => const AdminDashboard()),
        GetPage(name: '/user_dashboard', page: () => const UserDashboard()),
        GetPage(name: '/product_list_admin', page: () => const ProductListAdminPage()),
        GetPage(
          name: '/product_detail_user/:id',
          page: () => const ProductDetailUserPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(name: '/edit_profile', page: () => EditProfilePage()),
        GetPage(name: '/update_password', page: () => UpdatePassPage()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
