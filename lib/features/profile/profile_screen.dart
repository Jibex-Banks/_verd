import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/providers/auth_provider.dart';

import 'package:verd/shared/dialogs/confirmation_dialog.dart';
import 'package:verd/shared/widgets/skeleton_loader.dart';
import 'package:verd/shared/dialogs/info_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Truly not signed in (not even anonymously) — show skeleton briefly until
    // auth state resolves, or redirect happens via the router guard.
    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const ProfileSkeleton(),
      );
    }

    // Anonymous / guest user — show an upsell screen instead of a profile.
    final firebaseUser = ref.watch(firebaseAuthServiceProvider).currentUser;
    final isAnonymous = firebaseUser?.isAnonymous ?? false;
    if (isAnonymous) {
      return _buildGuestScreen(context);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Deep green from the inspiration Image #3
    final headerBgColor = isDark ? const Color(0xFF081C0B) : const Color(0xFF13401A);

    return Scaffold(
      backgroundColor: headerBgColor, // Bleeds into status bar
      body: Stack(
        children: [
          // Geometric abstract background patterns
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
          
          Column(
            children: [
              // HEADER (Constrained by SafeArea)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.profile, style: AppTypography.h2.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () => _showMoreOptions(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _buildAvatar(user.photoUrl, user.displayName, headerBgColor),
                          GestureDetector(
                            onTap: () => context.push('/edit-profile'),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.only(bottom: 4, right: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE68A00),
                                shape: BoxShape.circle,
                                border: Border.all(color: headerBgColor, width: 2),
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        user.displayName.isNotEmpty ? user.displayName : AppLocalizations.of(context)!.farmer,
                        style: AppTypography.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // BOTTOM OVERLAPPING CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
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
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        top: AppSpacing.xxl,
                        bottom: 120, // Pad enough for nav bar area + safety
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.account_overview,
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF2196F3), // Light Blue
                            title: AppLocalizations.of(context)!.my_profile,
                            onTap: () => context.push('/edit-profile'),
                          ),
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.history,
                            iconColor: const Color(0xFF4CAF50), // Green 
                            title: AppLocalizations.of(context)!.scan_history,
                            onTap: () => context.push('/scan-history'),
                          ),
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.analytics_outlined,
                            iconColor: const Color(0xFF9C27B0), // Purple
                            title: AppLocalizations.of(context)!.farming_insights,
                            onTap: () => context.push('/user-insights'),
                          ),
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.lock_outline,
                            iconColor: const Color(0xFFFF9800), // Orange
                            title: AppLocalizations.of(context)!.change_password,
                            onTap: () => context.push('/change-password'),
                          ),
                          
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.logout,
                            iconColor: const Color(0xFFF44336), // Red
                            title: AppLocalizations.of(context)!.logout,
                            onTap: () async {
                              final confirmed = await ConfirmationDialog.logout(context);
                              if (confirmed == true && context.mounted) {
                                // IMPORTANT: Actually sign out from Firebase/Google 
                                await ref.read(authRepositoryProvider).logout();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              }
                            },
                            hideChevron: true,
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

  Widget _buildAvatar(String? photoUrl, String displayName, Color borderColor) {
    const size = 100.0;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF81C784), width: 3),
        color: AppColors.primary,
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _initialsWidget(initial),
              )
            : _initialsWidget(initial),
      ),
    );
  }

  Widget _initialsWidget(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required ThemeData theme,
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
                  borderRadius: BorderRadius.circular(12), // Soft rectangular icon background
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (!hideChevron)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    InfoDialog.options(
      context,
      title: AppLocalizations.of(context)!.more_options,
      options: [
        SheetOption(
          label: AppLocalizations.of(context)!.my_profile,
          icon: Icons.person_outline,
          value: 'profile',
          color: const Color(0xFF2196F3),
        ),
        SheetOption(
          label: AppLocalizations.of(context)!.preferences_support,
          icon: Icons.settings_outlined,
          value: 'settings',
          color: const Color(0xFF9C27B0),
        ),
      ],
    ).then((result) {
      if (!context.mounted) return;
      if (result != null && result == 'profile') {
        context.push('/edit-profile');
      } else if (result != null && result == 'settings') {
        context.push('/settings');
      }
    });
  }

  /// Guest / anonymous user profile screen — prompts them to sign up.
  Widget _buildGuestScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: AppTypography.h3.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, size: 50, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'You\'re using Verd as a Guest',
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Create a free account to unlock unlimited scans, save your farm history, and access all features.',
                  style: AppTypography.body.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => context.go('/signup'),
                    child: Text(
                      'Create Free Account',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.body.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Log In',
                        style: AppTypography.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
