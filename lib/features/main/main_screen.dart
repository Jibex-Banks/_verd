import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/features/home/home_screen.dart';
import 'package:verd/features/profile/profile_screen.dart';
import 'package:verd/features/scan/scan_screen.dart';
import 'package:verd/shared/widgets/connectivity_banner.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: designTheme.surface,
      body: ConnectivityBanner(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(
              onScanTap: () => _onTabTapped(1),
              onProfileTap: () => _onTabTapped(2),
            ),
            ScanScreen(isActive: _currentIndex == 1),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            color: designTheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          child: GNav(
            selectedIndex: _currentIndex,
            onTabChange: _onTabTapped,
            rippleColor: designTheme.primary.withOpacity(0.15),
            hoverColor: designTheme.primary.withOpacity(0.05),
            haptic: true,
            tabBorderRadius: 16,
            tabActiveBorder: Border.all(
              color: designTheme.primary.withOpacity(0.1),
              width: 1,
            ),
            tabBorder: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
            tabShadow: [
              BoxShadow(
                color: designTheme.primary.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
            curve: Curves.easeOutExpo,
            duration: const Duration(
              milliseconds: 300,
            ),
            gap: 8,
            color: designTheme.textDim,
            activeColor: colorScheme.onPrimary,
            iconSize: 24,
            tabBackgroundColor: designTheme.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ), // navigation bar padding
            tabs: [
              GButton(
                icon: Icons.home_outlined,
                text: AppLocalizations.of(context)?.home ?? 'Home',
              ),
              GButton(
                icon: Icons.camera_alt_outlined,
                text: AppLocalizations.of(context)?.scan ?? 'Scan',
              ),
              GButton(
                icon: Icons.person_outline,
                text: AppLocalizations.of(context)?.profile ?? 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
