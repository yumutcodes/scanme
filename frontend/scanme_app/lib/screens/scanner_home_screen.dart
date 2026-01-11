import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import 'package:scanme_app/services/connectivity_service.dart';
import 'package:scanme_app/widgets/offline_banner.dart';
import 'package:scanme_app/widgets/scan_success_overlay.dart';

class ScannerHomeScreen extends StatefulWidget {
  const ScannerHomeScreen({super.key});

  @override
  State<ScannerHomeScreen> createState() => _ScannerHomeScreenState();
}

class _ScannerHomeScreenState extends State<ScannerHomeScreen>
    with RouteAware, WidgetsBindingObserver {
  // Mobile Scanner Controller for torch control
  late MobileScannerController _controller;
  bool _isScanning = true;
  bool _isTorchOn = false;
  bool _isControllerInitialized = false;
  bool _showSuccessOverlay = false;
  String? _scannedBarcode;

  // Store router delegate reference for cleanup
  RouterDelegate<Object>? _routerDelegate;

  // Connectivity monitoring
  bool _isOnline = true;
  StreamSubscription<bool>? _connectivitySubscription;

  // Vibration support
  bool _canVibrate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
    _initConnectivity();
    _checkVibrationSupport();
  }

  void _initConnectivity() {
    // Get initial connectivity state
    _isOnline = ConnectivityService().isOnline;

    // Listen for connectivity changes
    _connectivitySubscription = ConnectivityService().onConnectivityChanged
        .listen((isOnline) {
          if (mounted) {
            setState(() {
              _isOnline = isOnline;
            });
          }
        });
  }

  Future<void> _checkVibrationSupport() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (mounted) {
        setState(() {
          _canVibrate = hasVibrator;
        });
      }
    } catch (e) {
      // Vibration not supported
      _canVibrate = false;
    }
  }

  Future<void> _triggerHapticFeedback() async {
    if (_canVibrate) {
      try {
        // Short vibration pattern for successful scan
        await Vibration.vibrate(duration: 100);
      } catch (e) {
        // Ignore vibration errors
      }
    }
  }

  void _initController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _isControllerInitialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to detect when we come back
    // Store the reference so we can unsubscribe in dispose
    if (_routerDelegate == null) {
      _routerDelegate = GoRouter.of(context).routerDelegate;
      _routerDelegate!.addListener(_onRouteChanged);
    }
  }

  void _onRouteChanged() {
    // Check if this screen is now visible (user navigated back)
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      _resumeScanning();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes (going to background/foreground)
    if (!_isControllerInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App is visible again, resume scanning
        _resumeScanning();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        // App is going to background, pause scanning
        _controller.stop();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _resumeScanning() {
    if (!mounted || !_isControllerInitialized) return;

    // Reset scanning state and restart camera
    setState(() {
      _isScanning = true;
    });

    // Restart the controller if it was stopped
    _controller.start();
  }

  void _toggleTorch() async {
    if (!_isControllerInitialized) return;

    try {
      await _controller.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      // Torch might not be available on all devices
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flashlight not available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          _isScanning = false;
          _showSuccessOverlay = true;
          _scannedBarcode = barcode.rawValue;
        });

        // Trigger haptic feedback for successful scan
        _triggerHapticFeedback();

        // Show success animation for 500ms before navigating
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _scannedBarcode != null) {
            setState(() {
              _showSuccessOverlay = false;
            });
            context.push('/result', extra: _scannedBarcode);
          }
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Use stored reference instead of context
    _routerDelegate?.removeListener(_onRouteChanged);
    // Cancel connectivity subscription
    _connectivitySubscription?.cancel();
    _controller.dispose();
    _isControllerInitialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),

          // Success Overlay (shown after scan)
          if (_showSuccessOverlay)
            const ScanSuccessOverlay(),

          // Overlay
          SafeArea(
            child: Column(
              children: [
                // Offline Banner
                OfflineBanner(
                  isVisible: !_isOnline,
                  onRetry: () async {
                    await ConnectivityService().refresh();
                  },
                ),

                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Torch Toggle Button
                      IconButton(
                        icon: Icon(
                          _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: _isTorchOn
                              ? const Color(0xFF00C9A7)
                              : Colors.white,
                        ),
                        onPressed: _toggleTorch,
                        tooltip: _isTorchOn
                            ? 'Turn off flashlight'
                            : 'Turn on flashlight',
                      ),
                      const Text(
                        'Scan Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.history,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              context.push('/history');
                            },
                            tooltip: 'Scan history',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              context.push('/allergens', extra: true);
                            },
                            tooltip: 'Settings',
                          ),
                        ],
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
                      border: Border.all(
                        color: _isScanning
                            ? const Color(0xFF00C9A7)
                            : const Color(0xFF00C9A7).withValues(alpha: 0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        // Corner decors
                        _buildCorner(true, true),
                        _buildCorner(true, false),
                        _buildCorner(false, true),
                        _buildCorner(false, false),

                        // Scanning Animation Line (only show when scanning)
                        if (_isScanning)
                          Center(
                            child:
                                Container(
                                      height: 2,
                                      width: 260,
                                      color: const Color(
                                        0xFF00C9A7,
                                      ).withValues(alpha: 0.5),
                                    )
                                    .animate(
                                      onPlay: (controller) =>
                                          controller.repeat(reverse: true),
                                    )
                                    .slideY(
                                      begin: -60,
                                      end: 60,
                                      duration: 2000.ms,
                                    ),
                          ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Scanning status indicator
                Text(
                  _isScanning
                      ? 'Point your camera at a barcode'
                      : 'Processing...',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),

                // Manual Entry
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Enter Barcode manually',
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: Icon(Icons.search, color: Colors.black54),
                      ),
                      keyboardType: TextInputType.number,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() => _isScanning = false);
                          context.push('/result', extra: value);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Test Button (for development)
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => _isScanning = false);
                      // Test barcode for Nutella: 3017620422003
                      context.push('/result', extra: '3017620422003');
                    },
                    icon: const Icon(Icons.bug_report, color: Colors.white54),
                    label: const Text(
                      'Test: Nutella',
                      style: TextStyle(color: Colors.white54),
                    ),
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
            top: top
                ? const BorderSide(color: Color(0xFF00C9A7), width: 6)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: Color(0xFF00C9A7), width: 6)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: Color(0xFF00C9A7), width: 6)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: Color(0xFF00C9A7), width: 6)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(20) : Radius.zero,
            topRight: top && !left ? const Radius.circular(20) : Radius.zero,
            bottomLeft: !top && left ? const Radius.circular(20) : Radius.zero,
            bottomRight: !top && !left
                ? const Radius.circular(20)
                : Radius.zero,
          ),
        ),
      ),
    );
  }
}
