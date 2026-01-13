import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanme_app/exceptions/app_exceptions.dart';

/// A reusable error display widget with retry functionality.
class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? code;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.code,
    this.onRetry,
    this.icon,
    this.iconColor,
  });

  /// Factory constructor from AppException
  factory ErrorDisplay.fromException(AppException exception, {VoidCallback? onRetry}) {
    IconData iconData;
    Color color;
    
    switch (exception) {
      case NetworkException():
        iconData = Icons.wifi_off_rounded;
        color = Colors.orange;
        break;
      case ProductException():
        iconData = Icons.search_off_rounded;
        color = Colors.amber;
        break;
      case AuthException():
        iconData = Icons.lock_outline;
        color = Colors.red;
        break;
      default:
        iconData = Icons.error_outline_rounded;
        color = Colors.red;
    }
    
    return ErrorDisplay(
      message: exception.message,
      code: exception.code,
      onRetry: onRetry,
      icon: iconData,
      iconColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.red).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 40,
                color: iconColor ?? Colors.red,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 24),
            
            // Error Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            
            if (code != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error code: $code',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
            
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ).animate().fadeIn(delay: 400.ms).scale(),
            ],
          ],
        ),
      ),
    );
  }
}

/// A snackbar helper for showing errors with retry option.
class ErrorSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
  
  /// Show an error from an exception
  static void showException(
    BuildContext context,
    AppException exception, {
    VoidCallback? onRetry,
  }) {
    show(context, message: exception.message, onRetry: onRetry);
  }
}
