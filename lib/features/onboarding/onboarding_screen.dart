import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_button.dart';
import 'package:verd/shared/widgets/progress_dots.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Scan Your Crops',
      description: 'Just take a photo. VERD checks your plant instantly.',
      imagePath: AppAssets.onboarding1,
      showLogo: true,
    ),
    _OnboardingPageData(
      title: 'Get Clear Insights',
      description: 'Know if your crop is healthy, sick, or lacking nutrients',
      imagePath: AppAssets.onboarding2,
      showLogo: false,
    ),
    _OnboardingPageData(
      title: 'Take Smart Action',
      description: 'Get clear steps to protect your farm and grow more.',
      imagePath: AppAssets.onboarding3,
      showLogo: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    // Navigate to login. In a real app we'd save a "has_seen_onboarding" flag here.
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar (Skip Button or Logo) ──
            _buildTopBar(),

            // ── Page View Content ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
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

            // ── Bottom Section (Button + Dots) ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: _currentIndex == _pages.length - 1
                        ? 'GET STARTED'
                        : 'NEXT',
                    onPressed: _onNextPressed,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ProgressDots(
                    count: _pages.length,
                    currentIndex: _currentIndex,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.gray300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final showLogo = _pages[_currentIndex].showLogo;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showLogo)
            Column(
              children: [
                SvgPicture.asset(AppAssets.logoSvg, height: 40),
                const SizedBox(height: 4),
                const Text(
                  'WELCOME!',
                  style: TextStyle(
                    fontFamily: AppTypography.primaryFont,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Skip',
                style: AppTypography.body.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(_OnboardingPageData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration takes up available space flexibly, but single child scroll view doesn't allow Flexible.
          // Adjust layout to use SizedBox for the image.
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.35,
            child: Image.asset(
              data.imagePath,
              fit: BoxFit.contain,
              // Fallback placeholder during dev if images aren't present yet
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 100,
                color: AppColors.gray300,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          
          Text(
            data.title,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.description,
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;
  final bool showLogo;

  _OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
    this.showLogo = false,
  });
}
