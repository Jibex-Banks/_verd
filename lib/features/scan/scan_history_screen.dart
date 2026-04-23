import 'package:verd/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/providers/scan_provider.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/skeleton_loader.dart';
import 'package:verd/shared/widgets/empty_state.dart';

class ScanHistoryScreen extends ConsumerStatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  ConsumerState<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends ConsumerState<ScanHistoryScreen> {
  String _selectedFilter = 'all';
  List<Map<String, String>> _getFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'key': 'all', 'label': l10n.filter_all},
      {'key': 'healthy', 'label': l10n.healthy},
      {'key': 'warning', 'label': l10n.warning},
      {'key': 'critical', 'label': l10n.critical},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
          backgroundColor: designTheme.background,
          body: Center(
              child: Text(
            AppLocalizations.of(context)!.please_log_in,
            style: designTheme.bodyRegular,
          )));
    }

    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: designTheme.background,
      appBar: AppBar(
        backgroundColor: designTheme.background,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: _buildIconButton(
              designTheme: designTheme,
              icon: Icons.chevron_left,
              onTap: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.scan_history,
          style: designTheme.titleLarge.copyWith(
            color: designTheme.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: _buildIconButton(
                designTheme: designTheme,
                icon: Icons.filter_alt_outlined,
                onTap: _showFilterSheet,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Filters horizontal pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: _getFilters(context).map((filter) {
                final isSelected = _selectedFilter == filter['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilter = filter['key']!),
                    borderRadius: BorderRadius.circular(100),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? designTheme.primary
                            : designTheme.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: isSelected
                                ? designTheme.primary
                                : designTheme.textMain.withOpacity(0.1)),
                        boxShadow: isSelected ? [
                          BoxShadow(
                             color: designTheme.primary.withOpacity(0.3),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                          )
                        ] : null,
                      ),
                      child: Text(
                        filter['label']!,
                        style: designTheme.bodyRegular.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : designTheme.textMain.withOpacity(0.6),
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24.0),
          // History List
          Expanded(
            child: historyAsync.when(
              loading: () => const ScanListSkeleton(),
              error: (err, stack) => Center(child: Text('Error: $err', style: designTheme.bodyRegular)),
              data: (items) {
                final filtered = _selectedFilter == 'all'
                    ? items
                    : items.where((item) => item.diagnosis.toLowerCase() == _selectedFilter.toLowerCase()).toList();

                if (filtered.isEmpty) {
                  return EmptyState.noScans();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildHistoryCard(context, filtered[index], designTheme),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final designTheme = AppDesignSystem.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: designTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: designTheme.textMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 28.0),
              Text(
                AppLocalizations.of(context)!.filter_by_status,
                style: designTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: designTheme.textMain,
                ),
              ),
              const SizedBox(height: 20.0),
              ..._getFilters(context).map((filter) {
                final isSelected = _selectedFilter == filter['key'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? designTheme.primary.withOpacity(0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isSelected ? designTheme.primary : designTheme.textMain.withOpacity(0.2),
                                width: 2
                            )
                        ),
                        child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? designTheme.primary : Colors.transparent
                            ),
                        ),
                    ),
                    title: Text(
                      filter['label']!,
                      style: designTheme.bodyRegular.copyWith(
                        color: isSelected ? designTheme.textMain : designTheme.textDim,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedFilter = filter['key']!);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    required AppDesignSystem designTheme,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: designTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: designTheme.textMain.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: designTheme.textMain, size: 22),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ScanResult item, AppDesignSystem dt) {
    final statusColor = _getStatusColor(item.diagnosis, dt);
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      onTap: () => context.push('/scan-result', extra: item),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: item.imageUrl != null
                  ? _buildHistoryImage(item, statusColor)
                  : (item.localImagePath != null &&
                          File(item.localImagePath!).existsSync())
                      ? Image.file(
                          File(item.localImagePath!),
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image_outlined, color: statusColor),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.plantName,
                        style: dt.bodyRegular.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          item.diagnosis.toUpperCase(),
                          style: dt.bodyRegular.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 14, color: dt.textDim),
                    const SizedBox(width: 4),
                    Text(
                      '${(item.confidence * 100).toStringAsFixed(0)}% accuracy',
                      style: dt.bodyRegular.copyWith(
                        color: dt.textDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _formatDate(item.scannedAt),
                  style: dt.bodyRegular.copyWith(
                    color: dt.textDim.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryImage(ScanResult item, Color statusColor) {
    final localPath = item.localImagePath;
    final hasLocal = localPath != null && File(localPath).existsSync();
    if (hasLocal) {
      return Image.file(File(localPath), fit: BoxFit.cover);
    }
    return Image.network(
      item.imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported_outlined, color: statusColor),
    );
  }

  Color _getStatusColor(String status, AppDesignSystem dt) {
    switch (status.toLowerCase()) {
      case 'healthy': return dt.accentGreen;
      case 'warning': return dt.semanticWarning;
      case 'critical': return dt.semanticError;
      default: return dt.textDim;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
