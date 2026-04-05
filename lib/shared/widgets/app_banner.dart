import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

enum BannerVariant { success, error, warning, info }

/// Persistent top-of-screen banner.
/// Place [AppBanner] at the top of your Scaffold body, or use
/// [AppBannerController] via a provider to show/hide globally.
class AppBanner extends StatefulWidget {
  final String message;
  final BannerVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final bool visible;
  final bool animate;

  const AppBanner({
    super.key,
    required this.message,
    this.variant = BannerVariant.info,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.visible = true,
    this.animate = true,
  });

  @override
  State<AppBanner> createState() => _AppBannerState();
}

class _AppBannerState extends State<AppBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.visible ? 1.0 : 0.0,
    );
    _heightFactor =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(AppBanner old) {
    super.didUpdateWidget(old);
    if (widget.visible != old.visible) {
      widget.visible ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _bg(BuildContext context, AppDesignSystem theme) => switch (widget.variant) {
        BannerVariant.success => theme.accentGreen,
        BannerVariant.error   => Theme.of(context).colorScheme.error,
        BannerVariant.warning => Colors.orange,
        BannerVariant.info    => theme.primary,
      };

  IconData get _icon => switch (widget.variant) {
        BannerVariant.success => Icons.check_circle_outline,
        BannerVariant.error   => Icons.error_outline,
        BannerVariant.warning => Icons.warning_amber_outlined,
        BannerVariant.info    => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    
    return ClipRect(
      child: AnimatedBuilder(
        animation: _heightFactor,
        builder: (_, child) => Align(
          heightFactor: widget.animate ? _heightFactor.value : (widget.visible ? 1.0 : 0.0),
          child: child,
        ),
        child: Container(
          width: double.infinity,
          color: _bg(context, designTheme),
          padding: const EdgeInsets.fromLTRB(
            16.0,
            12.0,
            8.0,
            12.0,
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_icon, color: designTheme.textMain, size: 20),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    widget.message,
                    style: designTheme.bodyRegular.copyWith(
                      color: designTheme.textMain,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Optional CTA
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: widget.onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: designTheme.textMain,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      minimumSize: Size(designTheme.touchTargetMin, designTheme.touchTargetMin),
                      textStyle: designTheme.bodyRegular.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(widget.actionLabel!),
                  ),
                ],
                // Dismiss
                if (widget.onDismiss != null)
                  GestureDetector(
                    onTap: widget.onDismiss,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: designTheme.touchTargetMin,
                      height: designTheme.touchTargetMin,
                      child: Center(
                        child: Icon(Icons.close, color: designTheme.textMain, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
