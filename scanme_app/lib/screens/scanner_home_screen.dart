import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScannerHomeScreen extends StatelessWidget {
  const ScannerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Camera feel
      body: Stack(
        children: [
          // Mock Camera Preview
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Preview',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          ),
          
          // Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.flash_off, color: Colors.white),
                        onPressed: () {},
                      ),
                      const Text(
                        'Scan Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () {
                          // Profile
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Scanner Box
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF00C9A7), width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        // Corner decors
                        Positioned(
                          top: 0, left: 0, 
                          child: Container(width: 40, height: 40, 
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF00C9A7), width: 6),
                                left: BorderSide(color: Color(0xFF00C9A7), width: 6),
                                
                              ),
                               borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                            ))),
                             Positioned(
                          top: 0, right: 0, 
                          child: Container(width: 40, height: 40, 
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF00C9A7), width: 6),
                                right: BorderSide(color: Color(0xFF00C9A7), width: 6),
                                
                              ),
                               borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                            ))),
                             Positioned(
                          bottom: 0, left: 0, 
                          child: Container(width: 40, height: 40, 
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF00C9A7), width: 6),
                                left: BorderSide(color: Color(0xFF00C9A7), width: 6),
                                
                              ),
                               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                            ))),
                             Positioned(
                          bottom: 0, right: 0, 
                          child: Container(width: 40, height: 40, 
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF00C9A7), width: 6),
                                right: BorderSide(color: Color(0xFF00C9A7), width: 6),
                                
                              ),
                               borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                            ))),
                        
                        // Scanning Animation Line
                        Center(child: Container(
                          height: 2,
                          width: 260,
                          color: const Color(0xFF00C9A7).withValues(alpha: 0.5),
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .slideY(begin: -60, end: 60, duration: 2000.ms),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                
                // Bottom Instructions
                const Text(
                  'Point your camera at a barcode',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                
                // Scan Button (Simulation)
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/result');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    ),
                    child: const Text('Simulate Scan'),
                  ).animate().scale(delay: 500.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
