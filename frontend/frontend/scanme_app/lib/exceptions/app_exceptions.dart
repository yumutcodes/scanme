/// Base exception class for all app-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.noConnection() => NetworkException(
    'No internet connection available',
    code: 'NO_CONNECTION',
  );

  factory NetworkException.timeout() =>
      NetworkException('Request timed out', code: 'TIMEOUT');

  factory NetworkException.serverError() =>
      NetworkException('Server error occurred', code: 'SERVER_ERROR');
}

/// Product lookup exceptions
class ProductException extends AppException {
  ProductException(super.message, {super.code, super.originalError});

  factory ProductException.notFound(String barcode) => ProductException(
    'Product not found for barcode: $barcode',
    code: 'NOT_FOUND',
  );

  factory ProductException.invalidBarcode(String barcode) => ProductException(
    'Invalid barcode format: $barcode',
    code: 'INVALID_BARCODE',
  );

  factory ProductException.fetchFailed(dynamic error) => ProductException(
    'Failed to fetch product data',
    code: 'FETCH_FAILED',
    originalError: error,
  );
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalError});

  factory AuthException.invalidCredentials() =>
      AuthException('Invalid email or password', code: 'INVALID_CREDENTIALS');

  factory AuthException.userNotFound() =>
      AuthException('User not found', code: 'USER_NOT_FOUND');

  factory AuthException.userAlreadyExists() => AuthException(
    'An account with this email already exists',
    code: 'USER_EXISTS',
  );

  factory AuthException.sessionExpired() => AuthException(
    'Your session has expired. Please login again.',
    code: 'SESSION_EXPIRED',
  );

  factory AuthException.weakPassword() => AuthException(
    'Password is too weak. Use at least 6 characters.',
    code: 'WEAK_PASSWORD',
  );
}

/// Database exceptions
class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.originalError});

  factory DatabaseException.readFailed(dynamic error) => DatabaseException(
    'Failed to read from database',
    code: 'READ_FAILED',
    originalError: error,
  );

  factory DatabaseException.writeFailed(dynamic error) => DatabaseException(
    'Failed to write to database',
    code: 'WRITE_FAILED',
    originalError: error,
  );
}

/// Storage exceptions
class StorageException extends AppException {
  StorageException(super.message, {super.code, super.originalError});

  factory StorageException.readFailed(dynamic error) => StorageException(
    'Failed to read from secure storage',
    code: 'READ_FAILED',
    originalError: error,
  );

  factory StorageException.writeFailed(dynamic error) => StorageException(
    'Failed to write to secure storage',
    code: 'WRITE_FAILED',
    originalError: error,
  );
}
