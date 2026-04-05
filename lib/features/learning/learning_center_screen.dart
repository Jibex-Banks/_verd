import 'dart:math' as math;
import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/data/models/course.dart';
import 'package:verd/data/models/user_progress.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/providers/learning_provider.dart';
import 'package:verd/shared/widgets/bouncing_card.dart';

class LearningCenterScreen extends ConsumerWidget {
  const LearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designTheme = AppDesignSystem.of(context);
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: designTheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(coursesProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context, designTheme, ref),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  coursesAsync.when(
                    data: (courses) => _buildFeaturedArticle(
                      context, 
                      designTheme, 
                      courses.isNotEmpty ? courses.first : null
                    ),
                    loading: () => _buildFeaturedPlaceholder(designTheme),
                    error: (_, __) => _buildFeaturedArticle(context, designTheme, null),
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    AppLocalizations.of(context)!.explore_categories,
                    style: designTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: designTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  coursesAsync.when(
                    data: (courses) => courses.isEmpty
                        ? _buildEmptyState(context, designTheme)
                        : _buildLearningPathList(context, designTheme, ref, courses),
                    loading: () => _buildLoadingList(),
                    error: (err, stack) => _buildErrorState(context, designTheme, err),
                  ),
                  const SizedBox(height: 64.0),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppDesignSystem designTheme, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: designTheme.background,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: designTheme.textMain),
        onPressed: () => context.pop(),
      ),
      title: Text(
        AppLocalizations.of(context)!.article_library,
        style: designTheme.titleLarge.copyWith(
          color: designTheme.textMain,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: designTheme.textMain),
          onPressed: () => _showSearchSheet(context, designTheme),
        ),
      ],
    );
  }

  void _showSearchSheet(BuildContext context, AppDesignSystem designTheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: designTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 32.0,
            right: 32.0,
            top: 32.0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: designTheme.textDim.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                AppLocalizations.of(context)!.search_articles,
                style: designTheme.displayMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: designTheme.textMain,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search_hint,
                  prefixIcon: Icon(Icons.search, color: designTheme.textDim),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: designTheme.surface,
                  hintStyle: designTheme.bodyRegular.copyWith(color: designTheme.textDim),
                ),
                style: designTheme.bodyRegular.copyWith(color: designTheme.textMain),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedArticle(BuildContext context, AppDesignSystem designTheme, Course? course) {
    final title = course != null ? _courseFriendlyName(course.id, context) : 'How to Identify Fall Armyworm';
    final courseId = course?.id ?? 'featured';
    
    return BouncingCard(
      onTap: () => context.push('/article/$courseId'),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: course != null && course.image.startsWith('http')
                ? NetworkImage(course.image) as ImageProvider
                : const AssetImage(AppAssets.onboarding1),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: designTheme.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: designTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'FEATURED GUIDE',
                  style: designTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: designTheme.displayMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedPlaceholder(AppDesignSystem designTheme) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: designTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLearningPathList(
    BuildContext context,
    AppDesignSystem designTheme,
    WidgetRef ref,
    List<Course> courses,
  ) {
    final user = ref.watch(currentUserProvider);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final course = courses[index];
        final color = _courseColor(index);

        final progressAsync = user != null
            ? ref.watch(userProgressProvider(course.id))
            : const AsyncValue<UserProgress?>.data(null);

        final progress = progressAsync.value;
        final fraction = progress != null && course.lessons.isNotEmpty
            ? progress.progressFraction(course.lessons.length)
            : 0.0;

        return _buildLearningPathRow(
          context: context,
          designTheme: designTheme,
          course: course,
          color: color,
          progressFraction: fraction,
        );
      },
    );
  }

  Widget _buildLearningPathRow({
    required BuildContext context,
    required AppDesignSystem designTheme,
    required Course course,
    required Color color,
    required double progressFraction,
  }) {
    return BouncingCard(
      onTap: () => context.push('/article/${course.id}'),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: designTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: designTheme.textMain.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _courseIcon(course.id),
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _courseFriendlyName(course.id, context),
                    style: designTheme.bodyRegular.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: designTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _courseCategory(course.id, context),
                    style: designTheme.bodySmall.copyWith(
                      color: designTheme.textDim,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: progressFraction > 0 ? progressFraction : 0.05,
                    backgroundColor: designTheme.textDim.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressFraction >= 1.0 ? const Color(0xFF4CAF50) : color,
                    ),
                    strokeWidth: 4,
                  ),
                ),
                if (progressFraction >= 1.0)
                  const Icon(Icons.check, color: Color(0xFF4CAF50), size: 18)
                else
                  Text(
                    '${(progressFraction * 100).round()}%',
                    style: designTheme.bodySmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: designTheme.textMain,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppDesignSystem designTheme) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: designTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_stories_outlined, size: 48, color: designTheme.textDim),
          const SizedBox(height: 16),
          Text(
            'No learning modules found.',
            style: designTheme.bodyRegular.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your internet connection or sync settings.',
            textAlign: TextAlign.center,
            style: designTheme.bodySmall.copyWith(color: designTheme.textDim),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppDesignSystem designTheme, Object error) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: designTheme.semanticError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: designTheme.semanticError.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: designTheme.semanticError, size: 32),
          const SizedBox(height: 12),
          Text(
            'Sync Error',
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.semanticError,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: designTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Color _courseColor(int index) {
    const colors = [
      Color(0xFFE53935), // Red
      Color(0xFF4CAF50), // Green
      Color(0xFF2196F3), // Blue
      Color(0xFFFF9800), // Orange
      Color(0xFF9C27B0), // Purple
      Color(0xFF673AB7), // Deep Purple
      Color(0xFFE91E63), // Pink
      Color(0xFF00BCD4), // Cyan
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

  String _courseFriendlyName(String courseId, BuildContext context) {
    return courseId
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll('expanded', '')
        .trim()
        .split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _courseCategory(String courseId, BuildContext context) {
    final id = courseId.toLowerCase();
    if (id.contains('pathology') || id.contains('disease')) return 'Plant Protection';
    if (id.contains('pest') || id.contains('ecology') || id.contains('ipm')) return 'Pest Control';
    if (id.contains('soil') || id.contains('fertility')) return 'Sustenance';
    if (id.contains('water') || id.contains('irrigat')) return 'Resource Mgmt';
    if (id.contains('ai') || id.contains('precision')) return 'Advanced Tech';
    return 'Core Agronomy';
  }
}
