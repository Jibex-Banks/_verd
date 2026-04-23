import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SUCCESS INDICATOR
// Animated checkmark — use in dialogs, overlays, or inline
// ═══════════════════════════════════════════════════════════════════════════

class SuccessIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final VoidCallback? onComplete;

  const SuccessIndicator({
    super.key,
    this.size = 80,
    this.color,
    this.onComplete,
  });

  @override
  State<SuccessIndicator> createState() => _SuccessIndicatorState();
}

class _SuccessIndicatorState extends State<SuccessIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _circleScale;
  late final Animation<double> _checkDraw;
  late final Animation<double> _bgFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _bgFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _circleScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
    _checkDraw = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );

    _ctrl.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final color = widget.color ?? designTheme.accentGreen;
    final s = widget.size;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => SizedBox(
        width: s,
        height: s,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            FadeTransition(
              opacity: _bgFade,
              child: Transform.scale(
                scale: _circleScale.value,
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Border circle
            Transform.scale(
              scale: _circleScale.value,
              child: Container(
                width: s * 0.82,
                height: s * 0.82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2.5),
                ),
              ),
            ),
            // Animated checkmark
            CustomPaint(
              size: Size(s * 0.42, s * 0.42),
              painter: _CheckPainter(
                progress: _checkDraw.value,
                color: color,
                strokeWidth: s * 0.055,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Checkmark points: left-bottom → mid-bottom → right-top
    final p1 = Offset(0, size.height * 0.55);
    final p2 = Offset(size.width * 0.38, size.height);
    final p3 = Offset(size.width, 0);

    final path = Path()..moveTo(p1.dx, p1.dy);

    // Total path length (approx)
    final seg1 = (p2 - p1).distance;
    final seg2 = (p3 - p2).distance;
    final total = seg1 + seg2;

    final drawn = progress * total;

    if (drawn <= seg1) {
      final t = drawn / seg1;
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = (drawn - seg1) / seg2;
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * t,
        p2.dy + (p3.dy - p2.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

// ─── Success Dialog ─────────────────────────────────────────────────────────

/// Full success dialog with animated checkmark.
class SuccessDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool autoDismiss;
  final Duration autoDismissDuration;

  const SuccessDialog({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.autoDismiss = false,
    this.autoDismissDuration = const Duration(seconds: 2),
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    bool autoDismiss = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        autoDismiss: autoDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    if (autoDismiss) {
      Future.delayed(autoDismissDuration, () {
        if (context.mounted) Navigator.of(context).pop();
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(designTheme.radiusStandard)),
      backgroundColor: designTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SuccessIndicator(size: 88),
            const SizedBox(height: 24.0),
            Text(title,
                style: designTheme.titleLarge.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8.0),
              Text(message!,
                  style: designTheme.bodyRegular
                      .copyWith(color: designTheme.textDim),
                  textAlign: TextAlign.center),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAction?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: designTheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text(
                    actionLabel!,
                    style: designTheme.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
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

// ─── Inline success badge ────────────────────────────────────────────────────

/// Small inline success pill — "Saved ✓"
class SuccessBadge extends StatelessWidget {
  final String label;
  const SuccessBadge({super.key, this.label = 'Saved'});

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: designTheme.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border:
            Border.all(color: designTheme.accentGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              color: designTheme.accentGreen, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: designTheme.bodyRegular.copyWith(
                color: designTheme.accentGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
              )),
        ],
      ),
    );
  }
}
