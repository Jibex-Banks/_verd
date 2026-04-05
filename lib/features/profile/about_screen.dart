import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          AppLocalizations.of(context)!.about_verd,
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
          children: [
            const SizedBox(height: 12.0),
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: designTheme.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: designTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.shield, // Using shield as in screenshot
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'VERD', // Brand name, not translated
              style: designTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 32,
                color: designTheme.textMain,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              AppLocalizations.of(context)!.version,
              style: designTheme.bodyRegular.copyWith(
                fontSize: 13,
                color: designTheme.textDim,
              ),
            ),
            const SizedBox(height: 48.0),

            // Our Mission Card
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.our_mission,
                    style: designTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: designTheme.textMain,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    AppLocalizations.of(context)!.mission_desc,
                    style: designTheme.bodyRegular.copyWith(
                      color: designTheme.textDim,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Features Card
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.features,
                    style: designTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: designTheme.textMain,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildFeatureItem(context, AppLocalizations.of(context)!.feature_ai, designTheme),
                  _buildFeatureItem(context, AppLocalizations.of(context)!.feature_learning, designTheme),
                  _buildFeatureItem(context, AppLocalizations.of(context)!.feature_offline, designTheme),
                  _buildFeatureItem(context, AppLocalizations.of(context)!.feature_history, designTheme),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Terms of Service Card
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(16.0),
              onTap: () {
                AppToast.show(
                  context,
                  message: AppLocalizations.of(context)!.terms_coming_soon,
                  variant: ToastVariant.info,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.terms_of_service,
                    style: designTheme.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: designTheme.textMain,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: designTheme.textDim,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text, AppDesignSystem designTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check,
            color: designTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: designTheme.bodyRegular.copyWith(
                color: designTheme.textDim,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
