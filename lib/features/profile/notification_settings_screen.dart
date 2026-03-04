import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool scanResults = true;
  bool learningUpdates = false;
  bool weeklyReports = true;
  bool systemAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            'Back',
            style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              AppToast.show(
                context,
                message: 'Settings saved',
                variant: ToastVariant.success,
              );
              context.pop();
            },
            child: Text(
              'Save',
              style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            _buildToggleItem(
              title: 'Push Notifications',
              subtitle: 'Receive notifications on your device',
              value: pushNotifications,
              onChanged: (val) => setState(() => pushNotifications = val),
            ),
            _buildToggleItem(
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              value: emailNotifications,
              onChanged: (val) => setState(() => emailNotifications = val),
            ),
            _buildToggleItem(
              title: 'Scan Results',
              subtitle: 'Get notified when scan is complete',
              value: scanResults,
              onChanged: (val) => setState(() => scanResults = val),
            ),
            _buildToggleItem(
              title: 'Learning Updates',
              subtitle: 'New articles and guides',
              value: learningUpdates,
              onChanged: (val) => setState(() => learningUpdates = val),
            ),
            _buildToggleItem(
              title: 'Weekly Reports',
              subtitle: 'Summary of your activity',
              value: weeklyReports,
              onChanged: (val) => setState(() => weeklyReports = val),
            ),
            _buildToggleItem(
              title: 'System Alerts',
              subtitle: 'Important app updates',
              value: systemAlerts,
              onChanged: (val) => setState(() => systemAlerts = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.gray300,
            ),
          ],
        ),
      ),
    );
  }
}
