import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:verd/core/theme/app_design_system.dart';

// ─── Base shimmer wrapper ───────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: isDark
          ? designTheme.surface.withOpacity(0.1)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      highlightColor: isDark
          ? designTheme.surface.withOpacity(0.2)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

// ─── Primitive shimmer shapes ──────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;

  const ShimmerLine({
    super.key,
    this.width,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Scan history list item skeleton
class ScanListItemSkeleton extends StatelessWidget {
  const ScanListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 56, height: 56, borderRadius: 12.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(width: double.infinity, height: 14),
                  const SizedBox(height: 4.0),
                  ShimmerLine(
                    width: MediaQuery.sizeOf(context).width * 0.4,
                    height: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            const ShimmerBox(width: 60, height: 24, borderRadius: 100),
          ],
        ),
      ),
    );
  }
}

/// Full scan history list skeleton (repeating rows)
class ScanListSkeleton extends StatelessWidget {
  final int itemCount;
  const ScanListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: List.generate(itemCount, (i) => Column(
        children: [
          const ScanListItemSkeleton(),
          if (i < itemCount - 1)
            Divider(
              height: 1,
              indent: 16.0,
              endIndent: 16.0,
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            ),
        ],
      )),
    );
  }
}

/// Dashboard / home screen header + stat cards skeleton
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final sw = MediaQuery.sizeOf(context).width;
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              const ShimmerCircle(size: 44),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLine(width: sw * 0.3, height: 12),
                    const SizedBox(height: 6),
                    ShimmerLine(width: sw * 0.5, height: 16),
                  ],
                ),
              ),
              const ShimmerBox(width: 40, height: 40, borderRadius: 100),
            ]),
            const SizedBox(height: 32.0),
            // Stat cards row
            Row(children: [
              const Expanded(child: ShimmerBox(width: double.infinity, height: 88)),
              const SizedBox(width: 16.0),
              const Expanded(child: ShimmerBox(width: double.infinity, height: 88)),
            ]),
            const SizedBox(height: 16.0),
            Row(children: [
              const Expanded(child: ShimmerBox(width: double.infinity, height: 88)),
              const SizedBox(width: 16.0),
              const Expanded(child: ShimmerBox(width: double.infinity, height: 88)),
            ]),
            const SizedBox(height: 32.0),
            // Section title
            ShimmerLine(width: sw * 0.35, height: 16),
            const SizedBox(height: 16.0),
            // Recent scan cards
            ...List.generate(3, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: ShimmerBox(
                width: double.infinity,
                height: 72,
                borderRadius: 16.0,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Profile screen skeleton
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final sw = MediaQuery.sizeOf(context).width;
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar + name
            const ShimmerCircle(size: 80),
            const SizedBox(height: 16.0),
            ShimmerLine(width: sw * 0.4, height: 18),
            const SizedBox(height: 8.0),
            ShimmerLine(width: sw * 0.55, height: 13),
            const SizedBox(height: 32.0),
            // Settings rows
            ...List.generate(6, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(children: [
                const ShimmerBox(width: 40, height: 40),
                const SizedBox(width: 16.0),
                const Expanded(child: ShimmerLine(height: 14)),
                const SizedBox(width: 16.0),
                const ShimmerBox(width: 20, height: 20),
              ]),
            )),
          ],
        ),
      ),
    );
  }
}

/// Single card detail skeleton (scan result page)
class ScanDetailSkeleton extends StatelessWidget {
  const ScanDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final sw = MediaQuery.sizeOf(context).width;
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ShimmerBox(
              width: double.infinity,
              height: sw * 0.6,
              borderRadius: 24.0,
            ),
            const SizedBox(height: 24.0),
            // Title + badge
            Row(children: [
              const Expanded(child: ShimmerLine(height: 20)),
              const SizedBox(width: 16.0),
              const ShimmerBox(width: 72, height: 28, borderRadius: 100),
            ]),
            const SizedBox(height: 16.0),
            // Body lines
            const ShimmerLine(height: 13),
            const SizedBox(height: 4.0),
            const ShimmerLine(height: 13),
            const SizedBox(height: 4.0),
            ShimmerLine(width: sw * 0.7, height: 13),
            const SizedBox(height: 32.0),
            // Recommendations
            ShimmerLine(width: sw * 0.4, height: 16),
            const SizedBox(height: 16.0),
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerCircle(size: 20),
                  const SizedBox(width: 16.0),
                  const Expanded(child: ShimmerLine(height: 13)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
