import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_button.dart';
import 'package:verd/shared/dialogs/confirmation_dialog.dart';
import 'package:verd/shared/widgets/skeleton_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading for the profile skeleton
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: ProfileSkeleton(),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Bar ──
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
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
                    icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                    onPressed: () {
                      context.go('/home');
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Profile Header ──
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50), // Green
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Ada',
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ada.farmer@verd.com',
                      style: AppTypography.body.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      text: 'Edit Profile Picture',
                      onPressed: () {
                        context.push('/edit-profile');
                      },
                      customColor: const Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Menu Items ──
              _buildMenuItem(
                icon: Icons.edit,
                iconColor: const Color(0xFFFFB300),
                title: 'Edit Profile',
                onTap: () {
                  context.push('/edit-profile');
                },
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                iconColor: const Color(0xFF8D6E63),
                title: 'Change Password',
                onTap: () {
                  context.push('/change-password');
                },
              ),
              _buildMenuItem(
                icon: Icons.notifications_active,
                iconColor: const Color(0xFFFF9800),
                title: 'Notification Settings',
                onTap: () {
                  context.push('/notifications');
                },
              ),
              _buildMenuItem(
                icon: Icons.language,
                iconColor: const Color(0xFF2196F3),
                title: 'Language',
                onTap: () {
                  context.push('/language');
                },
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                iconColor: const Color(0xFFE53935), // Red question mark in design
                title: 'Help & Support',
                onTap: () {
                  context.push('/help-support');
                },
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF607D8B),
                title: 'About VERD',
                onTap: () {
                  context.push('/about');
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Logout Button ──
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Logout',
                  onPressed: () async {
                    final confirmed = await ConfirmationDialog.logout(context);
                    if (confirmed == true && context.mounted) {
                      context.go('/login');
                    }
                  },
                  customColor: const Color(0xFFF44336), // Red
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
