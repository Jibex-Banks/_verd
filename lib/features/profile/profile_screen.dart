import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    // Truly not signed in (not even anonymously) — show skeleton briefly until
    // auth state resolves, or redirect happens via the router guard.
    if (user == null) {
      return const Scaffold(
        body: ProfileSkeleton(),
      );
    }

    // Anonymous / guest user — show an upsell screen instead of a profile.
    final firebaseUser = ref.watch(firebaseAuthServiceProvider).currentUser;
    final isAnonymous = firebaseUser?.isAnonymous ?? false;
    if (isAnonymous) {
      return _buildGuestScreen(context);
    }

    final designTheme = AppDesignSystem.of(context);
    final headerBgColor = colorScheme.primaryContainer;

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
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.05),
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
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.05),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.profile, 
                            style: designTheme.titleLarge.copyWith(
                              color: colorScheme.onPrimaryContainer, 
                              fontWeight: FontWeight.w800
                            )
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert, color: colorScheme.onPrimaryContainer),
                            onPressed: () => _showMoreOptions(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
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
                                color: designTheme.semanticWarning,
                                shape: BoxShape.circle,
                                border: Border.all(color: headerBgColor, width: 2),
                              ),
                              child: Icon(Icons.edit, color: colorScheme.onPrimary, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        user.displayName.isNotEmpty ? user.displayName : AppLocalizations.of(context)!.farmer,
                        style: designTheme.titleLarge.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: designTheme.bodyRegular.copyWith(
                          fontSize: 13,
                          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                        ),
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
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.account_overview,
                            style: designTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: designTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          _buildMenuItem(
                            designTheme: designTheme,
                            icon: Icons.person_outline,
                            iconColor: designTheme.secondary,
                            title: AppLocalizations.of(context)!.my_profile,
                            onTap: () => context.push('/edit-profile'),
                          ),
                          _buildMenuItem(
                            designTheme: designTheme,
                            icon: Icons.history,
                            iconColor: designTheme.accentGreen,
                            title: AppLocalizations.of(context)!.scan_history,
                            onTap: () => context.push('/scan-history'),
                          ),
                          _buildMenuItem(
                            designTheme: designTheme,
                            icon: Icons.analytics_outlined,
                            iconColor: designTheme.primary,
                            title: AppLocalizations.of(context)!.farming_insights,
                            onTap: () => context.push('/user-insights'),
                          ),
                          _buildMenuItem(
                            designTheme: designTheme,
                            icon: Icons.lock_outline,
                            iconColor: designTheme.semanticWarning,
                            title: AppLocalizations.of(context)!.change_password,
                            onTap: () => context.push('/change-password'),
                          ),
                          
                          _buildMenuItem(
                            designTheme: designTheme,
                            icon: Icons.logout,
                            iconColor: designTheme.semanticError,
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
    final designTheme = AppDesignSystem.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: designTheme.accentGreen, width: 3),
        color: designTheme.primary,
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
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
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
                  borderRadius: BorderRadius.circular(12), // Soft rectangular icon background
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

  void _showMoreOptions(BuildContext context) {
    InfoDialog.options(
      context,
      title: AppLocalizations.of(context)!.more_options,
      options: [
        SheetOption(
          label: AppLocalizations.of(context)!.my_profile,
          icon: Icons.person_outline,
          value: 'profile',
          color: AppDesignSystem.of(context).secondary,
        ),
        SheetOption(
          label: AppLocalizations.of(context)!.preferences_support,
          icon: Icons.settings_outlined,
          value: 'settings',
          color: AppDesignSystem.of(context).primary,
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
    final designTheme = AppDesignSystem.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: designTheme.background,
      appBar: AppBar(
        backgroundColor: designTheme.background,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: designTheme.titleLarge.copyWith(
            color: designTheme.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: designTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline, size: 50, color: designTheme.primary),
                ),
                const SizedBox(height: 32.0),
                Text(
                  'You\'re using Verd as a Guest',
                  style: designTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: designTheme.textMain,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Text(
                  'Create a free account to unlock unlimited scans, save your farm history, and access all features.',
                  style: designTheme.bodyRegular.copyWith(
                    color: designTheme.textDim,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48.0),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: designTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => context.go('/signup'),
                    child: Text(
                      'Create Free Account',
                      style: designTheme.bodyRegular.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: designTheme.bodyRegular.copyWith(
                        color: designTheme.textDim,
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
                        style: designTheme.bodyRegular.copyWith(
                          color: designTheme.primary,
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
