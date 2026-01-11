import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Secure session manager using encrypted storage.
/// Stores a unique session token instead of user ID for improved security.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keySessionToken = 'session_token';
  static const String _keyUserId = 'user_id';
  static const String _keySessionCreatedAt = 'session_created_at';

  static const _uuid = Uuid();

  String? _sessionToken;
  int? _currentUserId;
  DateTime? _sessionCreatedAt;

  /// Session expiration duration (7 days)
  static const Duration sessionDuration = Duration(days: 7);

  /// Initialize session from secure storage
  Future<void> init() async {
    try {
      _sessionToken = await _storage.read(key: _keySessionToken);
      final userIdStr = await _storage.read(key: _keyUserId);
      final createdAtStr = await _storage.read(key: _keySessionCreatedAt);

      if (userIdStr != null) {
        _currentUserId = int.tryParse(userIdStr);
      }

      if (createdAtStr != null) {
        _sessionCreatedAt = DateTime.tryParse(createdAtStr);
      }

      // Check if session has expired
      if (_sessionCreatedAt != null && isSessionExpired) {
        await logout();
      }
    } catch (e) {
      // If we can't read from secure storage, ensure we're logged out
      _sessionToken = null;
      _currentUserId = null;
      _sessionCreatedAt = null;
    }
  }

  /// Login user and create a new session token
  Future<String> login(int userId) async {
    // Generate a new UUID session token
    final token = _uuid.v4();
    final now = DateTime.now();

    _sessionToken = token;
    _currentUserId = userId;
    _sessionCreatedAt = now;

    await _storage.write(key: _keySessionToken, value: token);
    await _storage.write(key: _keyUserId, value: userId.toString());
    await _storage.write(key: _keySessionCreatedAt, value: now.toIso8601String());

    return token;
  }

  /// Logout and clear all session data
  Future<void> logout() async {
    _sessionToken = null;
    _currentUserId = null;
    _sessionCreatedAt = null;

    await _storage.delete(key: _keySessionToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keySessionCreatedAt);
  }

  /// Check if user is logged in with a valid session
  bool get isLoggedIn => 
      _sessionToken != null && _currentUserId != null && !isSessionExpired;

  /// Check if session has expired
  bool get isSessionExpired {
    if (_sessionCreatedAt == null) return true;
    return DateTime.now().difference(_sessionCreatedAt!) > sessionDuration;
  }

  /// Get current user ID (null if not logged in)
  int? get currentUserId => isLoggedIn ? _currentUserId : null;

  /// Get current session token (null if not logged in)
  String? get sessionToken => isLoggedIn ? _sessionToken : null;

  /// Refresh the session (extend expiration)
  Future<void> refreshSession() async {
    if (_currentUserId != null && _sessionToken != null) {
      final now = DateTime.now();
      _sessionCreatedAt = now;
      await _storage.write(key: _keySessionCreatedAt, value: now.toIso8601String());
    }
  }
}
