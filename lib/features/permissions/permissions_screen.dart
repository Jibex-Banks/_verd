import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verd/core/constants/app_theme.dart';
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

  final List<_PermissionPageData> _pages = [
    _PermissionPageData(
      icon: Icons.camera_alt_outlined,
      color: const Color(0xFF4CAF50), // Green
      title: 'Camera Access Required',
      description: 'VERD needs access to your camera to scan crops and identify diseases.',
      benefits: [
        'Take photos of crops for instant analysis',
        'Identify diseases in real-time',
        'Save scan history with photos',
      ],
      buttonText: 'Allow Camera Access',
      permissionDetails: 'Your photos are processed securely and never shared without your permission.',
      permissionStrategy: () => Permission.camera.request(),
    ),
    _PermissionPageData(
      icon: Icons.location_on_outlined,
      color: const Color(0xFF2196F3), // Blue
      title: 'Location Access',
      description: 'Enable location to get localized crop disease warnings and weather updates.',
      benefits: [
        'Get regional disease alerts',
        'Receive weather-based recommendations',
        'Find nearby agricultural resources',
      ],
      buttonText: 'Allow Location Access',
      permissionDetails: 'Your location data is used only for providing relevant information and is never shared.',
      permissionStrategy: () => Permission.location.request(),
    ),
    _PermissionPageData(
      icon: Icons.notifications_none_outlined,
      color: const Color(0xFFFF9800), // Orange
      title: 'Stay Informed',
      description: 'Get timely notifications about disease outbreaks, scan results, and important agricultural updates.',
      benefits: [
        'Instant scan completion alerts',
        'Disease outbreak warnings',
        'Weekly crop health reports',
      ],
      buttonText: 'Enable Notifications',
      permissionDetails: 'You can customize notification preferences anytime in settings.',
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
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar (Skip + Progress Dots) ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProgressDots(
                     count: _pages.length,
                     currentIndex: _currentIndex,
                     activeColor: AppColors.gray800,
                     inactiveColor: AppColors.gray300,
                     dotSize: 8, // Smaller dots compared to onboarding
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip',
                      style: AppTypography.body.copyWith(
                        color: AppColors.gray600,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
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
                        border: Border.all(color: AppColors.backgroundPrimary, width: 3),
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
            style: AppTypography.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.gray600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // ── Benefits List ──
          Column(
            children: data.benefits.map((benefit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: data.color, size: 24),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        benefit,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
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
          const SizedBox(height: AppSpacing.lg),

          // ── Small Print ──
          Text(
            data.permissionDetails,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
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
