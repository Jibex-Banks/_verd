import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';

class Navbar extends StatelessWidget {
  final String currentView;
  final Function(String) onViewChanged;

  const Navbar({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo
            GestureDetector(
              onTap: () => onViewChanged('home'),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: VerdTheme.glassDecoration(opacity: 0.1),
                    child: Image.asset('assets/logo.png', width: 32, height: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('VERD', style: Theme.of(context).textTheme.titleLarge),
                      Text('AGRONOMY HUB', style: TextStyle(fontSize: 8, color: VerdTheme.textDim, letterSpacing: 2)),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Nav Links
            _NavLink(label: 'SCAN', isActive: currentView == 'scan', onTap: () => onViewChanged('scan')),
            _NavLink(label: 'INSIGHTS', isActive: currentView == 'insights', onTap: () => onViewChanged('insights')),
            _NavLink(label: 'DASHBOARD', isActive: currentView == 'dashboard', onTap: () => onViewChanged('dashboard')),
            _NavLink(label: 'HISTORY', isActive: currentView == 'history', onTap: () => onViewChanged('history')),
            _NavLink(label: 'LEARNING', isActive: currentView == 'learning', onTap: () => onViewChanged('learning')),
            
            const SizedBox(width: 40),
            
            // Profile Action
            ElevatedButton(
              onPressed: () => onViewChanged('profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: VerdTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('PROFILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isActive ? VerdTheme.primary : VerdTheme.textDim,
          ),
        ),
      ),
    );
  }
}
