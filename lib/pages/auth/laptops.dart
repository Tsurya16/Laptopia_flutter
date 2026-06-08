// lib/pages/auth/laptops.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaptopApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/laptops';

  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<dynamic>> fetchLaptops() async {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar('Error', 'Authentication token not found. Please log in again.');
      return [];
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorMessage = json.decode(response.body)['message'] ?? 'Failed to load laptops. Status code: ${response.statusCode}';
      Get.snackbar('Error', errorMessage);
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchLaptopById(int id) async {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar('Error', 'Authentication token not found.');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      Get.snackbar('Error', 'Failed to load laptop details: ${json.decode(response.body)['message'] ?? response.statusCode}');
      return null;
    }
  }

  static Future<bool> addLaptop(Map<String, dynamic> laptopData) async {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar('Error', 'Authentication token not found.');
      return false;
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(laptopData),
    );

    if (response.statusCode == 201) {
      Get.snackbar('Success', 'Laptop added successfully');
      return true;
    } else {
      Get.snackbar('Error', 'Failed to add laptop: ${json.decode(response.body)['message'] ?? response.statusCode}');
      return false;
    }
  }

  static Future<bool> updateLaptop(int id, Map<String, dynamic> laptopData) async {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar('Error', 'Authentication token not found.');
      return false;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(laptopData),
    );

    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Laptop updated successfully');
      return true;
    } else {
      Get.snackbar('Error', 'Failed to update laptop: ${json.decode(response.body)['message'] ?? response.statusCode}');
      return false;
    }
  }

  static Future<bool> deleteLaptop(int id) async {
  final token = await _getToken();

  if (token == null) {
    Get.snackbar('Error', 'Authentication token not found.');
    return false;
  }

  final response = await http.delete(
    Uri.parse('$baseUrl/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 204) {
    Get.snackbar('Error', 'Failed to delete the laptop');
    return true;
  } else {
    Get.snackbar('Success', 'Laptop has been deleted');
    return false;
  }
}
}