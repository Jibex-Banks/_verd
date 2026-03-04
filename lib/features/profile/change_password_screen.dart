import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/app_text_field.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:verd/shared/widgets/loading_indicator.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            'Cancel',
            style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(
          'Change Password',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          _isSaving 
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              )
            : TextButton(
                onPressed: _handleSave,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField.password(
              label: 'Current Password',
              hint: 'Enter current password',
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.password(
              label: 'New Password',
              hint: 'Enter new password',
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.password(
              label: 'Confirm New Password',
              hint: 'Confirm new password',
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
                    'Password Requirements:',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildRequirementItem('At least 8 characters long'),
                  _buildRequirementItem('Contains uppercase and lowercase letters'),
                  _buildRequirementItem('Contains at least one number'),
                  _buildRequirementItem('Contains at least one special character'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.gray600,
        ),
      ),
    );
  }
}
