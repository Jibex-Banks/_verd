import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

enum AppButtonVariant { primary, secondary, ghost, outlined }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? icon; // mapped to leadingIcon for convenience
  final Color? customColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.icon,
    this.customColor,
  });

  /// Vertical padding scaled relative to screen height for responsiveness
  EdgeInsets _padding(BuildContext context) {
    final sh = MediaQuery.sizeOf(context).height;
    final vPad = switch (size) {
      AppButtonSize.small  => 8.0,
      AppButtonSize.medium => 12.0,
      AppButtonSize.large  => 16.0,
    };
    final hPad = switch (size) {
      AppButtonSize.small  => 16.0,
      AppButtonSize.medium => 20.0,
      AppButtonSize.large  => 24.0,
    };
    return EdgeInsets.symmetric(horizontal: hPad, vertical: vPad);
  }

  /// Text style capped at 1.3× so buttons don't overflow on large-text a11y
  TextStyle _textStyle(BuildContext context, AppDesignSystem theme) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final base = size == AppButtonSize.small
        ? theme.bodyRegular.copyWith(fontWeight: FontWeight.w500)
        : theme.bodyRegular.copyWith(fontWeight: FontWeight.w700, fontSize: 16, fontStyle: FontStyle.normal);
    
    return base.copyWith(fontSize: (base.fontSize ?? 16) * scale);
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final bool isActive = !isLoading && !isDisabled && onPressed != null;
    final Color baseColor = customColor ?? designTheme.primary;
    final cs = Theme.of(context).colorScheme;

    final loaderColor = variant == AppButtonVariant.primary
        ? designTheme.textMain
        : baseColor;

    Widget label = isLoading
        ? SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null || icon != null) ...[
          leadingIcon ?? icon!,
          const SizedBox(width: 8.0),
        ],
        Flexible(
          child: Text(
            text,
            style: _textStyle(context, designTheme),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8.0),
          trailingIcon!,
        ],
      ],
    );

    final ButtonStyle style = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: baseColor,
        foregroundColor: designTheme.textMain,
        disabledBackgroundColor: designTheme.surface,
        disabledForegroundColor: designTheme.textDim,
        padding: _padding(context),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(designTheme.radiusStandard),
        ),
      ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: designTheme.background,
        foregroundColor: designTheme.textMain,
        disabledBackgroundColor: designTheme.surface,
        disabledForegroundColor: designTheme.textDim,
        padding: _padding(context),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: isActive ? designTheme.textDim : designTheme.textDim.withOpacity(0.2),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(designTheme.radiusStandard),
        ),
      ),
      AppButtonVariant.ghost => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: baseColor,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor: designTheme.textDim,
        padding: _padding(context),
        elevation: 0,
        shadowColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(designTheme.radiusStandard),
        ),
      ),
      AppButtonVariant.outlined => ElevatedButton.styleFrom(
        backgroundColor: designTheme.surface,
        foregroundColor: designTheme.textMain,
        disabledBackgroundColor: designTheme.surface.withOpacity(0.5),
        disabledForegroundColor: designTheme.textDim,
        padding: _padding(context),
        elevation: 0,
        shadowColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: isActive ? designTheme.primary.withOpacity(0.5) : designTheme.textDim.withOpacity(0.2),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(designTheme.radiusStandard),
        ),
      ),
    };

    return ConstrainedBox(
      // Minimum 44px ensures iOS HIG / Material touch target & WCAG compliance
      constraints: BoxConstraints(minHeight: designTheme.touchTargetMin),
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: isActive ? onPressed : null,
          style: style,
          child: label,
        ),
      ),
    );
  }
}