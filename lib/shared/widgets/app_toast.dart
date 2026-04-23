import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

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

  Color _bg(BuildContext context, AppDesignSystem theme) => switch (widget.variant) {
        ToastVariant.success => theme.accentGreen,
        ToastVariant.error   => Theme.of(context).colorScheme.error,
        ToastVariant.warning => theme.semanticWarning,
        ToastVariant.info    => theme.surface,
      };

  IconData get _icon => switch (widget.variant) {
        ToastVariant.success => Icons.check_circle_outline,
        ToastVariant.error   => Icons.error_outline,
        ToastVariant.warning => Icons.warning_amber_outlined,
        ToastVariant.info    => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final sw = MediaQuery.sizeOf(context).width;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 32.0;

    return Positioned(
      bottom: bottomPad,
      left: 16.0,
      right: 16.0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sw - 32.0),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: widget.onTap ?? widget.onDismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: _bg(context, designTheme),
                      borderRadius: BorderRadius.circular(designTheme.radiusStandard),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
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
                        const SizedBox(width: 8.0),
                        GestureDetector(
                          onTap: widget.onDismiss,
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: designTheme.touchTargetMin,
                            height: designTheme.touchTargetMin,
                            child: Center(
                              child: Icon(Icons.close,
                                  color: designTheme.textDim, size: 16),
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
