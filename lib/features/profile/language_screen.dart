import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/core/providers/locale_provider.dart';
import 'package:verd/l10n/app_localizations.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  // Supported languages (must have matching app_*.arb in lib/l10n)
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'nativeName': 'English', 'code': 'en', 'country': 'us'},
    {'name': 'French', 'nativeName': 'Français', 'code': 'fr', 'country': 'fr'},
    {'name': 'Spanish', 'nativeName': 'Español', 'code': 'es', 'country': 'es'},
    {'name': 'Hausa', 'nativeName': 'Hausa', 'code': 'ha', 'country': 'ng'},
    {'name': 'Yoruba', 'nativeName': 'Èdè Yorùbá', 'code': 'yo', 'country': 'ng'},
    {'name': 'Igbo', 'nativeName': 'Igbo', 'code': 'ig', 'country': 'ng'},
    {'name': 'German', 'nativeName': 'Deutsch', 'code': 'de', 'country': 'de'},
    {'name': 'Portuguese', 'nativeName': 'Português', 'code': 'pt', 'country': 'br'},
    {'name': 'Chinese', 'nativeName': '中文', 'code': 'zh', 'country': 'cn'},
    {'name': 'Japanese', 'nativeName': '日本語', 'code': 'ja', 'country': 'jp'},
    {'name': 'Korean', 'nativeName': '한국어', 'code': 'ko', 'country': 'kr'},
    {'name': 'Arabic', 'nativeName': 'العربية', 'code': 'ar', 'country': 'sa'},
    {'name': 'Hindi', 'nativeName': 'हिन्दी', 'code': 'hi', 'country': 'in'},
  ];

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final currentLocale = ref.watch(localeProvider);
    
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
          AppLocalizations.of(context)!.language,
          style: designTheme.titleLarge.copyWith(
            color: designTheme.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
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
      body: Container(
        color: designTheme.surface,
        child: ListView.separated(
          itemCount: _languages.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: designTheme.textDim.withOpacity(0.1),
            indent: 24.0,
          ),
          itemBuilder: (context, index) {
            final language = _languages[index];
            final isSelected = currentLocale.languageCode == language['code'];

            return InkWell(
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(
                  Locale(language['code']!, language['country']),
                );
                                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language['name']!,
                          style: designTheme.bodyRegular.copyWith(
                            fontWeight: FontWeight.w600,
                            color: designTheme.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          language['nativeName']!,
                          style: designTheme.bodyRegular.copyWith(
                            fontSize: 13,
                            color: designTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: designTheme.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
