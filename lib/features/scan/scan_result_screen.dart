import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/l10n/app_localizations.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> scanResult;
  final String? imageUrl;

  const ScanResultScreen({super.key, required this.scanResult, this.imageUrl});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.scanResult['savedToCloud'] == true ||
        widget.scanResult['fromHistory'] == true;
  }

  Future<void> _saveResult() async {
    if (_isSaved || _isSaving) return;
    final user = ref.read(currentUserProvider);
    if (user == null) {
      AppToast.show(context, message: AppLocalizations.of(context)!.please_log_in_scanner, variant: ToastVariant.error);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final analysis = widget.scanResult['analysis'] as Map<String, dynamic>? ?? {};
      final scanId = widget.scanResult['scanId'] as String? ?? const Uuid().v4();
      final diseases = analysis['diseases'] as List<dynamic>? ?? [];
      final recommendations = diseases
          .map((d) => (d as Map<String, dynamic>)['treatment']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      final scan = ScanResult(
        id: scanId,
        userId: widget.scanResult['userId'] as String? ?? user.uid,
        imageUrl: widget.scanResult['imageUrl'] as String?,
        localImagePath: widget.scanResult['localImagePath'] as String? ?? widget.imageUrl,
        plantName: analysis['cropType'] as String? ?? 'Unknown',
        diagnosis: analysis['healthStatus'] as String? ?? 'Unknown',
        confidence: (analysis['confidence'] as num?)?.toDouble() ?? 0.0,
        recommendations: recommendations,
        scannedAt: DateTime.tryParse(widget.scanResult['timestamp'] as String? ?? '') ?? DateTime.now(),
        synced: false,
        analysisMap: analysis,
      );
      // 1. Save to Hive immediately (always works offline)
      await ref.read(localStorageServiceProvider).cacheScanResult(scan);

      // 2. Attempt Firestore sync only if online and registered user
      final isAnonymous = ref.read(firebaseAuthServiceProvider).currentUser?.isAnonymous ?? true;
      if (!isAnonymous) {
        final connectivity = await Connectivity().checkConnectivity();
        final isOnline = !connectivity.contains(ConnectivityResult.none) && connectivity.isNotEmpty;
        if (isOnline) {
          try {
            await ref.read(firestoreServiceProvider).saveScanRaw(user.uid, scanId, scan.toFirestore());
            // Mark as synced in Hive
            await ref.read(localStorageServiceProvider).markSynced(
              scanId,
              remoteImageUrl: widget.scanResult['imageUrl'] as String?,
            );
          } catch (_) {} // SyncService will retry later
        }
      }
      if (mounted) {
        setState(() { _isSaved = true; _isSaving = false; });
        AppToast.show(context, message: AppLocalizations.of(context)!.result_saved_successfully, variant: ToastVariant.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.show(context, message: 'Failed to save: $e', variant: ToastVariant.error);
      }
    }
  }

  String _fmtTimestamp(String ts) {
    try {
      final d = DateTime.parse(ts);
      return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) { return ts; }
  }

  @override
  Widget build(BuildContext context) {
    final dt = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final analysis = widget.scanResult['analysis'] as Map<String, dynamic>? ?? {};
    final engine = widget.scanResult['engine'] as String? ?? 'unknown';
    final timestamp = widget.scanResult['timestamp'] as String? ?? '';

    final cropType = analysis['cropType'] as String? ?? 'Unknown Crop';
    final healthStatus = analysis['healthStatus'] as String? ?? 'Unknown';
    final confidence = (analysis['confidence'] as num?)?.toDouble() ?? 0.0;
    final diseases = analysis['diseases'] as List<dynamic>? ?? [];
    final personalizedRecommendations =
        widget.scanResult['personalizedRecommendations'] as List<dynamic>? ?? [];
    final learningResources =
        widget.scanResult['learningResources'] as List<dynamic>? ?? [];
    final contextualInsights = analysis['contextualInsights'] as String?;
    final actionSteps = analysis['actionSteps'] as List<dynamic>? ?? [];
    final top3 = analysis['top3'] as List<dynamic>? ?? [];
    final visualSigns = analysis['visualSigns'] as String? ?? '';

    final isCloudFallback = widget.scanResult['cloudFallback'] == true;
    final isUncertain = analysis['isUncertain'] == true;
    final isOnline = engine.contains('gemini') && !isCloudFallback;
    final engineLabel = isOnline ? 'Verd Online AI' : 'Verd Offline';
    final healthColor = _healthColor(healthStatus, dt);

    return Scaffold(
      backgroundColor: dt.background,
      appBar: AppBar(
        title: Text(
          l10n.scan_results,
          style: dt.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: dt.background,
        foregroundColor: dt.textMain,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HERO: image + crop + health + engine ─────────────────────
            _HeroCard(
              dt: dt,
              imageUrl: widget.imageUrl,
              cropType: cropType,
              healthStatus: healthStatus,
              healthColor: healthColor,
              confidence: confidence,
              engineLabel: engineLabel,
              timestamp: timestamp,
              isOnline: isOnline,
            ),
            const SizedBox(height: 16),

            // ── WARNINGS ─────────────────────────────────────────────────
            if (isCloudFallback) ...[
              _Banner(
                dt: dt,
                icon: Icons.wifi_off_rounded,
                color: dt.semanticWarning,
                message:
                    'Cloud analysis unavailable. Showing on-device results instead.',
              ),
              const SizedBox(height: 12),
            ],
            if (isUncertain) ...[
              _Banner(
                dt: dt,
                icon: Icons.help_outline_rounded,
                color: dt.semanticWarning,
                message:
                    'Uncertain diagnosis. Confirm result with manual inspection.',
              ),
              const SizedBox(height: 12),
            ],

            // ── VISUAL INDICATORS ────────────────────────────────────────
            if (visualSigns.isNotEmpty) ...[
              _ResultCard(
                dt: dt,
                title: 'VISUAL INDICATORS',
                icon: Icons.remove_red_eye_rounded,
                iconColor: dt.secondary,
                child: Text(
                  visualSigns,
                  style: dt.bodyRegular.copyWith(
                    color: dt.textMain.withOpacity(0.9),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── DETECTED ISSUES ──────────────────────────────────────────
            if (diseases.isNotEmpty) ...[
              _ResultCard(
                dt: dt,
                title: l10n.detected_issues.toUpperCase(),
                child: Column(
                  children: diseases.map((d) {
                    final name = d['name'] as String? ?? 'Unknown Issue';
                    final severity = d['severity'] as String? ?? 'Moderate';
                    final sevColor = _severityColor(severity, dt);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: sevColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: sevColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: dt.bodyRegular.copyWith(
                                fontWeight: FontWeight.w700,
                                color: sevColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _Chip(
                            label: severity.toUpperCase(),
                            color: sevColor,
                            dt: dt,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── RECOMMENDED ACTIONS ──────────────────────────────────────
            if (actionSteps.isNotEmpty) ...[
              _ResultCard(
                dt: dt,
                title: 'RECOMMENDED ACTIONS',
                child: Column(
                  children: actionSteps.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StepBadge(number: e.key + 1, dt: dt),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              e.value.toString(),
                              style: dt.bodyRegular.copyWith(
                                color: dt.textMain.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── DISCLAIMER ───────────────────────────────────────────────
            if (analysis['disclaimer'] != null ||
                analysis['requiresManualInspection'] == true) ...[
              _Banner(
                dt: dt,
                icon: Icons.info_outline_rounded,
                color: dt.secondary,
                message: analysis['disclaimer'] ??
                    'Please confirm diagnosis with manual inspection or an expert before taking drastic action.',
              ),
              const SizedBox(height: 16),
            ],

            // ── MODEL PROBABILITIES ──────────────────────────────────────
            if (top3.isNotEmpty) ...[
              _ResultCard(
                dt: dt,
                title: 'MODEL PROBABILITIES',
                child: Column(
                  children: top3.map((pred) {
                    final conf =
                        (pred['confidence'] as num?)?.toDouble() ?? 0.0;
                    final barColor = conf > 0.8
                        ? dt.accentGreen
                        : (conf > 0.4
                            ? dt.semanticWarning
                            : dt.semanticError);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pred['displayName'] ?? 'Unknown',
                                  style: dt.bodyRegular.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: dt.textMain,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${(conf * 100).toStringAsFixed(1)}%',
                                style: dt.bodyRegular.copyWith(
                                  color: barColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      dt.textMain.withOpacity(0.06),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: conf,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: barColor
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
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
              const SizedBox(height: 16),
            ],

            // ── AI INSIGHTS ──────────────────────────────────────────────
            if (contextualInsights != null &&
                contextualInsights.isNotEmpty) ...[
              _ResultCard(
                dt: dt,
                title: l10n.ai_insights.toUpperCase(),
                icon: Icons.lightbulb_outline_rounded,
                iconColor: dt.secondary,
                child: Text(
                  contextualInsights,
                  style: dt.bodyRegular.copyWith(
                    color: dt.textMain.withOpacity(0.85),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── PERSONALIZED RECOMMENDATIONS ─────────────────────────────
            if (personalizedRecommendations.isNotEmpty) ...[
              _ResultCard(
                dt: dt,
                title: l10n.personlized_recommendations,
                icon: Icons.person_outline_rounded,
                iconColor: dt.primary,
                child: Column(
                  children: personalizedRecommendations.map((rec) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              color: dt.accentGreen, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rec.toString(),
                              style: dt.bodyRegular.copyWith(
                                color: dt.textDim,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── LEARNING RESOURCES ───────────────────────────────────────
            if (learningResources.isNotEmpty) ...[
              _ResultCard(
                dt: dt,
                title: l10n.learning_resources.toUpperCase(),
                child: Column(
                  children: learningResources.map((resource) {
                    final title =
                        resource['title'] as String? ?? 'Unknown';
                    final description =
                        resource['description'] as String? ?? '';
                    final priority =
                        resource['priority'] as String? ?? 'medium';
                    final type =
                        resource['type'] as String? ?? 'guide';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: dt.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: dt.textMain.withOpacity(0.07)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: dt.bodyRegular.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: dt.textMain,
                                  ),
                                ),
                              ),
                              _Chip(
                                label: priority.toUpperCase(),
                                color: priority == 'urgent'
                                    ? dt.semanticError
                                    : dt.secondary,
                                dt: dt,
                                colorScheme: colorScheme,
                                fontSize: 9,
                                borderRadius: 6,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: dt.bodyRegular.copyWith(
                              color: dt.textDim,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                type == 'guide'
                                    ? Icons.menu_book_rounded
                                    : Icons.medical_services_rounded,
                                size: 15,
                                color: dt.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                type == 'guide'
                                    ? l10n.care_guide
                                    : l10n.treatment_guide,
                                style: dt.bodyRegular.copyWith(
                                  color: dt.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  final id = title
                                      .toLowerCase()
                                      .replaceAll(' ', '-')
                                      .replaceAll('_', '-');
                                  context.push('/article/$id');
                                },
                                child: Text(
                                  l10n.view.toUpperCase(),
                                  style: dt.bodyRegular.copyWith(
                                    color: dt.primary,
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
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        dt: dt,
        colorScheme: colorScheme,
        isSaved: _isSaved,
        isSaving: _isSaving,
        onSave: _saveResult,
      ),
    );
  }

  Color _healthColor(String status, AppDesignSystem dt) {
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

  Color _severityColor(String severity, AppDesignSystem dt) {
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

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final AppDesignSystem dt;
  final String? imageUrl;
  final String cropType;
  final String healthStatus;
  final Color healthColor;
  final double confidence;
  final String engineLabel;
  final String timestamp;
  final bool isOnline;

  const _HeroCard({
    required this.dt,
    required this.imageUrl,
    required this.cropType,
    required this.healthStatus,
    required this.healthColor,
    required this.confidence,
    required this.engineLabel,
    required this.timestamp,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: dt.surface,
        borderRadius: BorderRadius.circular(dt.radiusStandard),
        border: Border.all(color: dt.textMain.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scanned image
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(dt.radiusStandard),
              ),
              child: _buildScanImage(),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Engine badge + timestamp
                Row(
                  children: [
                    Icon(
                      isOnline
                          ? Icons.cloud_done_rounded
                          : Icons.memory_rounded,
                      size: 14,
                      color: dt.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      engineLabel,
                      style: dt.bodyRegular.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: dt.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _fmt(timestamp),
                      style: dt.bodyRegular.copyWith(
                        color: dt.textDim,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 28,
                  color: dt.textMain.withOpacity(0.07),
                ),

                // Crop name + health status side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Crop
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CROP',
                            style: dt.bodyRegular.copyWith(
                              fontWeight: FontWeight.w800,
                              color: dt.textDim,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cropType,
                            style: dt.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Health + confidence
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: healthColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: healthColor.withOpacity(0.45),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              healthStatus,
                              style: dt.bodyRegular.copyWith(
                                fontWeight: FontWeight.w700,
                                color: healthColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                          style: dt.bodyRegular.copyWith(
                            fontSize: 12,
                            color: confidence > 0.8
                                ? dt.accentGreen
                                : dt.semanticWarning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(String timestamp) {
    try {
      final d = DateTime.parse(timestamp);
      return '${d.day}/${d.month}/${d.year} '
          '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  Widget _buildScanImage() {
    final value = imageUrl;
    if (value == null || value.trim().isEmpty) {
      return _imageErrorPlaceholder();
    }

    final isRemote = _isRemoteImage(value);
    return isRemote
        ? Image.network(
            value,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imageErrorPlaceholder(),
          )
        : Image.file(
            File(_localFilePath(value)),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imageErrorPlaceholder(),
          );
  }

  bool _isRemoteImage(String value) {
    final uri = Uri.tryParse(value);
    final scheme = uri?.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }

  String _localFilePath(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.scheme.toLowerCase() == 'file') {
      return uri.toFilePath();
    }
    return value;
  }

  Widget _imageErrorPlaceholder() {
    return Container(
      height: 100,
      color: dt.textMain.withOpacity(0.05),
      child: Center(
        child: Icon(Icons.image_not_supported, size: 32, color: dt.textDim),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final AppDesignSystem dt;
  final String title;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;

  const _ResultCard({
    required this.dt,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dt.surface,
        borderRadius: BorderRadius.circular(dt.radiusStandard),
        border: Border.all(color: dt.textMain.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor, size: 15),
                const SizedBox(width: 7),
              ],
              Text(
                title,
                style: dt.bodyRegular.copyWith(
                  fontWeight: FontWeight.w800,
                  color: dt.textDim,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER (warnings, disclaimers)
// ─────────────────────────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  final AppDesignSystem dt;
  final IconData icon;
  final Color color;
  final String message;

  const _Banner({
    required this.dt,
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: dt.bodyRegular.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final AppDesignSystem dt;
  final ColorScheme colorScheme;
  final double fontSize;
  final double borderRadius;

  const _Chip({
    required this.label,
    required this.color,
    required this.dt,
    required this.colorScheme,
    this.fontSize = 10,
    this.borderRadius = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: dt.bodyRegular.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  final int number;
  final AppDesignSystem dt;

  const _StepBadge({required this.number, required this.dt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: dt.primary.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          color: dt.primary,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM BAR
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final AppDesignSystem dt;
  final ColorScheme colorScheme;
  final VoidCallback onSave;
  final bool isSaved;
  final bool isSaving;

  const _BottomBar({
    required this.dt,
    required this.colorScheme,
    required this.onSave,
    required this.isSaved,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: dt.surface,
        border: Border(
          top: BorderSide(color: dt.textMain.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: dt.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.new_scan,
                  style: dt.bodyRegular.copyWith(
                    color: dt.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (isSaved || isSaving) ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaved ? dt.accentGreen : dt.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: isSaved ? dt.accentGreen : dt.primary.withOpacity(0.6),
                  disabledForegroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSaved) ...[
                            const Icon(Icons.check_circle_rounded, size: 18),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            isSaved ? 'Saved' : l10n.save_result,
                            style: dt.bodyRegular.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}