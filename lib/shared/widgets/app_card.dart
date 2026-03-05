import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

enum AppCardVariant { elevated, outlined, filled, ghost }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool clipContent;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.clipContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? AppRadius.card;

    // Responsive padding: scales slightly with screen width
    final sw = MediaQuery.sizeOf(context).width;
    final defaultPadding = sw < 360
        ? const EdgeInsets.all(AppSpacing.md)
        : const EdgeInsets.all(AppSpacing.cardPadding);
    final effectivePadding = padding ?? defaultPadding;

    BoxDecoration decoration = switch (variant) {
      AppCardVariant.elevated => BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          if (theme.brightness == Brightness.light) AppShadows.card
        ],
      ),
      AppCardVariant.outlined => BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
      ),
      AppCardVariant.filled => BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      AppCardVariant.ghost => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
      ),
    };

    Widget content = Container(
      margin: margin,
      decoration: decoration,
      clipBehavior: clipContent ? Clip.antiAlias : Clip.none,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Dashboard stat card — icon + label + value, responsive 2-column grid friendly
class AppStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget icon;
  final Color? iconBackgroundColor;
  final Color? valueColor;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconBackgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.h3.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
                fontSize: AppTypography.xl * scaleFactor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: AppTypography.sm * scaleFactor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}