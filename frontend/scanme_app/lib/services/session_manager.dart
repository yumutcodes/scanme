import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  int? currentUserId;
  static const String _keyUserId = 'userId';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt(_keyUserId);
  }

  Future<void> login(int userId) async {
    currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  Future<void> logout() async {
    currentUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  bool get isLoggedIn => currentUserId != null;
}
