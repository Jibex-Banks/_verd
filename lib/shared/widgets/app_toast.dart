import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

enum ToastVariant { success, error, warning, info }

/// Global overlay toast — auto-dismisses after [duration].
/// Call [AppToast.show] from anywhere with a BuildContext.
class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    ToastVariant variant = ToastVariant.success,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    // Dismiss any existing toast first
    _dismiss();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        variant: variant,
        onDismiss: _dismiss,
        onTap: onTap,
      ),
    );

    _current = entry;
    overlay.insert(entry);

    Future.delayed(duration, _dismiss);
  }

  static void _dismiss() {
    _current?.remove();
    _current = null;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastVariant variant;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const _ToastWidget({
    required this.message,
    required this.variant,
    required this.onDismiss,
    this.onTap,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bg => switch (widget.variant) {
        ToastVariant.success => AppColors.success,
        ToastVariant.error   => AppColors.error,
        ToastVariant.warning => AppColors.warning,
        ToastVariant.info    => AppColors.gray900,
      };

  IconData get _icon => switch (widget.variant) {
        ToastVariant.success => Icons.check_circle_outline,
        ToastVariant.error   => Icons.error_outline,
        ToastVariant.warning => Icons.warning_amber_outlined,
        ToastVariant.info    => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final bottomPad = MediaQuery.paddingOf(context).bottom + AppSpacing.xxl;

    return Positioned(
      bottom: bottomPad,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sw - AppSpacing.xxl),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: widget.onTap ?? widget.onDismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [AppShadows.lg],
                    ),
                    child: Row(
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
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: widget.onDismiss,
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: Icon(Icons.close,
                                  color: Colors.white70, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
