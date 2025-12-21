import 'package:go_router/go_router.dart';
import 'package:scanme_app/screens/allergen_selection_screen.dart';
import 'package:scanme_app/screens/login_screen.dart';
import 'package:scanme_app/screens/product_result_screen.dart';
import 'package:scanme_app/screens/register_screen.dart';
import 'package:scanme_app/screens/scanner_home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/allergens',
      builder: (context, state) => const AllergenSelectionScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScannerHomeScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => const ProductResultScreen(),
    ),
  ],
);
