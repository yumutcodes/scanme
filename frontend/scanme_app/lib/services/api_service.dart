import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scanme_app/services/session_manager.dart';
import 'package:logger/logger.dart';
import 'package:scanme_app/services/database_helper.dart';

class ApiService {
  static final Logger _logger = Logger();

  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static Future<Map<String, String>> get _headers async {
    final token = SessionManager().jwtToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Auth ---

  static Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // TokenController returns raw string
        return response.body;
      } else {
        _logger.w('Login failed: ${response.statusCode} ${response.body}');
        throw Exception('Login failed: Invalid credentials');
      }
    } catch (e) {
      _logger.e('Login error', error: e);
      rethrow;
    }
  }

  static Future<void> register(String email, String password, String name, String surname, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'surname': surname,
          'username': username,
          'role': 'ROLE_USER'
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _logger.w('Registration failed: ${response.statusCode} ${response.body}');
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Registration error', error: e);
      rethrow;
    }
  }

  // --- History ---

  static Future<void> saveHistory(ScanItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/history'),
        headers: await _headers,
        body: jsonEncode({
          'barcode': item.barcode,
          'productName': item.productName,
          'isSafe': item.isSafe,
          'scanDate': item.scanDate.toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        _logger.w('Failed to save history to backend: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error saving history to backend', error: e);
    }
  }

  static Future<List<ScanItem>> getHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => ScanItem(
          barcode: json['barcode'],
          productName: json['productName'],
          isSafe: json['isSafe'],
          scanDate: DateTime.parse(json['scanDate']),
          // We intentionally don't set the local ID here, DatabaseHelper will generate one
        )).toList();
      }
    } catch (e) {
      _logger.e('Error fetching history', error: e);
    }
    return [];
  }

  // --- Allergens ---

  static Future<void> saveAllergen(String allergen) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/allergies'),
        headers: await _headers,
        body: jsonEncode({'allergy_name': allergen}),
      );
    } catch (e) {
      _logger.e('Error saving allergen', error: e);
    }
  }

  static Future<void> deleteAllergen(String allergen) async {
    try {
      // Backend expects AllergyDto, delete logic typically usually needs ID but here by name?
      // AllergyController uses deleteAAllergyForUser(@RequestBody AllergyDto ...)
      // We'll send name.
      final request = http.Request('DELETE', Uri.parse('$baseUrl/allergies'));
      request.headers.addAll(await _headers);
      request.body = jsonEncode({'allergy_name': allergen});
      
      await request.send();
    } catch (e) {
      _logger.e('Error deleting allergen', error: e);
    }
  }

  static Future<List<String>> getAllergens() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/allergies'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => json['allergy_name'] as String).toList();
      }
    } catch (e) {
      _logger.e('Error fetching allergens', error: e);
    }
    return [];
  }

  // --- Sync Logic ---

  static Future<void> syncUserData(int userId) async {
    try {
      // 1. Sync Allergens (Bidirectional)
      final backendAllergens = await getAllergens();
      final localAllergens = await DatabaseHelper.instance.getUserAllergens(userId);

      // Pull down (Backend -> Local)
      if (backendAllergens.isNotEmpty) {
        for (var allergen in backendAllergens) {
          if (!localAllergens.contains(allergen)) {
            await DatabaseHelper.instance.addUserAllergen(userId, allergen);
          }
        }
      }
      
      // Push up (Local -> Backend)
      if (localAllergens.isNotEmpty) {
        for (var allergen in localAllergens) {
          if (!backendAllergens.contains(allergen)) {
            await saveAllergen(allergen);
          }
        }
      }

      // 2. Sync History
      final backendHistory = await getHistory();
      if (backendHistory.isNotEmpty) {
        final localHistory = await DatabaseHelper.instance.readAllHistory(userId);
        // Avoid duplicates based on scanDate and barcode
        for (var bItem in backendHistory) {
          bool exists = localHistory.any((lItem) => 
            lItem.barcode == bItem.barcode && 
            lItem.scanDate.difference(bItem.scanDate).inSeconds.abs() < 5 // fuzzy match time
          );
          
          if (!exists) {
            await DatabaseHelper.instance.create(bItem, userId);
          }
        }
      }
    } catch (e) {
      _logger.e('Sync failed', error: e);
    }
  }
}