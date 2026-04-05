import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

/// Animated page-indicator dots.
/// The active dot expands to [activeDotWidth]; others stay [dotSize] circles.
class ProgressDots extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double activeDotWidth;
  final double spacing;

  const ProgressDots({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.activeDotWidth = 24,
    this.spacing = 6,
  }) : assert(count > 0, 'count must be at least 1'),
        assert(currentIndex >= 0 && currentIndex < count,
        'currentIndex must be within [0, count)');

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    // Scale dot size on very small screens
    final sw = MediaQuery.sizeOf(context).width;
    final scale = sw < 320 ? 0.8 : 1.0;
    final effectiveDotSize = dotSize * scale;
    final effectiveActiveWidth = activeDotWidth * scale;

    return Semantics(
      label: 'Page ${currentIndex + 1} of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: (spacing / 2) * scale),
            width: isActive ? effectiveActiveWidth : effectiveDotSize,
            height: effectiveDotSize,
            decoration: BoxDecoration(
              color: isActive
                  ? (activeColor ?? designTheme.primary)
                  : (inactiveColor ?? designTheme.textDim.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(effectiveDotSize / 2),
            ),
          );
        }),
      ),
    );
  }
}