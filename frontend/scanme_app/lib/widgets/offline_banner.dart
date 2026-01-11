import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Banner widget that shows when the device is offline.
/// Designed to slide in from the top with a smooth animation.
class OfflineBanner extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onRetry;
  
  const OfflineBanner({
    super.key,
    required this.isVisible,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      child: isVisible
          ? _OfflineBannerContent(onRetry: onRetry)
          : const SizedBox.shrink(),
    );
  }
}

class _OfflineBannerContent extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const _OfflineBannerContent({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade600,
            Colors.orange.shade800,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated wifi-off icon
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 20,
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.6, end: 1.0, duration: 1000.ms),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No internet connection',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact inline offline indicator for use within other widgets
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
