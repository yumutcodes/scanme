import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScannerHomeScreen extends StatefulWidget {
  const ScannerHomeScreen({super.key});

  @override
  State<ScannerHomeScreen> createState() => _ScannerHomeScreenState();
}

class _ScannerHomeScreenState extends State<ScannerHomeScreen> {
  // MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
        });
        
        // Vibrate or sound could go here
        
        context.push('/result', extra: barcode.rawValue);
        break; 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera
          MobileScanner(
            onDetect: _onDetect,
            fit: BoxFit.cover,
             // controller: controller,
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
                        onPressed: () {
                           // controller.toggleTorch();
                        },
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
                        icon: const Icon(Icons.history, color: Colors.white),
                        onPressed: () {
                          context.push('/history');
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Scanner Frame
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
                         // Corner decors (visual only)
                         _buildCorner(true, true),
                         _buildCorner(true, false),
                         _buildCorner(false, true),
                         _buildCorner(false, false),

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
                
                const Text(
                  'Point your camera at a barcode',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                
                // Manual Entry
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter Barcode manually',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Icon(Icons.search, color: Colors.white54),
                      ),
                      keyboardType: TextInputType.number,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                           context.push('/result', extra: value);
                        }
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                 // Manual Input Alternative
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: TextButton.icon(
                    onPressed: () {
                       // Test barcode for Nutella: 3017620422003
                       context.push('/result', extra: '3017620422003');
                    },
                    icon: const Icon(Icons.bug_report, color: Colors.white54),
                    label: const Text('Test: Nutella', style: TextStyle(color: Colors.white54)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildCorner(bool top, bool left) {
    return Positioned(
      top: top ? 0 : null,
      bottom: !top ? 0 : null,
      left: left ? 0 : null,
      right: !left ? 0 : null,
      child: Container(
        width: 40, 
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: Color(0xFF00C9A7), width: 6) : BorderSide.none,
            bottom: !top ? const BorderSide(color: Color(0xFF00C9A7), width: 6) : BorderSide.none,
            left: left ? const BorderSide(color: Color(0xFF00C9A7), width: 6) : BorderSide.none,
            right: !left ? const BorderSide(color: Color(0xFF00C9A7), width: 6) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(20) : Radius.zero,
            topRight: top && !left ? const Radius.circular(20) : Radius.zero,
            bottomLeft: !top && left ? const Radius.circular(20) : Radius.zero,
            bottomRight: !top && !left ? const Radius.circular(20) : Radius.zero,
          ),
        ),
      ),
    );
   }
}
