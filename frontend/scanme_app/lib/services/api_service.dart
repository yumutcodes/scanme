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
    _logger.d('Getting headers, JWT token present: ${token != null}, length: ${token?.length ?? 0}');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
        // TokenController returns raw string - clean up any quotes or whitespace
        String token = response.body.trim();
        // Remove surrounding quotes if present (some backends return "token" instead of token)
        if (token.startsWith('"') && token.endsWith('"')) {
          token = token.substring(1, token.length - 1);
        }
        _logger.i('Login successful, token received (length: ${token.length})');
        return token;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _logger.w('Auth failed: ${response.statusCode} ${response.body}');
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 500) {
        _logger.e('Server error during login');
        throw Exception('Server error. User may not exist.');
      } else {
        _logger.w('Login failed: ${response.statusCode} ${response.body}');
        throw Exception('Login failed: ${response.body}');
      }
    } on SocketException {
      throw Exception('Cannot connect to server. Is backend running?');
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

  /// Save history to backend and return the backend ID if successful
  static Future<int?> saveHistory(ScanItem item) async {
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

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final backendId = json['id'] as int;
        _logger.i('History saved to backend with id: $backendId');
        return backendId;
      } else {
        _logger.w('Failed to save history to backend: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error saving history to backend', error: e);
      return null;
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
          backendId: json['id'] as int,  // Capture backend ID
          barcode: json['barcode'],
          productName: json['productName'],
          isSafe: json['isSafe'],
          scanDate: DateTime.parse(json['scanDate']),
        )).toList();
      }
    } catch (e) {
      _logger.e('Error fetching history', error: e);
    }
    return [];
  }

  /// Delete a history entry by its backend ID
  static Future<bool> deleteHistory(int backendId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/history/$backendId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        _logger.i('Successfully deleted history from backend: $backendId');
        return true;
      } else {
        _logger.w('Failed to delete history: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e('Error deleting history', error: e);
      return false;
    }
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

  static Future<bool> deleteAllergen(String allergen) async {
    try {
      // Backend expects AllergyDto with allergy_name
      final request = http.Request('DELETE', Uri.parse('$baseUrl/allergies'));
      request.headers.addAll(await _headers);
      request.body = jsonEncode({'allergy_name': allergen});
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        _logger.i('Successfully deleted allergen from backend: $allergen');
        return true;
      } else {
        _logger.w('Failed to delete allergen from backend: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e('Error deleting allergen', error: e);
      return false;
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

      _logger.d('Syncing allergens - Backend: $backendAllergens, Local: $localAllergens');

      // Pull down (Backend -> Local) - ONLY add if local doesn't have it
      // But respect local deletions: if backend has it but local doesn't,
      // it means user deleted it locally, so we should delete from backend instead
      for (var allergen in backendAllergens) {
        if (!localAllergens.contains(allergen)) {
          // Local doesn't have this allergen - it was deleted locally
          // Delete from backend to sync the deletion
          _logger.d('Allergen "$allergen" exists in backend but not locally - deleting from backend');
          await deleteAllergen(allergen);
        }
      }
      
      // Push up (Local -> Backend) - add local allergens that backend doesn't have
      for (var allergen in localAllergens) {
        if (!backendAllergens.contains(allergen)) {
          _logger.d('Allergen "$allergen" exists locally but not in backend - pushing to backend');
          await saveAllergen(allergen);
        }
      }

      // 2. Sync History using backend IDs
      final backendHistory = await getHistory();
      final localHistory = await DatabaseHelper.instance.readAllHistory(userId);
      
      _logger.d('Syncing history - Backend: ${backendHistory.length} items, Local: ${localHistory.length} items');

      // Delete from backend if not in local (user deleted locally)
      // Match by backendId for precise deletion
      for (var bItem in backendHistory) {
        bool existsLocally = localHistory.any((lItem) => lItem.backendId == bItem.backendId);
        
        if (!existsLocally && bItem.backendId != null) {
          _logger.d('History "${bItem.barcode}" (id: ${bItem.backendId}) exists in backend but not locally - deleting from backend');
          await deleteHistory(bItem.backendId!);
        }
      }
      
      // Push local history to backend if it doesn't have a backend ID yet
      for (var lItem in localHistory) {
        if (lItem.backendId == null) {
          // No backend ID means it hasn't been synced to backend yet
          _logger.d('History "${lItem.barcode}" exists locally but not synced to backend - pushing to backend');
          final backendId = await saveHistory(lItem);
          if (backendId != null && lItem.id != null) {
            // Update local entry with the backend ID
            await DatabaseHelper.instance.updateBackendId(lItem.id!, backendId);
          }
        }
      }
    } catch (e) {
      _logger.e('Sync failed', error: e);
    }
  }
}