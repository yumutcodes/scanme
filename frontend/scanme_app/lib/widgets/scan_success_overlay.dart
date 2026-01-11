import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated checkmark overlay shown on successful barcode scan.
/// Displays for a brief moment before navigation to result screen.
class ScanSuccessOverlay extends StatelessWidget {
  const ScanSuccessOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated checkmark container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00C9A7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C9A7).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 60,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shake(duration: 200.ms, hz: 3),
            
            const SizedBox(height: 24),
            
            // Success text
            const Text(
              'Barcode Detected!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 200.ms)
                .slideY(begin: 0.5, end: 0),
            
            const SizedBox(height: 8),
            
            Text(
              'Loading product info...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 200.ms),
          ],
        ),
      ),
    );
  }
}
