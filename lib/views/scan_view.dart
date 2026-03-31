import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../ui/glass_card.dart';
import 'dart:math' as math;

class DiagnosticScanner extends StatefulWidget {
  const DiagnosticScanner({super.key});

  @override
  State<DiagnosticScanner> createState() => _DiagnosticScannerState();
}

class _DiagnosticScannerState extends State<DiagnosticScanner> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  bool _isScanning = false;
  String _status = 'IDLE';

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _status = 'ANALYZING';
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isScanning = false;
      _status = 'HEALTHY';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final horizontalPadding = isMobile ? 20.0 : 40.0;
        final scannerSize = math.min(constraints.maxWidth - (horizontalPadding * 2), 400.0);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScannerUI(scannerSize),
                SizedBox(height: isMobile ? 40 : 60),
                _buildControls(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerUI(double size) {
    final scale = size / 400.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Orbit
          RotationTransition(
            turns: _scannerController,
            child: Container(
              width: 380 * scale,
              height: 380 * scale,
              decoration: BoxDecoration(
                border: Border.all(color: VerdTheme.primary.withOpacity(0.1), width: 1),
                shape: BoxType.circle,
              ),
              child: Stack(
                children: [
                   Positioned(
                    top: 0, left: 190 * scale,
                    child: Container(width: 8 * scale, height: 8 * scale, decoration: const BoxDecoration(color: VerdTheme.primary, shape: BoxType.circle)),
                  ),
                ],
              ),
            ),
          ),
          
          // Outer Ring with Glow
          Container(
            width: 320 * scale,
            height: 320 * scale,
            decoration: BoxDecoration(
              shape: BoxType.circle,
              border: Border.all(color: VerdTheme.primary.withOpacity(0.2), width: 2),
              boxShadow: [BoxShadow(color: VerdTheme.primary.withOpacity(0.1), blurRadius: 40 * scale, spreadRadius: 10 * scale)],
            ),
          ),
|
          // Main Viewport
          ClipOval(
            child: Container(
              width: 300 * scale,
              height: 300 * scale,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Neural Background
                  Opacity(opacity: 0.3, child: Icon(LucideIcons.sprout, size: 120 * scale, color: const Color(0x3300D6B1))),
                  
                  // Scanning Line
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _scannerController,
                      builder: (context, child) {
                        return Positioned(
                          top: (150 * scale) + (130 * scale) * math.sin(_scannerController.value * 2 * math.pi),
                          left: 0, right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, VerdTheme.primary.withOpacity(0.5), Colors.transparent],
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                ],
              ),
            ),
          ),

          // Status Badge
          Positioned(
            bottom: 40 * scale,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 6 * scale),
              decoration: BoxDecoration(
                color: _status == 'HEALTHY' ? Colors.emerald : VerdTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: _status == 'HEALTHY' ? Colors.emerald : VerdTheme.primary.withOpacity(0.2)),
              ),
              child: Text(_status, style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SquareButton(icon: LucideIcons.camera, label: 'USE CAMERA', onTap: _startScan, isActive: !_isScanning),
            const SizedBox(width: 24),
            _SquareButton(icon: LucideIcons.upload, label: 'UPLOAD LOG', onTap: () {}, isActive: !_isScanning),
          ],
        ),
        const SizedBox(height: 48),
        Text('SCANNING INFRASTRUCTURE V4.2', style: TextStyle(fontSize: 8, fontWeight: FontWeight.black, color: Colors.white.withOpacity(0.1), letterSpacing: 4)),
      ],
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _SquareButton({required this.icon, required this.label, required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.4,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: VerdTheme.glassDecoration(opacity: 0.1),
              child: Icon(icon, color: VerdTheme.primary, size: 32),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}
