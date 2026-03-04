import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

enum StatusBarVariant { success, error, warning, info }

/// Inline status / alert banner — success, error, warning, or info.
class AppStatusBar extends StatelessWidget {
  final String message;
  final StatusBarVariant variant;
  final Widget? leading;
  final Widget? action;
  final VoidCallback? onDismiss;
  final bool showIcon;

  const AppStatusBar({
    super.key,
    required this.message,
    this.variant = StatusBarVariant.info,
    this.leading,
    this.action,
    this.onDismiss,
    this.showIcon = true,
  });

  factory AppStatusBar.success({
    required String message,
    VoidCallback? onDismiss,
    Widget? action,
  }) =>
      AppStatusBar(
        message: message,
        variant: StatusBarVariant.success,
        onDismiss: onDismiss,
        action: action,
      );

  factory AppStatusBar.error({
    required String message,
    VoidCallback? onDismiss,
    Widget? action,
  }) =>
      AppStatusBar(
        message: message,
        variant: StatusBarVariant.error,
        onDismiss: onDismiss,
        action: action,
      );

  factory AppStatusBar.warning({
    required String message,
    VoidCallback? onDismiss,
    Widget? action,
  }) =>
      AppStatusBar(
        message: message,
        variant: StatusBarVariant.warning,
        onDismiss: onDismiss,
        action: action,
      );

  factory AppStatusBar.info({
    required String message,
    VoidCallback? onDismiss,
    Widget? action,
  }) =>
      AppStatusBar(
        message: message,
        variant: StatusBarVariant.info,
        onDismiss: onDismiss,
        action: action,
      );

  Color get _bg => switch (variant) {
    StatusBarVariant.success => AppColors.success.withValues(alpha: 0.10),
    StatusBarVariant.error   => AppColors.error.withValues(alpha: 0.10),
    StatusBarVariant.warning => AppColors.warning.withValues(alpha: 0.10),
    StatusBarVariant.info    => AppColors.info.withValues(alpha: 0.10),
  };

  Color get _fg => switch (variant) {
    StatusBarVariant.success => AppColors.successDark,
    StatusBarVariant.error   => AppColors.errorDark,
    StatusBarVariant.warning => AppColors.warningDark,
    StatusBarVariant.info    => AppColors.infoDark,
  };

  Color get _border => switch (variant) {
    StatusBarVariant.success => AppColors.success,
    StatusBarVariant.error   => AppColors.error,
    StatusBarVariant.warning => AppColors.warning,
    StatusBarVariant.info    => AppColors.info,
  };

  IconData get _icon => switch (variant) {
    StatusBarVariant.success => Icons.check_circle_outline,
    StatusBarVariant.error   => Icons.error_outline,
    StatusBarVariant.warning => Icons.warning_amber_outlined,
    StatusBarVariant.info    => Icons.info_outline,
  };

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);

    return Semantics(
      // Announce to screen readers using the appropriate role
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: _border.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Leading icon or custom widget
            if (leading != null)
              leading!
            else if (showIcon)
              Icon(_icon, size: 18, color: _fg),

            const SizedBox(width: AppSpacing.sm),

            // Message — flexible so it wraps on narrow screens
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: _fg,
                  fontWeight: AppTypography.medium,
                  fontSize: AppTypography.sm * scaleFactor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Optional trailing action
            if (action != null) ...[
              const SizedBox(width: AppSpacing.xs),
              action!,
            ],

            // Dismiss button — meets 44px touch target
            if (onDismiss != null) ...[
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: onDismiss,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(Icons.close, size: 16, color: _fg),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}