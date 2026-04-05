import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/l10n/app_localizations.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/data/models/scan_result.dart'; // Needed if we still reference ScanResult

class ScanResultScreen extends StatelessWidget {
  final Map<String, dynamic> scanResult;
  final String? imageUrl;

  const ScanResultScreen({super.key, required this.scanResult, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final analysis = scanResult['analysis'] as Map<String, dynamic>? ?? {};
    final engine = scanResult['engine'] as String? ?? 'unknown';
    final timestamp = scanResult['timestamp'] as String? ?? '';

    final cropType = analysis['cropType'] as String? ?? 'Unknown Crop';
    final healthStatus = analysis['healthStatus'] as String? ?? 'Unknown';
    final confidence = (analysis['confidence'] as num?)?.toDouble() ?? 0.0;
    final diseases = analysis['diseases'] as List<dynamic>? ?? [];
    final personalizedRecommendations =
        scanResult['personalizedRecommendations'] as List<dynamic>? ?? [];
    final learningResources =
        scanResult['learningResources'] as List<dynamic>? ?? [];
    final contextualInsights = analysis['contextualInsights'] as String?;

    return Scaffold(
      backgroundColor: designTheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.scan_results,
          style: designTheme.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: designTheme.background,
        foregroundColor: designTheme.textMain,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              AppToast.show(
                context,
                message: AppLocalizations.of(context)!.share_coming_soon,
                variant: ToastVariant.info,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            if (imageUrl != null)
              Container(
                width: double.infinity,
                height: 220,
                margin: const EdgeInsets.only(bottom: 24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(designTheme.radiusStandard),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(designTheme.radiusStandard),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      );
                    },
                  ),
                ),
              ),

            // 1. Cloud Fallback Warning
            if (scanResult['cloudFallback'] == true)
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.all(16.0),
                decoration: designTheme.glassDecoration(
                  opacity: 0.1,
                ).copyWith(
                  color: designTheme.semanticWarning.withOpacity(0.1),
                  border: Border.all(color: designTheme.semanticWarning.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, color: designTheme.semanticWarning),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        'Cloud analysis currently unavailable. Showing fast on-device results instead.',
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.semanticWarning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Engine and timestamp info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: designTheme.surface,
                borderRadius: BorderRadius.circular(designTheme.radiusStandard),
                border: Border.all(color: designTheme.textMain.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        engine.contains('gemini')
                            ? Icons.auto_awesome
                            : Icons.memory_rounded,
                        size: 18,
                        color: designTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        engine.contains('gemini') &&
                                scanResult['cloudFallback'] != true
                            ? 'Gemini Intelligence'
                            : 'On-Device Vision Engine',
                        style: designTheme.bodyRegular.copyWith(
                          fontWeight: FontWeight.w700,
                          color: designTheme.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analysis generated ${_formatTimestamp(timestamp)}',
                    style: designTheme.bodyRegular.copyWith(
                      color: designTheme.textDim,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Main results
            _buildResultCard(
              designTheme: designTheme,
              title: AppLocalizations.of(context)!.crop_identification.toUpperCase(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropType,
                    style: designTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: designTheme.textMain,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.confidence_label,
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.textDim,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(confidence * 100).toStringAsFixed(1)}%',
                        style: designTheme.bodyRegular.copyWith(
                          fontWeight: FontWeight.w700,
                          color: confidence > 0.8
                              ? designTheme.accentGreen
                              : designTheme.semanticWarning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Health status
            _buildResultCard(
              designTheme: designTheme,
              title: AppLocalizations.of(context)!.health_status.toUpperCase(),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _getHealthStatusColor(healthStatus, designTheme),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getHealthStatusColor(healthStatus, designTheme).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    healthStatus,
                    style: designTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: _getHealthStatusColor(healthStatus, designTheme),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // 2. Uncertainty Warning
            if (analysis['isUncertain'] == true)
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.all(16.0),
                decoration: designTheme.glassDecoration(
                  opacity: 0.08,
                ).copyWith(
                  color: designTheme.semanticWarning.withOpacity(0.08),
                  border: Border.all(color: designTheme.semanticWarning.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: designTheme.semanticWarning,
                      size: 24,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        'Uncertain diagnosis. The AI model suggests confirming with manual inspection.',
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.semanticWarning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 3. Visual Signs (What to look for)
            if (analysis['visualSigns'] != null &&
                analysis['visualSigns'].toString().isNotEmpty)
              _buildResultCard(
                designTheme: designTheme,
                title: 'VISUAL INDICATORS',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.remove_red_eye_rounded, color: designTheme.secondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        analysis['visualSigns'],
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.textMain.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (analysis['visualSigns'] != null &&
                analysis['visualSigns'].toString().isNotEmpty)
              const SizedBox(height: 20.0),

            // Diseases/Issues (Diagnosis Name)
            if (diseases.isNotEmpty)
              _buildResultCard(
                designTheme: designTheme,
                title: AppLocalizations.of(context)!.detected_issues.toUpperCase(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: diseases.map((disease) {
                    final name = disease['name'] as String? ?? 'Unknown Issue';
                    final severity =
                        disease['severity'] as String? ?? 'Moderate';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(severity, designTheme).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _getSeverityColor(severity, designTheme).withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: designTheme.bodyRegular.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _getSeverityColor(severity, designTheme),
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(severity, designTheme),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              severity.toUpperCase(),
                              style: designTheme.bodyRegular.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20.0),

            // 4. What To Do Next (Action Steps)
            if (analysis['actionSteps'] != null &&
                (analysis['actionSteps'] as List).isNotEmpty)
              _buildResultCard(
                designTheme: designTheme,
                title: 'RECOMMENDED ACTIONS',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (analysis['actionSteps'] as List)
                      .asMap()
                      .entries
                      .map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 2,
                                  right: 16,
                                ),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: designTheme.primary.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: TextStyle(
                                    color: designTheme.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value.toString(),
                                  style: designTheme.bodyRegular.copyWith(
                                    color: designTheme.textMain.withOpacity(0.9),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            if (analysis['actionSteps'] != null &&
                (analysis['actionSteps'] as List).isNotEmpty)
              const SizedBox(height: 20.0),

            // Disclaimer & Manual Inspection
            if (analysis['disclaimer'] != null ||
                analysis['requiresManualInspection'] == true)
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: designTheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: designTheme.secondary.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: designTheme.secondary),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        analysis['disclaimer'] ??
                            'Please confirm diagnosis with manual inspection or an expert before taking drastic action.',
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.textMain.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Top 3 Predictions (Local tie-breakers)
            if (analysis['top3'] != null &&
                (analysis['top3'] as List).isNotEmpty)
              _buildResultCard(
                designTheme: designTheme,
                title: 'MODEL PROBABILITIES',
                child: Column(
                  children: (analysis['top3'] as List).map((pred) {
                    final conf =
                        (pred['confidence'] as num?)?.toDouble() ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pred['displayName'] ?? 'Unknown',
                                  style: designTheme.bodyRegular.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: designTheme.textMain,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${(conf * 100).toStringAsFixed(1)}%',
                                style: designTheme.bodyRegular.copyWith(
                                  color: designTheme.textDim,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                                Container(
                                    height: 8,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: designTheme.textMain.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(10),
                                    ),
                                ),
                                FractionallySizedBox(
                                    widthFactor: conf,
                                    child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                            color: conf > 0.8
                                                ? designTheme.accentGreen
                                                : (conf > 0.4 ? designTheme.semanticWarning : designTheme.semanticError),
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                                BoxShadow(
                                                    color: (conf > 0.8 ? designTheme.accentGreen : designTheme.semanticWarning).withOpacity(0.3),
                                                    blurRadius: 4,
                                                )
                                            ]
                                        ),
                                    ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20.0),

            // Contextual Insights
            if (contextualInsights != null && contextualInsights.isNotEmpty)
              _buildResultCard(
                designTheme: designTheme,
                title: AppLocalizations.of(context)!.ai_insights.toUpperCase(),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: designTheme.glassDecoration(opacity: 0.05).copyWith(
                    color: designTheme.secondary.withOpacity(0.05),
                    border: Border.all(color: designTheme.secondary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: designTheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.personalized_insights,
                            style: designTheme.bodyRegular.copyWith(
                              fontWeight: FontWeight.w700,
                              color: designTheme.textMain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        contextualInsights,
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.textMain.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

            // Personalized Recommendations
            if (personalizedRecommendations.isNotEmpty)
              _buildResultCard(
                designTheme: designTheme,
                title: AppLocalizations.of(
                  context,
                )!.personlized_recommendations,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: designTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.based_on_history,
                          style: designTheme.bodyRegular.copyWith(
                            fontWeight: FontWeight.w600,
                            color: designTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...personalizedRecommendations.map((recommendation) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation.toString(),
                                style: designTheme.bodyRegular.copyWith(
                                  color: designTheme.textDim,
                                  fontSize: 12.0,
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

            // Helpful Resources
            if (learningResources.isNotEmpty)
              _buildResultCard(
                designTheme: designTheme,
                title: AppLocalizations.of(context)!.learning_resources.toUpperCase(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...learningResources.map((resource) {
                      final title = resource['title'] as String? ?? 'Unknown';
                      final description =
                          resource['description'] as String? ?? '';
                      final priority =
                          resource['priority'] as String? ?? 'medium';
                      final type = resource['type'] as String? ?? 'guide';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: designTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: designTheme.textMain.withOpacity(0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: designTheme.bodyRegular.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: designTheme.textMain,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: priority == 'urgent'
                                        ? designTheme.semanticError
                                        : designTheme.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    priority.toUpperCase(),
                                    style: designTheme.bodyRegular.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: designTheme.bodyRegular.copyWith(
                                color: designTheme.textDim,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  type == 'guide' ? Icons.menu_book_rounded : Icons.medical_services_rounded,
                                  size: 16,
                                  color: designTheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type == 'Care Guide||guide'
                                      ? AppLocalizations.of(context)!.care_guide
                                      : AppLocalizations.of(context)!.treatment_guide,
                                  style: designTheme.bodyRegular.copyWith(
                                    color: designTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.view.toUpperCase(),
                                    style: designTheme.bodyRegular.copyWith(
                                      color: designTheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

            const SizedBox(height: 32.0),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: designTheme.surface,
          border: Border(top: BorderSide(color: designTheme.textMain.withOpacity(0.05))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: designTheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.new_scan,
                    style: designTheme.bodyRegular.copyWith(
                      color: designTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    AppToast.show(
                      context,
                      message: AppLocalizations.of(context)!.result_saved_successfully,
                      variant: ToastVariant.success,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: designTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.save_result,
                    style: designTheme.bodyRegular.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required AppDesignSystem designTheme,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: designTheme.surface,
        borderRadius: BorderRadius.circular(designTheme.radiusStandard),
        border: Border.all(color: designTheme.textMain.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: designTheme.bodyRegular.copyWith(
              fontWeight: FontWeight.w800,
              color: designTheme.textDim,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  Color _getHealthStatusColor(String status, AppDesignSystem dt) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'treated':
        return dt.accentGreen;
      case 'warning':
      case 'moderate':
        return dt.semanticWarning;
      case 'critical':
      case 'severe':
        return dt.semanticError;
      default:
        return dt.textDim;
    }
  }

  Color _getSeverityColor(String severity, AppDesignSystem dt) {
    switch (severity.toLowerCase()) {
      case 'low':
        return dt.accentGreen;
      case 'moderate':
        return dt.semanticWarning;
      case 'high':
      case 'severe':
        return dt.semanticError;
      default:
        return dt.textDim;
    }
  }
}
