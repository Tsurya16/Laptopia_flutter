# Laptopia - Flutter App

Aplikasi mobile untuk [isi dengan deskripsi singkat aplikasi, misal: katalog laptop atau toko komputer online]. Aplikasi ini dibangun menggunakan framework Flutter dan terintegrasi penuh dengan backend Laravel.

## 🚀 Fitur Utama
* Autentikasi Pengguna (Login, Register, Logout) dengan token Sanctum
* Manajemen Profil Pengguna (Edit Profil, Ubah Password)
* Katalog Produk / Laptop
* Terdapat Keranjang Untuk Produk Yang Ingin Dibeli
* Terdapat Banyak Pilihan Metode Pembayaran

## 🛠️ Tech Stack
* **Frontend:** Flutter
* **State Management & Routing:** GetX
* **Backend:** Laravel (RESTful API)
  Link: https://github.com/Tsurya16/laptopia_backend_laravel.git

## 📋 Prasyarat
Sebelum menjalankan project ini, pastikan sistem kamu sudah terinstal:
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* Android Studio / VS Code (beserta ekstensi Flutter & Dart)
* Lingkungan PHP & MySQL (seperti XAMPP/Laragon) untuk menjalankan backend.

## 💻 Cara Menjalankan Project

### 1. Persiapkan Backend (Laravel)
Pastikan backend Laravel untuk Laptopia sudah dikonfigurasi dan dijalankan.
```bash
# Arahkan terminal ke folder backend Laravel
cd path/to/laptopia-backend

# Jalankan server lokal
php artisan serve
