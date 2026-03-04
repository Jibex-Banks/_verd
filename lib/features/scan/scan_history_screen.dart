import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/skeleton_loader.dart';
import 'package:verd/shared/widgets/empty_state.dart';
import 'package:verd/shared/widgets/error_view.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  bool _isLoading = true;
  String _selectedFilter = 'All (6)';

  final List<String> _filters = ['All (6)', 'Healthy', 'Diseased'];

  final List<Map<String, dynamic>> _historyItems = [
    {
      'title': 'Healthy Crop',
      'subtitle': 'Tomato • 98% confidence',
      'date': 'Mar 3, 2026 at 09:30 AM',
      'status': 'Healthy', // Healthy
    },
    {
      'title': 'Early Blight',
      'subtitle': 'Potato • 92% confidence',
      'date': 'Mar 2, 2026 at 02:15 PM',
      'status': 'Medium', // Medium issue
    },
    {
      'title': 'Leaf Rust',
      'subtitle': 'Wheat • 95% confidence',
      'date': 'Mar 1, 2026 at 11:45 AM',
      'status': 'High', // High issue
    },
    {
      'title': 'Healthy Crop',
      'subtitle': 'Corn • 97% confidence',
      'date': 'Feb 28, 2026 at 04:20 PM',
      'status': 'Healthy',
    },
    {
      'title': 'Powdery Mildew',
      'subtitle': 'Cucumber • 89% confidence',
      'date': 'Feb 27, 2026 at 10:00 AM',
      'status': 'Low', // Low issue
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ),
          ),
        ),
        title: Text(
          'Scan History',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.filter_alt_outlined, color: AppColors.textPrimary),
                  onPressed: () {
                    // Filter logic
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4CAF50) : AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        filter,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // History List
          Expanded(
            child: _isLoading
                ? const ScanListSkeleton()
                : _historyItems.isEmpty
                    ? EmptyState.noScans()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl),
                        itemCount: _historyItems.length,
                        itemBuilder: (context, index) {
                          final item = _historyItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _buildHistoryCard(item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    Color iconBackgroundColor;
    IconData iconData;
    Color statusColor;

    switch (item['status']) {
      case 'Healthy':
        iconBackgroundColor = const Color(0xFF4CAF50);
        iconData = Icons.check;
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'Low':
        iconBackgroundColor = const Color(0xFF81C784); // light green
        iconData = Icons.warning_amber_rounded;
        statusColor = const Color(0xFF81C784);
        break;
      case 'Medium':
        iconBackgroundColor = const Color(0xFFFF9800); // orange
        iconData = Icons.warning_amber_rounded;
        statusColor = const Color(0xFFFF9800);
        break;
      case 'High':
        iconBackgroundColor = const Color(0xFFE53935); // red
        iconData = Icons.warning_amber_rounded;
        statusColor = const Color(0xFFE53935);
        break;
      default:
        iconBackgroundColor = AppColors.gray400;
        iconData = Icons.info_outline;
        statusColor = AppColors.gray400;
    }

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              iconData,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'],
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status'],
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['date'],
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.gray400,
                      size: 20,
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
}
