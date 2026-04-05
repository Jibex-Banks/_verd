import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:verd/shared/widgets/app_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(BuildContext context, Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        AppToast.show(context, message: 'Could not launch link', variant: ToastVariant.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    return Scaffold(
      backgroundColor: designTheme.background,
      appBar: AppBar(
        backgroundColor: designTheme.background,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            context.pop();
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
          AppLocalizations.of(context)!.help_support,
          style: designTheme.titleLarge.copyWith(
            color: designTheme.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.contact_us,
              style: designTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: designTheme.textMain,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildContactItem(
              context: context,
              designTheme: designTheme,
              icon: Icons.email_outlined,
              title: AppLocalizations.of(context)!.email_support,
              subtitle: 'support@verd.app',
              onTap: () {
                _launchUrl(context, Uri(scheme: 'mailto', path: 'playbetgenius@gmail.com'));
              },
            ),
            _buildContactItem(
              context: context,
              designTheme: designTheme,
              icon: Icons.phone_outlined,
              title: AppLocalizations.of(context)!.call_us,
              subtitle: '+1 (800) 123-4567',
              onTap: () {
                _launchUrl(context, Uri(scheme: 'tel', path: '+18001234567'));
              },
            ),
            _buildContactItem(
              context: context,
              designTheme: designTheme,
              icon: Icons.chat_bubble_outline,
              title: AppLocalizations.of(context)!.live_chat,
              subtitle: AppLocalizations.of(context)!.live_chat_desc,
              onTap: () {
                _launchUrl(context, Uri.parse('https://wa.me/2348087400168'));
              },
            ),
            const SizedBox(height: 40.0),
            
            Text(
              AppLocalizations.of(context)!.faqs,
              style: designTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: designTheme.textMain,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildFAQItem(
              context: context,
              designTheme: designTheme,
              question: AppLocalizations.of(context)!.faq_scan_q,
              answer: AppLocalizations.of(context)!.faq_scan_a,
            ),
            _buildFAQItem(
              context: context,
              designTheme: designTheme,
              question: AppLocalizations.of(context)!.faq_accuracy_q,
              answer: AppLocalizations.of(context)!.faq_accuracy_a,
            ),
            _buildFAQItem(
              context: context,
              designTheme: designTheme,
              question: AppLocalizations.of(context)!.faq_offline_q,
              answer: AppLocalizations.of(context)!.faq_offline_a,
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required AppDesignSystem designTheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.all(16.0),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: designTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: designTheme.primary,
                size: 24,
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
                      fontWeight: FontWeight.w600,
                      color: designTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            Icon(
              Icons.chevron_right,
              color: designTheme.textDim,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required AppDesignSystem designTheme,
    required String question,
    required String answer,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: designTheme.bodyRegular.copyWith(
                fontWeight: FontWeight.w600,
                color: designTheme.textMain,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              answer,
              style: designTheme.bodyRegular.copyWith(
                color: designTheme.textDim,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
