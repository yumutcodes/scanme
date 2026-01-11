import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:scanme_app/router/app_router.dart';
import 'package:scanme_app/theme/app_theme.dart';
import 'package:scanme_app/services/session_manager.dart';
import 'package:scanme_app/services/connectivity_service.dart';
import 'package:scanme_app/services/onboarding_service.dart';

final Logger _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handlers
  _setupErrorHandlers();

  // Initialize services (order matters - onboarding first for initial route)
  await OnboardingService().init();
  await SessionManager().init();
  await ConnectivityService().init();

  runApp(const ScanMeApp());
}

/// Sets up global error handlers for both Flutter and Dart errors
void _setupErrorHandlers() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    _logger.e(
      'Flutter Error: ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );

    // In debug mode, also print to console with more details
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Handle errors that escape the Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    _logger.e(
      'Platform Error: $error',
      error: error,
      stackTrace: stack,
    );
    return true; // Return true to prevent the error from propagating
  };

  // Handle async errors
  runZonedGuarded(() {
    // This zone captures any async errors that weren't caught
  }, (error, stackTrace) {
    _logger.e(
      'Async Error: $error',
      error: error,
      stackTrace: stackTrace,
    );
  });
}

class ScanMeApp extends StatelessWidget {
  const ScanMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ScanMe',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      // Global error widget builder for widget errors
      builder: (context, child) {
        // Set up error widget for release mode
        ErrorWidget.builder = (FlutterErrorDetails details) {
          if (kDebugMode) {
            // In debug mode, show the default error widget
            return ErrorWidget(details.exception);
          }
          // In release mode, show a user-friendly error widget
          return _AppErrorWidget(details: details);
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// User-friendly error widget for production
class _AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const _AppErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We encountered an unexpected error.\nPlease restart the app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    details.exceptionAsString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
