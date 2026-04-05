import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/core/theme/app_design_system.dart';
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

  List<_OnboardingPageData> get _pages => [
    _OnboardingPageData(
      title: AppLocalizations.of(context)!.scan_crops_title,
      description: AppLocalizations.of(context)!.scan_crops_desc,
      imagePath: AppAssets.onboarding1,
      showLogo: true,
    ),
    _OnboardingPageData(
      title: AppLocalizations.of(context)!.get_insights_title,
      description: AppLocalizations.of(context)!.get_insights_desc,
      imagePath: AppAssets.onboarding2,
      showLogo: false,
    ),
    _OnboardingPageData(
      title: AppLocalizations.of(context)!.take_action_title,
      description: AppLocalizations.of(context)!.take_action_desc,
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
    final designTheme = AppDesignSystem.of(context);
    return Scaffold(
      backgroundColor: designTheme.background,
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
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: _currentIndex == _pages.length - 1
                        ? AppLocalizations.of(context)!.get_started
                        : AppLocalizations.of(context)!.next,
                    onPressed: _onNextPressed,
                  ),
                  const SizedBox(height: 16.0),
                  ProgressDots(
                    count: _pages.length,
                    currentIndex: _currentIndex,
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
    final designTheme = AppDesignSystem.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 12.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                AppLocalizations.of(context)!.skip,
                style: designTheme.bodyRegular.copyWith(
                  color: designTheme.textDim,
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
    final designTheme = AppDesignSystem.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.35,
            child: Image.asset(
              data.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.image_not_supported,
                size: 100,
                color: designTheme.textDim,
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          
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
