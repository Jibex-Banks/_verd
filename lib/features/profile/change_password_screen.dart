import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/app_text_field.dart';
import 'package:verd/shared/widgets/app_toast.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isSaving = false;

  void _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        message: AppLocalizations.of(context)!.password_update_success,
        variant: ToastVariant.success,
      );
      context.pop();
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
        leadingWidth: 90,
        leading: TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppLocalizations.of(context)!.change_password,
            style: designTheme.titleLarge.copyWith(
              color: designTheme.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          _isSaving 
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, 
                    color: designTheme.primary
                  ),
                ),
              )
            : TextButton(
                onPressed: _handleSave,
            child: Text(
              AppLocalizations.of(context)!.save,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField.password(label: AppLocalizations.of(context)!.current_password,
              hint: AppLocalizations.of(context)!.enter_current_password,
            ),
            const SizedBox(height: 24.0),
            AppTextField.password(label: AppLocalizations.of(context)!.new_password,
              hint: AppLocalizations.of(context)!.enter_new_password,
            ),
            const SizedBox(height: 24.0),
            AppTextField.password(label: AppLocalizations.of(context)!.confirm_new_password,
              hint: AppLocalizations.of(context)!.confirm_new_password,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32.0),
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.password_requirements,
                    style: designTheme.bodyRegular.copyWith(
                      fontWeight: FontWeight.w800,
                      color: designTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildRequirementItem(context, AppLocalizations.of(context)!.pwd_rule_length, designTheme),
                  _buildRequirementItem(context, AppLocalizations.of(context)!.pwd_rule_case, designTheme),
                  _buildRequirementItem(context, AppLocalizations.of(context)!.pwd_rule_number, designTheme),
                  _buildRequirementItem(context, AppLocalizations.of(context)!.pwd_rule_special, designTheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(BuildContext context, String text, AppDesignSystem designTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: designTheme.bodyRegular.copyWith(
          color: designTheme.textDim,
          fontSize: 13,
        ),
      ),
    );
  }
}
