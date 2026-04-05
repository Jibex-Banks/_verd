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

class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designTheme = AppDesignSystem.of(context);
    final color = _getColor(articleId);

    final coursesAsync = ref.watch(coursesProvider);
    final progressAsync = ref.watch(userProgressProvider(articleId));
    final user = ref.watch(currentUserProvider);

    return coursesAsync.when(
      data: (courses) {
        final course = courses.where((c) => c.id == articleId).firstOrNull;

        if (course != null && course.lessons.isNotEmpty) {
          return _buildDynamicScreen(
            context: context,
            ref: ref,
            designTheme: designTheme,
            course: course,
            color: color,
            progress: progressAsync.value,
            isGuest: user == null || user.displayName == 'Guest',
          );
        }
        return _buildStaticScreen(context, designTheme);
      },
      loading: () => _buildLoadingScreen(designTheme),
      error: (_, __) => _buildStaticScreen(context, designTheme),
    );
  }

  Widget _buildLoadingScreen(AppDesignSystem designTheme) {
    return Scaffold(
      backgroundColor: designTheme.background,
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDynamicScreen({
    required BuildContext context,
    required WidgetRef ref,
    required AppDesignSystem designTheme,
    required Course course,
    required Color color,
    required UserProgress? progress,
    required bool isGuest,
  }) {
    return Scaffold(
      backgroundColor: designTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, _getFriendlyTitle(context, course), color, designTheme),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!isGuest && progress != null)
                  _buildProgressBar(context, designTheme, progress, course.lessons.length, color),
                const SizedBox(height: 48.0),
                ...course.lessons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final lesson = entry.value;
                  final isCompleted = progress?.isLessonCompleted(lesson.id) ?? false;

                  return _buildArticleLesson(
                    context: context,
                    ref: ref,
                    designTheme: designTheme,
                    lesson: lesson,
                    isCompleted: isCompleted,
                    isGuest: isGuest,
                    totalLessons: course.lessons.length,
                    showDivider: index < course.lessons.length - 1,
                    color: color,
                  );
                }),
                const SizedBox(height: 100.0),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String titleText, Color color, AppDesignSystem designTheme) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: color,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 12),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        expandedTitleScale: 1.1,
        titlePadding: const EdgeInsets.only(left: 48, bottom: 20, right: 32),
        title: Align(
          alignment: Alignment.bottomRight,
          child: SafeArea(
            bottom: false,
            child: Text(
              titleText,
              textAlign: TextAlign.right,
              style: designTheme.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                shadows: [
                  const Shadow(
                    color: Colors.black45,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.onboarding2, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    color.withOpacity(0.7),
                    color,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    AppDesignSystem designTheme,
    UserProgress progress,
    int totalLessons,
    Color color,
  ) {
    final fraction = progress.progressFraction(totalLessons);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.completedLessons.length} of $totalLessons sections completed',
              style: designTheme.bodySmall.copyWith(
                color: designTheme.textDim,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(fraction * 100).round()}%',
              style: designTheme.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildArticleLesson({
    required BuildContext context,
    required WidgetRef ref,
    required AppDesignSystem designTheme,
    required Lesson lesson,
    required bool isCompleted,
    required bool isGuest,
    required int totalLessons,
    required bool showDivider,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _lessonFriendlyName(lesson.id),
                style: designTheme.displayMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: isCompleted ? designTheme.textDim : designTheme.textMain,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (!isGuest)
              IconButton(
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? const Color(0xFF4CAF50) : designTheme.textDim.withOpacity(0.3),
                  size: 28,
                ),
                onPressed: () {
                  ref.read(userProgressProvider(articleId).notifier).toggleLesson(
                    lessonId: lesson.id,
                    totalLessons: totalLessons,
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 24.0),
        Text(
          lesson.content,
          style: designTheme.bodyRegular.copyWith(
            height: 1.8,
            fontSize: 17,
            color: designTheme.textMain.withOpacity(0.85),
            letterSpacing: 0.2,
          ),
        ),
        if (lesson.technicalDetails.isNotEmpty) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: designTheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20, color: color),
                    const SizedBox(width: 10),
                    Text(
                      'KEY NOTES',
                      style: designTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 2.0,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...lesson.technicalDetails.entries.map((e) {
                  // Clean up keys like '0', '1' if they are just indexes
                  final isIndexKey = RegExp(r'^\d+$').hasMatch(e.key);
                  final displayKey = isIndexKey ? '' : '${e.key}: ';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(Icons.arrow_right_rounded, color: color, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                if (displayKey.isNotEmpty)
                                  TextSpan(
                                    text: displayKey,
                                    style: designTheme.bodyRegular.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: designTheme.textMain,
                                      fontSize: 15,
                                    ),
                                  ),
                                TextSpan(
                                  text: e.value,
                                  style: designTheme.bodyRegular.copyWith(
                                    color: designTheme.textMain.withOpacity(0.9),
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        if (showDivider) ...[
          const SizedBox(height: 48),
          Divider(color: designTheme.textMain.withOpacity(0.08), thickness: 1),
          const SizedBox(height: 48),
        ],
      ],
    );
  }

  Widget _buildStaticScreen(BuildContext context, AppDesignSystem designTheme) {
    final title = _getTitle(context, articleId);
    final color = _getColor(articleId);

    return Scaffold(
      backgroundColor: designTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, title, color, designTheme),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 48.0),
                _buildStaticArticleChunk(
                  context,
                  title: AppLocalizations.of(context)!.article_look_q,
                  content: AppLocalizations.of(context)!.article_look_a,
                  designTheme: designTheme,
                ),
                const SizedBox(height: 48.0),
                _buildStaticArticleChunk(
                  context,
                  title: AppLocalizations.of(context)!.article_action_q,
                  content: AppLocalizations.of(context)!.article_action_a,
                  designTheme: designTheme,
                  isAlert: true,
                ),
                const SizedBox(height: 48.0),
                _buildStaticArticleChunk(
                  context,
                  title: AppLocalizations.of(context)!.article_treatment_q,
                  content: AppLocalizations.of(context)!.article_treatment_a,
                  designTheme: designTheme,
                ),
                const SizedBox(height: 64.0),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticArticleChunk(
    BuildContext context, {
    required AppDesignSystem designTheme,
    required String title,
    required String content,
    bool isAlert = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: designTheme.displayMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: isAlert ? designTheme.semanticError : designTheme.textMain,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          content,
          style: designTheme.bodyRegular.copyWith(
            height: 1.7,
            color: designTheme.textMain.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'started':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getFriendlyTitle(BuildContext context, Course course) {
    if (course.description.isNotEmpty && course.description.length < 30) {
      return course.description;
    }
    return articleId.replaceAll('-', ' ').split(' ').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  String _lessonFriendlyName(String lessonId) {
    return lessonId
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _getTitle(BuildContext ctx, String id) {
    switch (id) {
      case 'diseases': return AppLocalizations.of(ctx)!.guide_diseases;
      case 'pests': return AppLocalizations.of(ctx)!.guide_pests;
      case 'soil': return AppLocalizations.of(ctx)!.guide_soil;
      case 'water': return AppLocalizations.of(ctx)!.guide_water;
      case 'featured': return AppLocalizations.of(ctx)!.guide_featured;
      default: return id.replaceAll('-', ' ').split(' ').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    }
  }

  Color _getColor(String id) {
    switch (id) {
      case 'diseases': return const Color(0xFFE53935);
      case 'pests': return const Color(0xFFFF9800);
      case 'soil': return const Color(0xFF4CAF50);
      case 'water': return const Color(0xFF2196F3);
      case 'featured': return const Color(0xFF9C27B0);
      default: return const Color(0xFF4CAF50);
    }
  }
}
