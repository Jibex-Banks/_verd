import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';

import 'package:verd/shared/widgets/skeleton_loader.dart';
import 'package:verd/shared/widgets/bouncing_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onProfileTap;
  
  const HomeScreen({
    super.key,
    this.onScanTap,
    this.onProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: designTheme.primary,
                  borderRadius: BorderRadius.circular(designTheme.radiusStandard),
                  border: Border.all(color: designTheme.primary.withOpacity(0.3)),
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
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.tip_of_the_day.toUpperCase(),
                        style: designTheme.bodyRegular.copyWith(
                          color: Colors.white,
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
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      AppLocalizations.of(context)!.early_detection_desc,
                      style: designTheme.bodyRegular.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),

              // ── Popular Topics ──
              Text(
                AppLocalizations.of(context)!.popular_topics,
                style: designTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: designTheme.textMain,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 12.0),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.95,
                children: [
                   _buildTopicCard(
                    iconBackgroundColor: designTheme.semanticError,
                    icon: Icons.coronavirus_rounded,
                    title: AppLocalizations.of(context)!.crop_diseases,
                    subtitle: AppLocalizations.of(context)!.crop_diseases_desc_short,
                    onTap: () => context.push('/article/diseases'),
                  ),
                  _buildTopicCard(
                    iconBackgroundColor: designTheme.secondary,
                    icon: Icons.bug_report_rounded,
                    title: AppLocalizations.of(context)!.pest_control,
                    subtitle: AppLocalizations.of(context)!.pest_control_desc_short,
                    onTap: () => context.push('/article/pests'),
                  ),
                  _buildTopicCard(
                    iconBackgroundColor: designTheme.primary,
                    icon: Icons.grass_rounded,
                    title: AppLocalizations.of(context)!.soil_health,
                    subtitle: AppLocalizations.of(context)!.soil_health_desc_short,
                    onTap: () => context.push('/article/soil'),
                  ),
                  _buildTopicCard(
                    iconBackgroundColor: designTheme.secondary,
                    icon: Icons.water_drop_rounded,
                    title: AppLocalizations.of(context)!.irrigation,
                    subtitle: AppLocalizations.of(context)!.irrigation_desc_short,
                    onTap: () => context.push('/article/water'),
                  ),
                ],
              ),
              const SizedBox(height: 32.0), // Bottom padding
            ],
          ),
        ),
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
              color: Colors.black.withOpacity(0.06),
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
    return BouncingCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: designTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: designTheme.textMain.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
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