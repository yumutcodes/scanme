import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service for securely hashing passwords using SHA-256.
/// In production, consider using bcrypt or Argon2 via a backend service.
class HashService {
  static final HashService _instance = HashService._internal();
  factory HashService() => _instance;
  HashService._internal();

  /// Hashes a password with a salt using SHA-256.
  /// Returns the combined salt and hash as a single string.
  String hashPassword(String password, {String? salt}) {
    // Generate a new salt if not provided
    salt ??= _generateSalt();
    
    // Combine password and salt, then hash
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    
    // Return salt:hash format for storage
    return '$salt:${digest.toString()}';
  }

  /// Verifies a password against a stored hash.
  /// The stored hash should be in the format "salt:hash".
  bool verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;
      
      final salt = parts[0];
      final expectedHash = parts[1];
      
      // Hash the password with the extracted salt
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      
      // Constant-time comparison to prevent timing attacks
      return _constantTimeEquals(digest.toString(), expectedHash);
    } catch (e) {
      return false;
    }
  }

  /// Generates a random salt using current timestamp and random component.
  /// For production, use a cryptographically secure random generator.
  String _generateSalt() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = timestamp.hashCode ^ DateTime.now().hashCode;
    final bytes = utf8.encode('$timestamp$random');
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  /// Constant-time string comparison to prevent timing attacks.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
