import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/providers/learning_provider.dart';

import 'package:verd/shared/widgets/skeleton_loader.dart';
import 'package:verd/shared/widgets/bouncing_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onProfileTap;
  
  const HomeScreen({
    super.key,
    this.onScanTap,
    this.onProfileTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading to show skeleton
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const DashboardSkeleton(),
      );
    }
    final designTheme = AppDesignSystem.of(context);
    return Scaffold(
      backgroundColor: designTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.welcome_to_verd,
                          style: designTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            color: designTheme.textMain,
                            fontSize: 32.0,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.smart_companion,
                          style: designTheme.bodyRegular.copyWith(
                            color: designTheme.textDim,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: designTheme.glassDecoration(
                        opacity: 0.1,
                      ).copyWith(
                        color: designTheme.primary.withOpacity(0.1),
                        border: Border.all(
                          color: designTheme.primary.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: designTheme.primary,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              // ── Quick Actions ──
              Text(
                AppLocalizations.of(context)!.quick_actions,
                style: designTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: designTheme.textMain,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 12.0),
              _buildQuickActionCard(
                iconBackgroundColor: designTheme.accentGreen,
                icon: Icons.camera_alt_rounded,
                title: AppLocalizations.of(context)!.scan_crop,
                subtitle: AppLocalizations.of(context)!.scan_crop_desc_short,
                onTap: widget.onScanTap,
              ),
              _buildQuickActionCard(
                iconBackgroundColor: designTheme.secondary,
                icon: Icons.menu_book_rounded,
                title: AppLocalizations.of(context)!.learning_center_title,
                subtitle: AppLocalizations.of(context)!.learning_center_desc_short,
                onTap: () => context.push('/learning-center'),
              ),
              _buildQuickActionCard(
                iconBackgroundColor: designTheme.semanticWarning,
                icon: Icons.history_rounded,
                title: AppLocalizations.of(context)!.view_history,
                subtitle: AppLocalizations.of(context)!.view_history_desc_short,
                onTap: () => context.push('/scan-history'),
              ),
              _buildQuickActionCard(
                iconBackgroundColor: designTheme.primary,
                icon: Icons.photo_library_rounded,
                title: AppLocalizations.of(context)!.gallery,
                subtitle: AppLocalizations.of(context)!.gallery_desc_short,
                onTap: () => context.push('/gallery'),
              ),
              const SizedBox(height: 32.0),
              // ── Tip of the Day ──
              _buildTipOfTheDay(context, designTheme),
              const SizedBox(height: 32.0),

              // ── Popular Topics ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.popular_topics,
                    style: designTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: designTheme.textMain,
                      fontSize: 20.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/learning-center'),
                    child: Text(
                      'View All',
                      style: designTheme.bodySmall.copyWith(
                        color: designTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              ref.watch(coursesProvider).when(
                    data: (courses) {
                      final displayCourses = courses.take(4).toList();
                      if (displayCourses.isEmpty) {
                        return _buildEmptyTopics(context, designTheme);
                      }
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 0.95,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayCourses.length,
                        itemBuilder: (context, index) {
                          final course = displayCourses[index];
                          return _buildTopicCard(
                            iconBackgroundColor: _courseColor(index),
                            icon: _courseIcon(course.id),
                            title: _courseFriendlyName(course.id),
                            subtitle: _courseCategory(course.id),
                            onTap: () => context.push('/article/${course.id}'),
                          );
                        },
                      );
                    },
                    loading: () => _buildLoadingTopics(),
                    error: (err, _) => _buildErrorTopics(designTheme, err),
                  ),
              const SizedBox(height: 32.0), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTopics(BuildContext context, AppDesignSystem designTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: designTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: designTheme.textMain.withOpacity(0.05)),
      ),
      child: Center(
        child: Text(
          'Start your learning journey today!',
          style: designTheme.bodySmall.copyWith(color: designTheme.textDim),
        ),
      ),
    );
  }

  Widget _buildLoadingTopics() {
    final designTheme = AppDesignSystem.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            color: designTheme.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorTopics(AppDesignSystem designTheme, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: designTheme.semanticError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Failed to load topics',
        style: designTheme.bodySmall.copyWith(color: designTheme.semanticError),
      ),
    );
  }

  Color _courseColor(int index) {
    final designTheme = AppDesignSystem.of(context);
    final colors = [
      designTheme.semanticError,
      designTheme.accentGreen,
      designTheme.secondary,
      designTheme.semanticWarning,
    ];
    return colors[index % colors.length];
  }

  IconData _courseIcon(String courseId) {
    final id = courseId.toLowerCase();
    if (id.contains('pathology') || id.contains('disease')) return Icons.coronavirus;
    if (id.contains('pest') || id.contains('ecology') || id.contains('ipm')) return Icons.bug_report;
    if (id.contains('soil') || id.contains('fertility')) return Icons.grass;
    if (id.contains('water') || id.contains('irrigat')) return Icons.water_drop;
    if (id.contains('ai') || id.contains('precision')) return Icons.auto_awesome;
    if (id.contains('agronomy') || id.contains('farming')) return Icons.agriculture;
    if (id.contains('harvest') || id.contains('biology')) return Icons.eco;
    return Icons.menu_book;
  }

  String _courseFriendlyName(String courseId) {
    return courseId
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll('expanded', '')
        .trim()
        .split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _courseCategory(String courseId) {
    final id = courseId.toLowerCase();
    if (id.contains('pathology') || id.contains('disease')) return 'Plant Protection';
    if (id.contains('pest') || id.contains('ecology') || id.contains('ipm')) return 'Pest Control';
    if (id.contains('soil') || id.contains('fertility')) return 'Sustenance';
    if (id.contains('water') || id.contains('irrigat')) return 'Resource Mgmt';
    if (id.contains('ai') || id.contains('precision')) return 'Advanced Tech';
    return 'Core Agronomy';
  }

  Widget _buildTipOfTheDay(BuildContext context, AppDesignSystem designTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    final tip = ref.watch(tipOfTheDayProvider);
    final tipText = tip?.text ?? AppLocalizations.of(context)!.early_detection_desc;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: designTheme.primary,
        borderRadius: BorderRadius.circular(designTheme.radiusStandard),
        boxShadow: [
          BoxShadow(
            color: designTheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              AppLocalizations.of(context)!.tip_of_the_day.toUpperCase(),
              style: designTheme.bodyRegular.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            AppLocalizations.of(context)!.early_detection_title,
            style: designTheme.titleLarge.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            tipText,
            style: designTheme.bodyRegular.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
              height: 1.5,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required Color iconBackgroundColor,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return BouncingCard(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: designTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: designTheme.textMain.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconBackgroundColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: designTheme.bodyRegular.copyWith(
                          fontWeight: FontWeight.w800,
                          color: designTheme.textMain,
                          fontSize: 17.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.textDim,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: designTheme.textMain.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: designTheme.textDim,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildTopicCard({
    required Color iconBackgroundColor,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return BouncingCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: designTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: designTheme.textMain.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconBackgroundColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  title,
                  style: designTheme.bodyRegular.copyWith(
                    fontWeight: FontWeight.w800,
                    color: designTheme.textMain,
                    fontSize: 15.0,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: designTheme.bodyRegular.copyWith(
                    color: designTheme.textDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ),
    );
  }
}