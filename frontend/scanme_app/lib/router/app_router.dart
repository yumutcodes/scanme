import 'package:go_router/go_router.dart';
import 'package:scanme_app/screens/allergen_selection_screen.dart';
import 'package:scanme_app/screens/login_screen.dart';
import 'package:scanme_app/screens/onboarding_screen.dart';
import 'package:scanme_app/screens/product_result_screen.dart';
import 'package:scanme_app/screens/register_screen.dart';
import 'package:scanme_app/screens/scanner_home_screen.dart';
import 'package:scanme_app/screens/history_screen.dart';
import 'package:scanme_app/services/session_manager.dart';
import 'package:scanme_app/services/onboarding_service.dart';

/// Determines the initial route based on onboarding and login status.
String _getInitialLocation() {
  // First check if onboarding is complete
  if (!OnboardingService().hasCompletedOnboarding) {
    return '/onboarding';
  }
  // Then check if user is logged in
  return SessionManager().isLoggedIn ? '/scan' : '/';
}

final appRouter = GoRouter(
  initialLocation: _getInitialLocation(),
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/allergens',
      builder: (context, state) {
        final fromSettings = state.extra as bool? ?? false;
        return AllergenSelectionScreen(fromSettings: fromSettings);
      },
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScannerHomeScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final barcode = state.extra as String? ?? '0000000000000'; // Default or handle null
        return ProductResultScreen(barcode: barcode);
      },
    ),
    GoRoute(
       path: '/history',
       builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
