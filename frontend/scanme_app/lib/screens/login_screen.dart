import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanme_app/services/database_helper.dart';
import 'package:scanme_app/services/session_manager.dart';
import 'package:scanme_app/services/hash_service.dart';
import 'package:scanme_app/services/api_service.dart';
import 'package:scanme_app/exceptions/app_exceptions.dart';
import 'package:scanme_app/widgets/error_display.dart';
import 'package:logger/logger.dart';
import 'package:scanme_app/config/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim().toLowerCase();
        final password = _passwordController.text;

        String? jwtToken;

        // 1. Try Online Login (if not in mock mode)
        if (!AppConfig.useMockData) {
          try {
            jwtToken = await ApiService.login(email, password);
          } catch (e) {
            _logger.w('Online login attempt failed, falling back to local: $e');
          }
        }

        User? user;

        if (jwtToken != null) {
          // Online Success
          _logger.i('Online login successful');

          // Ensure user exists locally for offline capability
          user = await DatabaseHelper.instance.getUserByEmail(email);
          if (user == null) {
            // Create local user
            final hashedPassword = HashService().hashPassword(password);
            final newUser = User(email: email, password: hashedPassword);
            final id = await DatabaseHelper.instance.createUser(newUser);
            user = User(id: id, email: email, password: hashedPassword);
          }

          // Start Session with JWT
          await SessionManager().login(user.id!, jwtToken: jwtToken);

          // Sync Data
          await ApiService.syncUserData(user.id!);
        } else {
          // 2. Offline Fallback
          _logger.i('Attempting offline login');

          user = await DatabaseHelper.instance.getUserByEmail(email);

          if (user == null) {
            throw AuthException.invalidCredentials();
          }

          final isValidPassword = HashService().verifyPassword(
            password,
            user.password,
          );
          if (!isValidPassword) {
            throw AuthException.invalidCredentials();
          }

          // Start Session (Local only)
          await SessionManager().login(user.id!);
        }

        if (user.id == null) {
          throw AuthException.userNotFound();
        }

        _logger.i('User logged in successfully: ${user.email}');

        // Navigate to scanner
        if (mounted) context.go('/scan');
      } on AuthException catch (e) {
        _logger.w('Login failed: ${e.message}');
        if (mounted) {
          ErrorSnackbar.showException(context, e);
        }
      } catch (e) {
        _logger.e('Unexpected login error: $e');
        if (mounted) {
          ErrorSnackbar.show(
            context,
            message: 'An unexpected error occurred. Please try again.',
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 80,
                      color: Color(0xFF00C9A7),
                    ).animate().fade(duration: 600.ms).scale(delay: 200.ms),
                    const SizedBox(height: 32),
                    Text(
                      'ScanMe',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00C9A7),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Your personal allergen detector',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms).slideX(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms).slideX(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Login'),
                    ).animate().fadeIn(delay: 500.ms).scale(),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      child: const Text('New here? Create Account'),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
