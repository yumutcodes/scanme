import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// Singleton service for monitoring network connectivity.
/// Provides real-time connectivity status and stream for listening to changes.
class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();
  
  // Stream controller for broadcasting connectivity changes
  final StreamController<bool> _connectivityController = 
      StreamController<bool>.broadcast();
  
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;
  bool _isInitialized = false;

  /// Whether the device currently has network connectivity
  bool get isOnline => _isOnline;

  /// Stream of connectivity status changes (true = online, false = offline)
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Initialize the connectivity service and start monitoring
  Future<void> init() async {
    if (_isInitialized) return;
    
    _logger.d('Initializing ConnectivityService');
    
    // Check initial connectivity status
    await _checkConnectivity();
    
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _handleConnectivityChange(results);
      },
      onError: (error) {
        _logger.e('Connectivity monitoring error', error: error);
      },
    );
    
    _isInitialized = true;
    _logger.i('ConnectivityService initialized - Online: $_isOnline');
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      _logger.e('Failed to check connectivity', error: e);
      // Assume online if we can't check (fail open for better UX)
      _updateStatus(true);
    }
  }

  /// Handle connectivity change events
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final bool wasOnline = _isOnline;
    
    // Check if we have any connectivity
    // ConnectivityResult.none means no network
    final bool nowOnline = results.isNotEmpty && 
        !results.every((result) => result == ConnectivityResult.none);
    
    if (wasOnline != nowOnline) {
      _logger.i('Connectivity changed: ${wasOnline ? "online" : "offline"} -> ${nowOnline ? "online" : "offline"}');
    }
    
    _updateStatus(nowOnline);
  }

  /// Update the connectivity status and notify listeners
  void _updateStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _connectivityController.add(_isOnline);
    }
  }

  /// Force a refresh of the connectivity status
  Future<bool> refresh() async {
    await _checkConnectivity();
    return _isOnline;
  }

  /// Check if we have a specific type of connection
  Future<bool> hasWifi() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi);
    } catch (e) {
      return false;
    }
  }

  /// Check if we have mobile data connection
  Future<bool> hasMobileData() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
    _isInitialized = false;
    _logger.d('ConnectivityService disposed');
  }
}
