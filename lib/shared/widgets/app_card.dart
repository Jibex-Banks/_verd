import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

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
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final radius = borderRadius ?? designTheme.radiusStandard;

    // Responsive padding: scales slightly with screen width
    final sw = MediaQuery.sizeOf(context).width;
    final defaultPadding = sw < 360
        ? const EdgeInsets.all(16.0)
        : const EdgeInsets.all(24.0);
    final effectivePadding = padding ?? defaultPadding;

    BoxDecoration decoration = switch (variant) {
      AppCardVariant.elevated => backgroundColor != null
          ? BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(radius))
          : designTheme.glassDecoration(opacity: 0.08, blur: 15.0),
      AppCardVariant.outlined => BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: designTheme.textDim.withOpacity(0.2), width: 1.5),
      ),
      AppCardVariant.filled => BoxDecoration(
        color: backgroundColor ?? designTheme.surface,
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
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);

    return AppCard(
      variant: AppCardVariant.elevated, // Will inherit glassmorphism now
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // Touch-target minimum compliance applied to layout hitboxes
            width: designTheme.touchTargetMin,
            height: designTheme.touchTargetMin,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? designTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 8.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: designTheme.titleLarge.copyWith(
                color: valueColor ?? designTheme.textMain,
                fontSize: 28.0 * scaleFactor,
                fontStyle: FontStyle.normal, // Overriding default italic for stats
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.textDim,
              fontSize: 14.0 * scaleFactor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}