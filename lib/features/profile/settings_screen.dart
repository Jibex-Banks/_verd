import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final headerBgColor = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF081C0B) : const Color(0xFF13401A);

    return Scaffold(
      backgroundColor: headerBgColor,
      body: Stack(
        children: [
          // Geometric abstract background patterns (same as profile screen)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Main content
          Column(
            children: [
              // HEADER
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.preferences_support,
                            style: designTheme.titleLarge.copyWith(
                              color: Colors.white, 
                              fontWeight: FontWeight.w800
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ),

              // BOTTOM OVERLAPPING CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: designTheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        top: 32.0,
                        bottom: 120,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.preferences_support,
                            style: designTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: designTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          _buildMenuItem(
                            designTheme: designTheme,
                            icon: Icons.notifications_none,
                            iconColor: const Color(0xFFE91E63), // Pink
                            title: AppLocalizations.of(context)!.notifications,
                            onTap: () => context.push('/notifications'),
                          ),
                          
                          _buildMenuItem(
                            designTheme: designTheme,
                            icon: Icons.language,
                            iconColor: const Color(0xFF9C27B0), // Purple
                            title: AppLocalizations.of(context)!.change_language,
                            onTap: () => context.push('/language'),
                          ),

                          const SizedBox(height: 24.0),
                          
                          _buildThemeToggleItem(designTheme),
                           
                          const SizedBox(height: 24.0),

                          _buildMenuItem(
                            designTheme: designTheme,
                            icon: Icons.help_outline,
                            iconColor: const Color(0xFF00BCD4), // Cyan
                            title: AppLocalizations.of(context)!.help_support,
                            onTap: () => context.push('/help-support'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required AppDesignSystem designTheme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool hideChevron = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  title,
                  style: designTheme.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    color: designTheme.textMain,
                  ),
                ),
              ),
              if (!hideChevron)
                Icon(
                  Icons.chevron_right,
                  color: designTheme.textDim.withOpacity(0.5),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleItem(AppDesignSystem designTheme) {
    final currentMode = ref.watch(themeProvider);
    
    // Determine active icon 
    IconData activeIcon = Icons.brightness_auto;
    Color activeColor = const Color(0xFF673AB7); // Deep Purple
    
    if (currentMode == ThemeMode.dark) {
      activeIcon = Icons.dark_mode;
      activeColor = const Color(0xFF3F51B5); // Indigo
    } else if (currentMode == ThemeMode.light) {
      activeIcon = Icons.light_mode;
      activeColor = const Color(0xFFFF9800); // Orange
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(activeIcon, color: activeColor, size: 24),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.appearance,
                  style: designTheme.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    color: designTheme.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.only(left: 60.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: designTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: designTheme.textDim.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  _buildCustomToggleBtn(
                    designTheme: designTheme,
                    title: AppLocalizations.of(context)!.system,
                    icon: Icons.brightness_auto,
                    isSelected: currentMode == ThemeMode.system,
                    onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
                  ),
                  _buildCustomToggleBtn(
                    designTheme: designTheme,
                    title: AppLocalizations.of(context)!.light,
                    icon: Icons.light_mode,
                    isSelected: currentMode == ThemeMode.light,
                    onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
                  ),
                  _buildCustomToggleBtn(
                    designTheme: designTheme,
                    title: AppLocalizations.of(context)!.dark,
                    icon: Icons.dark_mode,
                    isSelected: currentMode == ThemeMode.dark,
                    onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomToggleBtn({
    required AppDesignSystem designTheme,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? designTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: designTheme.primary.withValues(alpha: 0.5), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? designTheme.primary : designTheme.textDim,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: designTheme.bodyRegular.copyWith(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? designTheme.textMain : designTheme.textDim,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
