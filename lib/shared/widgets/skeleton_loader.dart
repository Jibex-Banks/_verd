import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:verd/core/constants/app_theme.dart';

// ─── Base shimmer wrapper ───────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray50,
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
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
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
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
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
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 56, height: 56, borderRadius: AppRadius.md),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(width: double.infinity, height: 14),
                  const SizedBox(height: AppSpacing.xs),
                  ShimmerLine(
                    width: MediaQuery.sizeOf(context).width * 0.4,
                    height: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const ShimmerBox(width: 60, height: 24, borderRadius: AppRadius.full),
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
    return Column(
      children: List.generate(itemCount, (i) => Column(
        children: [
          ScanListItemSkeleton(),
          if (i < itemCount - 1)
            const Divider(
              height: 1,
              indent: AppSpacing.lg,
              endIndent: AppSpacing.lg,
              color: AppColors.gray100,
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
    final sw = MediaQuery.sizeOf(context).width;
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              const ShimmerCircle(size: 44),
              const SizedBox(width: AppSpacing.md),
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
              const ShimmerBox(width: 40, height: 40, borderRadius: AppRadius.full),
            ]),
            const SizedBox(height: AppSpacing.xxl),
            // Stat cards row
            Row(children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 88)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: ShimmerBox(width: double.infinity, height: 88)),
            ]),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 88)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: ShimmerBox(width: double.infinity, height: 88)),
            ]),
            const SizedBox(height: AppSpacing.xxl),
            // Section title
            ShimmerLine(width: sw * 0.35, height: 16),
            const SizedBox(height: AppSpacing.lg),
            // Recent scan cards
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ShimmerBox(
                width: double.infinity,
                height: 72,
                borderRadius: AppRadius.card,
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
    final sw = MediaQuery.sizeOf(context).width;
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Avatar + name
            const ShimmerCircle(size: 80),
            const SizedBox(height: AppSpacing.md),
            ShimmerLine(width: sw * 0.4, height: 18),
            const SizedBox(height: AppSpacing.sm),
            ShimmerLine(width: sw * 0.55, height: 13),
            const SizedBox(height: AppSpacing.xxl),
            // Settings rows
            ...List.generate(6, (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Row(children: [
                const ShimmerBox(width: 40, height: 40),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: ShimmerLine(height: 14)),
                const SizedBox(width: AppSpacing.md),
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
    final sw = MediaQuery.sizeOf(context).width;
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ShimmerBox(
              width: double.infinity,
              height: sw * 0.6,
              borderRadius: AppRadius.xl,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Title + badge
            Row(children: [
              Expanded(child: ShimmerLine(height: 20)),
              const SizedBox(width: AppSpacing.md),
              const ShimmerBox(width: 72, height: 28, borderRadius: AppRadius.full),
            ]),
            const SizedBox(height: AppSpacing.lg),
            // Body lines
            const ShimmerLine(height: 13),
            const SizedBox(height: AppSpacing.xs),
            const ShimmerLine(height: 13),
            const SizedBox(height: AppSpacing.xs),
            ShimmerLine(width: sw * 0.7, height: 13),
            const SizedBox(height: AppSpacing.xxl),
            // Recommendations
            ShimmerLine(width: sw * 0.4, height: 16),
            const SizedBox(height: AppSpacing.lg),
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerCircle(size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: ShimmerLine(height: 13)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
