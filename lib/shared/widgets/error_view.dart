import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';
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
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final size = MediaQuery.sizeOf(context);
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final iconSize = (size.width * 0.22).clamp(64.0, 88.0);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: 32.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: iconSize * 0.45,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              title,
              style: designTheme.titleLarge.copyWith(
                color: designTheme.textMain,
                fontSize: 24.0 * scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8.0),
              Text(
                message!,
                style: designTheme.bodyRegular.copyWith(
                  color: designTheme.textDim,
                  fontSize: 16.0 * scaleFactor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 32.0),
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
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              title,
              style: designTheme.bodyRegular.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14.0 * scaleFactor,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                minimumSize: Size(designTheme.touchTargetMin, designTheme.touchTargetMin),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                retryLabel ?? 'Retry',
                style: designTheme.bodyRegular.copyWith(
                  color: designTheme.primary,
                  fontSize: 14.0 * scaleFactor,
                  fontWeight: FontWeight.w500,
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
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final errorColor = Theme.of(context).colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.08),
        border: Border(
          left: BorderSide(color: errorColor, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 18, color: errorColor),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: designTheme.bodyRegular.copyWith(
                    color: designTheme.textMain,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0 * scaleFactor,
                  ),
                ),
                if (message != null)
                  Text(
                    message!,
                    style: designTheme.bodyRegular.copyWith(
                      color: designTheme.textDim,
                      fontSize: 14.0 * scaleFactor,
                    ),
                  ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                  minimumSize: Size(designTheme.touchTargetMin, designTheme.touchTargetMin)),
              child: Text(
                retryLabel ?? 'Retry',
                style: designTheme.bodyRegular.copyWith(
                  color: designTheme.primary,
                  fontSize: 14.0 * scaleFactor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}