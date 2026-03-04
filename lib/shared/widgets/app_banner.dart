import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

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

  Color get _bg => switch (widget.variant) {
        BannerVariant.success => AppColors.success,
        BannerVariant.error   => AppColors.error,
        BannerVariant.warning => AppColors.warning,
        BannerVariant.info    => AppColors.info,
      };

  IconData get _icon => switch (widget.variant) {
        BannerVariant.success => Icons.check_circle_outline,
        BannerVariant.error   => Icons.error_outline,
        BannerVariant.warning => Icons.warning_amber_outlined,
        BannerVariant.info    => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _heightFactor,
        builder: (_, child) => Align(
          heightFactor: widget.animate ? _heightFactor.value : (widget.visible ? 1.0 : 0.0),
          child: child,
        ),
        child: Container(
          width: double.infinity,
          color: _bg,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_icon, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.message,
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.medium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Optional CTA
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: widget.onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      minimumSize: const Size(44, 44),
                      textStyle: AppTypography.buttonSmall
                          .copyWith(decoration: TextDecoration.underline),
                    ),
                    child: Text(widget.actionLabel!),
                  ),
                ],
                // Dismiss
                if (widget.onDismiss != null)
                  GestureDetector(
                    onTap: widget.onDismiss,
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Icon(Icons.close, color: Colors.white, size: 18),
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
