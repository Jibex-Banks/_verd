import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/shared/widgets/app_button.dart';
import 'package:verd/shared/widgets/progress_dots.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<_PermissionPageData> get _pages => [
    _PermissionPageData(
      icon: Icons.location_on_outlined,
      color: const Color(0xFF2196F3), // Blue
      title: AppLocalizations.of(context)!.perm_location_title,
      description: AppLocalizations.of(context)!.perm_location_desc,
      benefits: [
        AppLocalizations.of(context)!.perm_location_benefit1,
        AppLocalizations.of(context)!.perm_location_benefit2,
        AppLocalizations.of(context)!.perm_location_benefit3,
      ],
      buttonText: AppLocalizations.of(context)!.perm_location_btn,
      permissionDetails: AppLocalizations.of(context)!.perm_location_details,
      permissionStrategy: () => Permission.location.request(),
    ),
    _PermissionPageData(
      icon: Icons.notifications_none_outlined,
      color: const Color(0xFFFF9800), // Orange
      title: AppLocalizations.of(context)!.perm_notif_title,
      description: AppLocalizations.of(context)!.perm_notif_desc,
      benefits: [
        AppLocalizations.of(context)!.perm_notif_benefit1,
        AppLocalizations.of(context)!.perm_notif_benefit2,
        AppLocalizations.of(context)!.perm_notif_benefit3,
      ],
      buttonText: AppLocalizations.of(context)!.perm_notif_btn,
      permissionDetails: AppLocalizations.of(context)!.perm_notif_details,
      permissionStrategy: () => Permission.notification.request(),
      badgeScore: 3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handlePermissionRequest() async {
    final pageData = _pages[_currentIndex];
    await pageData.permissionStrategy();
    
    // We proceed whether granted or denied. If permanently denied, 
    // a production app might show settings dialog, but typically in onboarding
    // you just advance so they don't get stuck.
    _advanceToNextPage();
  }

  void _skip() {
    _advanceToNextPage();
  }

  void _advanceToNextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishPermissions();
    }
  }

  void _finishPermissions() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    return Scaffold(
      backgroundColor: designTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar (Skip + Progress Dots) ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProgressDots(
                     count: _pages.length,
                     currentIndex: _currentIndex,
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.skip,
                      style: designTheme.bodyRegular.copyWith(
                        color: designTheme.textDim,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Page View Content ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping so they read it
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPageContent(_pages[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(_PermissionPageData data) {
    final designTheme = AppDesignSystem.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24.0),
          // ── Hero Icon ──
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: data.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      data.icon,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (data.badgeScore != null)
                  Positioned(
                    top: 10,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935), // Red badge
                        shape: BoxShape.circle,
                        border: Border.all(color: designTheme.background, width: 3),
                      ),
                      child: Text(
                        data.badgeScore.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // ── Title & Description ──
          Text(
            data.title,
            style: designTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: designTheme.textMain,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),
          Text(
            data.description,
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.textDim,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // ── Benefits List ──
          Column(
            children: data.benefits.map((benefit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: data.color, size: 24),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        benefit,
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),

          // ── Button ──
          AppButton(
            text: data.buttonText,
            onPressed: _handlePermissionRequest,
            customColor: data.color,
          ),
          const SizedBox(height: 24.0),

          // ── Small Print ──
          Text(
            data.permissionDetails,
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.textDim.withOpacity(0.6),
              fontSize: 11,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PermissionPageData {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final List<String> benefits;
  final String buttonText;
  final String permissionDetails;
  final Future<PermissionStatus> Function() permissionStrategy;
  final int? badgeScore;

  _PermissionPageData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.benefits,
    required this.buttonText,
    required this.permissionDetails,
    required this.permissionStrategy,
    this.badgeScore,
  });
}
