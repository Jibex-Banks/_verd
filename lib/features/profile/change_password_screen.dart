import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/app_text_field.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:df_localization/df_localization.dart';


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
        message: 'Password updated successfully',
        variant: ToastVariant.success,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            'Cancel||cancel'.tr(),
            style: AppTypography.buttonSmall.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        title: Text(
          'Change Password||change_password'.tr(),
          style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          _isSaving 
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                ),
              )
            : TextButton(
                onPressed: _handleSave,
            child: Text(
              'Save||save'.tr(),
              style: AppTypography.buttonSmall.copyWith(color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField.password(
              label: 'Current Password||current_password'.tr(),
              hint: 'Enter current password||enter_current_password'.tr(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.password(
              label: 'New Password||new_password'.tr(),
              hint: 'Enter new password||enter_new_password'.tr(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.password(
              label: 'Confirm New Password||confirm_new_password'.tr(),
              hint: 'Confirm new password||confirm_new_password'.tr(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Requirements:||password_requirements'.tr(),
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildRequirementItem(context, 'At least 8 characters long||pwd_rule_length'.tr()),
                  _buildRequirementItem(context, 'Contains uppercase and lowercase letters||pwd_rule_case'.tr()),
                  _buildRequirementItem(context, 'Contains at least one number||pwd_rule_number'.tr()),
                  _buildRequirementItem(context, 'Contains at least one special character||pwd_rule_special'.tr()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
