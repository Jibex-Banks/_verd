import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/providers/notification_provider.dart';
import 'package:verd/providers/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designTheme = AppDesignSystem.of(context);
    final topics = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: designTheme.background,
      appBar: AppBar(
        backgroundColor: designTheme.background,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.back,
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: designTheme.titleLarge.copyWith(
            color: designTheme.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.done,
              style: designTheme.bodyRegular.copyWith(
                color: designTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildToggleItem(
              context: context,
              designTheme: designTheme,
              title: AppLocalizations.of(context)!.push_notifications,
              subtitle: AppLocalizations.of(context)!.push_notifications_desc,
              value: settingsNotifier.notificationsEnabled,
              onChanged: (val) async {
                if (val) {
                  // Initialize FCM service if turning on
                  await ref.read(fcmServiceProvider).init();
                }
                await settingsNotifier.setNotificationsEnabled(val);
              },
            ),
            const Divider(height: 32.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.topics,
                  style: designTheme.titleLarge.copyWith(
                    fontSize: 18,
                    color: designTheme.primary,
                  ),
                ),
              ),
            ),
            _buildToggleItem(
              context: context,
              designTheme: designTheme,
              title: AppLocalizations.of(context)!.scan_results,
              subtitle: AppLocalizations.of(context)!.scan_results_desc,
              value: topics[FcmTopics.scanResults] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.scanResults, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            _buildToggleItem(
              context: context,
              designTheme: designTheme,
              title: AppLocalizations.of(context)!.learning_updates,
              subtitle: AppLocalizations.of(context)!.learning_updates_desc,
              value: topics[FcmTopics.learningUpdates] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.learningUpdates, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            _buildToggleItem(
              context: context,
              designTheme: designTheme,
              title: AppLocalizations.of(context)!.system_alerts,
              subtitle: AppLocalizations.of(context)!.system_alerts_desc,
              value: topics[FcmTopics.systemAlerts] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.systemAlerts, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            const Divider(height: 32.0),
            _buildToggleItem(
              context: context,
              designTheme: designTheme,
              title: AppLocalizations.of(context)!.email_notifications,
              subtitle: AppLocalizations.of(context)!.email_notifications_desc,
              value: true, // Mocked for now
              onChanged: (val) {},
              enabled: true,
            ),
            if (kDebugMode) ...[
              const Divider(height: 48.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.debug_tools,
                    style: designTheme.titleLarge.copyWith(
                      fontSize: 18,
                      color: designTheme.primary,
                    ),
                  ),
                ),
              ),
              AppCard(
                variant: AppCardVariant.outlined,
                onTap: () async {
                  final token = await ref.read(fcmServiceProvider).init();
                  if (token != null) {
                    await Clipboard.setData(ClipboardData(text: token));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.token_copied)),
                      );
                    }
                  }
                },
                child: ListTile(
                  leading: Icon(
                    Icons.copy_outlined,
                    color: isDark ? const Color(0xFFEF5350) : const Color(0xFFD32F2F),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.copy_token,
                    style: designTheme.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: designTheme.textMain,
                    ),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.debug_token_desc,
                    style: designTheme.bodyRegular.copyWith(
                      fontSize: 13,
                      color: designTheme.textDim,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required BuildContext context,
    required AppDesignSystem designTheme,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: designTheme.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: designTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: designTheme.bodyRegular.copyWith(
                      fontSize: 13,
                      color: designTheme.textDim,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: Colors.white,
              activeTrackColor: designTheme.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Theme.of(context).brightness == Brightness.dark
                  ? designTheme.textDim.withOpacity(0.2)
                  : const Color(0xFFE0E0E0),
            ),
          ],
        ),
      ),
    );
  }
}
