import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/providers/ai_provider.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class UserInsightsScreen extends ConsumerStatefulWidget {
  const UserInsightsScreen({super.key});

  @override
  ConsumerState<UserInsightsScreen> createState() => _UserInsightsScreenState();
}

class _UserInsightsScreenState extends ConsumerState<UserInsightsScreen> {
  Map<String, dynamic>? _insights;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final insights = await ref.read(aiServiceProvider).getUserFarmingInsights(user.uid);
        if (mounted) {
          setState(() {
            _insights = insights;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Failed to load insights: $e',
          variant: ToastVariant.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: designTheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.farming_insights,
          style: designTheme.titleLarge.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w800
          ),
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadInsights,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: designTheme.primary))
          : _insights == null
              ? _buildEmptyState()
              : _buildInsightsContent(),
    );
  }

  Widget _buildEmptyState() {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: designTheme.textDim.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.no_insights_yet,
            style: designTheme.titleLarge.copyWith(
              color: designTheme.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.start_scanning_desc,
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.textDim,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pushNamed('scan_result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: designTheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              AppLocalizations.of(context)!.start_scanning,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsContent() {
    final designTheme = AppDesignSystem.of(context);
    final insights = _insights!;
    final scanCount = insights['scanCount'] as int? ?? 0;
    final cropTypes = insights['cropTypes'] as List<String>? ?? [];
    final lastUpdated = insights['lastUpdated'] as String? ?? '';
    final error = insights['error'] as String?;

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: designTheme.semanticError,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.insights_error,
                style: designTheme.titleLarge.copyWith(
                  color: designTheme.textMain,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: designTheme.bodyRegular.copyWith(
                  color: designTheme.textDim,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats
          _buildStatsCard(scanCount, cropTypes.length, lastUpdated),
          const SizedBox(height: 24.0),

          // AI Insights
          if (insights['insights'] != null)
            _buildInsightsCard(insights['insights']),
          const SizedBox(height: 24.0),

          // Crop Diversity
          if (cropTypes.isNotEmpty)
            _buildCropDiversityCard(cropTypes),
          const SizedBox(height: 24.0),

          // Recommendations
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int scanCount, int cropCount, String lastUpdated) {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: designTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: designTheme.textDim.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.farming_overview,
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)!.total_scans,
                  scanCount.toString(),
                  Icons.camera_alt,
                  designTheme.primary,
                  designTheme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)!.crop_types,
                  cropCount.toString(),
                  Icons.eco,
                  designTheme.accentGreen,
                  designTheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Last updated: ${_formatDate(lastUpdated)}',
            style: designTheme.bodyRegular.copyWith(
              fontSize: 12,
              color: designTheme.textDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, AppDesignSystem designTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: designTheme.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          Text(
            label,
            style: designTheme.bodyRegular.copyWith(
              fontSize: 12,
              color: designTheme.textDim,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(dynamic insights) {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: designTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: designTheme.textDim.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: designTheme.semanticWarning, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.ai_insights_title,
                style: designTheme.bodyRegular.copyWith(
                  fontWeight: FontWeight.w800,
                  color: designTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: designTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: designTheme.primary.withOpacity(0.1)),
            ),
            child: Text(
              insights.toString(),
              style: designTheme.bodyRegular.copyWith(
                color: designTheme.textMain,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropDiversityCard(List<String> cropTypes) {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: designTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: designTheme.textDim.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: designTheme.accentGreen, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.crop_diversity,
                style: designTheme.bodyRegular.copyWith(
                  fontWeight: FontWeight.w800,
                  color: designTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cropTypes.map((crop) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: designTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: designTheme.accentGreen.withValues(alpha: 0.2)),
                ),
                child: Text(
                  crop,
                  style: designTheme.bodyRegular.copyWith(
                    fontSize: 12,
                    color: designTheme.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: designTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: designTheme.textDim.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: designTheme.secondary, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.recommendations,
                style: designTheme.bodyRegular.copyWith(
                  fontWeight: FontWeight.w800,
                  color: designTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            AppLocalizations.of(context)!.rec_scan_regularly,
            AppLocalizations.of(context)!.rec_diversify,
            AppLocalizations.of(context)!.rec_document,
          ].map((recommendation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: designTheme.accentGreen, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: designTheme.bodyRegular.copyWith(
                        color: designTheme.textMain,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return AppLocalizations.of(context)!.unknown;
    }
  }
}
