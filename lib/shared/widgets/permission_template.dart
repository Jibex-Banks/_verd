import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_button.dart';

/// A single bullet row used in permission screens.
class _PermissionBullet extends StatelessWidget {
  final String text;
  final Color checkColor;

  const _PermissionBullet({required this.text, required this.checkColor});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: checkColor, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 13),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: AppTypography.base * scaleFactor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable full-screen permission request template.
/// Uses [LayoutBuilder] + [SingleChildScrollView] so it adapts to any screen
/// height, including short phones and landscape orientation.
class PermissionTemplate extends StatelessWidget {
  final Widget iconWidget;
  final Color iconBackgroundColor;
  final String title;
  final String description;
  final List<String> bulletPoints;
  final Color bulletColor;
  final String actionButtonText;
  final VoidCallback onAction;
  final VoidCallback? onSkip;
  final String? footerNote;

  const PermissionTemplate({
    super.key,
    required this.iconWidget,
    required this.iconBackgroundColor,
    required this.title,
    required this.description,
    required this.bulletPoints,
    required this.bulletColor,
    required this.actionButtonText,
    required this.onAction,
    this.onSkip,
    this.footerNote,
  });

  // ── Named constructors matching the 3 design screens ──────────────────────

  factory PermissionTemplate.camera({
    Key? key,
    required VoidCallback onAllow,
    VoidCallback? onSkip,
  }) =>
      PermissionTemplate(
        key: key,
        iconBackgroundColor: AppColors.primary,
        iconWidget:
        const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 48),
        title: 'Camera Access Required',
        description:
        'VERD needs access to your camera to\nscan crops and identify diseases.',
        bulletPoints: const [
          'Take photos of crops for instant analysis',
          'Identify diseases in real-time',
          'Save scan history with photos',
        ],
        bulletColor: AppColors.primary,
        actionButtonText: 'Allow Camera Access',
        onAction: onAllow,
        onSkip: onSkip,
        footerNote:
        'Your photos are processed securely and never\nshared without your permission.',
      );

  factory PermissionTemplate.location({
    Key? key,
    required VoidCallback onAllow,
    VoidCallback? onSkip,
  }) =>
      PermissionTemplate(
        key: key,
        iconBackgroundColor: AppColors.info,
        iconWidget:
        const Icon(Icons.location_on_outlined, color: Colors.white, size: 48),
        title: 'Location Access',
        description:
        'Enable location to get localized crop\ndisease warnings and weather updates.',
        bulletPoints: const [
          'Get regional disease alerts',
          'Receive weather-based recommendations',
          'Find nearby agricultural resources',
        ],
        bulletColor: AppColors.info,
        actionButtonText: 'Allow Location Access',
        onAction: onAllow,
        onSkip: onSkip,
        footerNote:
        'Your location data is used only for providing\nrelevant information and is never shared.',
      );

  factory PermissionTemplate.notifications({
    Key? key,
    required VoidCallback onAllow,
    VoidCallback? onSkip,
  }) =>
      PermissionTemplate(
        key: key,
        iconBackgroundColor: AppColors.warning,
        iconWidget: const Icon(Icons.notifications_outlined,
            color: Colors.white, size: 48),
        title: 'Stay Informed',
        description:
        'Get timely notifications about disease outbreaks,\nscan results, and important agricultural updates.',
        bulletPoints: const [
          'Instant scan completion alerts',
          'Disease outbreak warnings',
          'Weekly crop health reports',
        ],
        bulletColor: AppColors.warning,
        actionButtonText: 'Enable Notifications',
        onAction: onAllow,
        onSkip: onSkip,
        footerNote:
        'You can customize notification preferences\nanytime in settings.',
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    // Icon circle scales between 120–160px depending on screen height
    final iconSize = (size.height * 0.20).clamp(120.0, 160.0);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Skip — fixed at top
            SizedBox(
              height: 44,
              child: onSkip != null
                  ? Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: AppTypography.base * scaleFactor,
                    ),
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),

            // Scrollable content — handles short screens / landscape
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    // Icon circle
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: iconBackgroundColor.withValues(alpha: 0.35),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(child: iconWidget),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Title
                    Text(
                      title,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: AppTypography.xxl * scaleFactor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Description
                    Text(
                      description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: AppTypography.base * scaleFactor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: size.height * 0.035),

                    // Bullet points
                    ...bulletPoints.map((p) => _PermissionBullet(
                      text: p,
                      checkColor: bulletColor,
                    )),

                    SizedBox(height: size.height * 0.04),

                    // Action button
                    AppButton(
                      text: actionButtonText,
                      onPressed: onAction,
                      customColor: iconBackgroundColor,
                    ),

                    if (footerNote != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        footerNote!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: AppTypography.xs * scaleFactor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}