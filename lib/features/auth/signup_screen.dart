import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_button.dart';
import 'package:verd/shared/widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    // TODO: Implement actual signup logic
    context.go('/permissions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Section ──
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      AppAssets.logoSvg,
                      height: 48,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Join VERD',
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Create your account to get started',
                      style: AppTypography.body.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Profile Picture ──
              Center(
                child: Column(
                  children: [
                    Text(
                      'Profile Picture (Optional)',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement image picker logic
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Form Fields ──
              AppTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              AppTextField.email(
                controller: _emailController,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField.password(
                label: 'Password',
                hint: 'Create a password',
                controller: _passwordController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField.password(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onSignUp(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Terms & Conditions ──
              Text.rich(
                TextSpan(
                  text: 'By signing up, you agree to our ',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.gray600),
                  children: [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                    ),
                    const TextSpan(text: ' and\n'),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Sign Up Button ──
              AppButton(
                text: 'SIGN UP',
                onPressed: _onSignUp,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Login Prompt ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(), // Pop goes back to Login
                    child: Text(
                      'Login',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
