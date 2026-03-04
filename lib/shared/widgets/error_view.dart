import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_button.dart';

enum ErrorViewVariant { fullPage, inline, banner }

/// Flexible error display — full-page, compact inline row, or top banner.
class ErrorView extends StatelessWidget {
  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final ErrorViewVariant variant;
  final IconData? icon;

  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.retryLabel = 'Try Again',
    this.onRetry,
    this.variant = ErrorViewVariant.fullPage,
    this.icon,
  });

  factory ErrorView.network({VoidCallback? onRetry}) => ErrorView(
    title: 'Connection Failed',
    message:
    'Unable to connect to the server.\nPlease check your internet connection.',
    onRetry: onRetry,
    icon: Icons.wifi_off_outlined,
  );

  factory ErrorView.server({VoidCallback? onRetry}) => ErrorView(
    title: 'Server Error',
    message:
    'Our servers are experiencing issues.\nPlease try again in a moment.',
    onRetry: onRetry,
    icon: Icons.cloud_off_outlined,
  );

  factory ErrorView.inline({String? message, VoidCallback? onRetry}) =>
      ErrorView(
        title: message ?? 'Failed to load',
        retryLabel: 'Retry',
        onRetry: onRetry,
        variant: ErrorViewVariant.inline,
      );

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      ErrorViewVariant.fullPage => _FullPage(
        title: title,
        message: message,
        retryLabel: retryLabel,
        onRetry: onRetry,
        icon: icon,
      ),
      ErrorViewVariant.inline => _Inline(
        title: title,
        retryLabel: retryLabel,
        onRetry: onRetry,
      ),
      ErrorViewVariant.banner => _Banner(
        title: title,
        message: message,
        retryLabel: retryLabel,
        onRetry: onRetry,
      ),
    };
  }
}

// ── Full-page ──────────────────────────────────────────────────────────────

class _FullPage extends StatelessWidget {
  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData? icon;

  const _FullPage({
    required this.title,
    this.message,
    this.retryLabel,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final iconSize = (size.width * 0.22).clamp(64.0, 88.0);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: iconSize * 0.45,
                color: AppColors.error,
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
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppTypography.base * scaleFactor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: retryLabel ?? 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Inline ─────────────────────────────────────────────────────────────────

class _Inline extends StatelessWidget {
  final String title;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const _Inline({required this.title, this.retryLabel, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
                fontSize: AppTypography.sm * scaleFactor,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: const Size(44, 44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                retryLabel ?? 'Retry',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontSize: AppTypography.sm * scaleFactor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Banner ─────────────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const _Banner({
    required this.title,
    this.message,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        border: const Border(
          left: BorderSide(color: AppColors.error, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    color: AppColors.errorDark,
                    fontWeight: AppTypography.semibold,
                    fontSize: AppTypography.base * scaleFactor,
                  ),
                ),
                if (message != null)
                  Text(
                    message!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                      fontSize: AppTypography.sm * scaleFactor,
                    ),
                  ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44)),
              child: Text(
                retryLabel ?? 'Retry',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                  fontSize: AppTypography.sm * scaleFactor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}