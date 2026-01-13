import 'package:shared_preferences/shared_preferences.dart';

/// Service to track onboarding status.
/// Manages first-launch detection for showing onboarding screens.
class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  static const String _keyOnboardingComplete = 'onboarding_complete';
  
  bool _isInitialized = false;
  bool _hasCompletedOnboarding = false;

  /// Initialize onboarding status from storage
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = prefs.getBool(_keyOnboardingComplete) ?? false;
      _isInitialized = true;
    } catch (e) {
      // If we can't read from storage, assume not completed
      _hasCompletedOnboarding = false;
      _isInitialized = true;
    }
  }

  /// Check if onboarding has been completed
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingComplete, true);
    } catch (e) {
      // Ignore storage errors - in-memory state is updated
    }
  }

  /// Reset onboarding status (for testing)
  Future<void> resetOnboarding() async {
    _hasCompletedOnboarding = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyOnboardingComplete);
    } catch (e) {
      // Ignore storage errors
    }
  }
}
