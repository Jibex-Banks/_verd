import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

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

  Color _bg(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final errorColor = Theme.of(context).colorScheme.error;
    return switch (variant) {
      StatusBarVariant.success => designTheme.accentGreen.withOpacity(0.10),
      StatusBarVariant.error   => errorColor.withOpacity(0.10),
      StatusBarVariant.warning => designTheme.semanticWarning.withOpacity(0.10),
      StatusBarVariant.info    => designTheme.primary.withOpacity(0.10),
    };
  }

  Color _fg(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final errorColor = Theme.of(context).colorScheme.error;
    return switch (variant) {
      StatusBarVariant.success => designTheme.accentGreen,
      StatusBarVariant.error   => errorColor,
      StatusBarVariant.warning => designTheme.semanticWarning,
      StatusBarVariant.info    => designTheme.primary,
    };
  }

  Color _border(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final errorColor = Theme.of(context).colorScheme.error;
    return switch (variant) {
      StatusBarVariant.success => designTheme.accentGreen,
      StatusBarVariant.error   => errorColor,
      StatusBarVariant.warning => designTheme.semanticWarning,
      StatusBarVariant.info    => designTheme.primary,
    };
  }

  IconData get _icon => switch (variant) {
    StatusBarVariant.success => Icons.check_circle_outline,
    StatusBarVariant.error   => Icons.error_outline,
    StatusBarVariant.warning => Icons.warning_amber_outlined,
    StatusBarVariant.info    => Icons.info_outline,
  };

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final bg = _bg(context);
    final fg = _fg(context);
    final borderColor = _border(context);

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null)
              leading!
            else if (showIcon)
              Icon(_icon, size: 18, color: fg),

            const SizedBox(width: 8.0),

            Expanded(
              child: Text(
                message,
                style: designTheme.bodyRegular.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0 * scaleFactor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (action != null) ...[
              const SizedBox(width: 4.0),
              action!,
            ],

            if (onDismiss != null) ...[
              const SizedBox(width: 4.0),
              GestureDetector(
                onTap: onDismiss,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: designTheme.touchTargetMin,
                  height: designTheme.touchTargetMin,
                  child: Center(
                    child: Icon(Icons.close, size: 16, color: fg),
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