import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_button.dart';

/// Zero / empty state widget with optional illustration, title, subtitle,
/// and up to two action buttons.
class EmptyState extends StatelessWidget {
  final Widget? illustration;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const EmptyState({
    super.key,
    this.illustration,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  factory EmptyState.noScans({VoidCallback? onScan}) => EmptyState(
    icon: Icons.document_scanner_outlined,
    title: 'No Scans Yet',
    subtitle: 'Take your first photo to check\nyour crop health instantly.',
    actionLabel: 'Scan a Crop',
    onAction: onScan,
  );

  factory EmptyState.noConnection({VoidCallback? onRetry}) => EmptyState(
    icon: Icons.wifi_off_outlined,
    title: 'No Connection',
    subtitle: 'Check your internet connection\nand try again.',
    actionLabel: 'Retry',
    onAction: onRetry,
  );

  factory EmptyState.noResults({String? query, VoidCallback? onClear}) =>
      EmptyState(
        icon: Icons.search_off_outlined,
        title: 'No Results Found',
        subtitle: query != null
            ? 'We couldn\'t find anything for "$query".'
            : 'Try adjusting your search.',
        actionLabel: 'Clear Search',
        onAction: onClear,
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    // Icon container scales with screen
    final iconContainerSize = (size.width * 0.24).clamp(72.0, 100.0);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else if (icon != null)
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: const BoxDecoration(
                  color: AppColors.gray100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconContainerSize * 0.45,
                  color: AppColors.gray400,
                ),
              ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              title,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontSize: AppTypography.xl * scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppTypography.base * scaleFactor,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],

            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: secondaryActionLabel!,
                onPressed: onSecondaryAction,
                variant: AppButtonVariant.ghost,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}