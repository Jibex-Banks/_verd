import 'package:verd/l10n/app_localizations.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/data/services/firebase_auth_service.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_button.dart';
import 'package:verd/shared/widgets/app_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _pickedImageFile;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked != null) {
      setState(() => _pickedImageFile = File(picked.path));
    }
  }

  Future<void> _onSignUp() async {
    if (_isLoading || _isGoogleLoading) return;

    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError(AppLocalizations.of(context)!.fill_all_fields);
      return;
    }
    if (password.length < 6) {
      _showError(AppLocalizations.of(context)!.password_too_short);
      return;
    }
    if (password != confirmPassword) {
      _showError(AppLocalizations.of(context)!.passwords_do_not_match);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).register(
            name: name,
            email: email,
            password: password,
          );
      if (_pickedImageFile != null) {
        await ref.read(authNotifierProvider.notifier).updateProfile(photoFile: _pickedImageFile);
      }
      if (mounted) context.go('/permissions');
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.unexpected_error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleSignUp() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null && mounted) {
        ref.invalidate(authStateProvider);
        context.go('/permissions');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.google_sign_up_failed);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _onContinueAsGuest() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).continueAsGuest();
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) _showError('Could not sign in as guest. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    return Scaffold(
      backgroundColor: designTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(AppAssets.logoSvg, height: 48),
                    const SizedBox(height: 24.0),
                    Text(
                      AppLocalizations.of(context)!.create_account,
                      style: designTheme.displayLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: designTheme.textMain,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      AppLocalizations.of(context)!.create_profile,
                      style: designTheme.bodyRegular.copyWith(
                        color: designTheme.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),

              // ── Profile Picture ──
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      _buildAvatarCircle(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: designTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_pickedImageFile != null) ...[
                const SizedBox(height: 16.0),
                Text(
                  AppLocalizations.of(context)!.profile_photo_selected,
                  style: designTheme.bodyRegular.copyWith(color: designTheme.primary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32.0),

              AppTextField(
                label: AppLocalizations.of(context)!.full_name,
                hint: AppLocalizations.of(context)!.full_name,
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24.0),
              
              AppTextField.email(controller: _emailController),
              const SizedBox(height: 24.0),

              AppTextField.password(label: AppLocalizations.of(context)!.password,
                hint: AppLocalizations.of(context)!.password,
                controller: _passwordController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24.0),

              AppTextField.password(label: AppLocalizations.of(context)!.confirm_new_password,
                hint: AppLocalizations.of(context)!.confirm_new_password,
                controller: _confirmPasswordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onSignUp(),
              ),
              const SizedBox(height: 32.0),

              AppButton(
                text: _isLoading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.sign_up.toUpperCase(),
                onPressed: _isLoading || _isGoogleLoading ? null : _onSignUp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24.0),

              // ── OR Divider ──
              Row(
                children: [
                  Expanded(child: Divider(color: designTheme.textDim.withOpacity(0.2), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(AppLocalizations.of(context)!.orDivider, style: designTheme.bodyRegular.copyWith(fontSize: 13, color: designTheme.textDim, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: designTheme.textDim.withOpacity(0.2), thickness: 1)),
                ],
              ),
              const SizedBox(height: 24.0),

              // ── Google Sign Up Button ──
              AppButton(
                text: _isGoogleLoading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.google_sign_in,
                onPressed: _isLoading || _isGoogleLoading ? null : _onGoogleSignUp,
                isLoading: _isGoogleLoading,
                variant: AppButtonVariant.outlined,
                icon: const Icon(Icons.g_mobiledata, size: 32),
              ),
              const SizedBox(height: 16.0),

              // ── Continue as Guest ──
              Center(
                child: TextButton(
                  onPressed: _isLoading || _isGoogleLoading ? null : _onContinueAsGuest,
                  child: Text(
                    'Continue as Guest  →',
                    style: designTheme.bodyRegular.copyWith(
                      fontSize: 14,
                      color: designTheme.textDim,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.already_have_account,
                      style: designTheme.bodyRegular.copyWith(fontSize: 13, color: designTheme.textDim),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        AppLocalizations.of(context)!.login,
                        style: designTheme.bodyRegular.copyWith(
                          fontSize: 14,
                          color: designTheme.primary,
                          fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCircle() {
    const size = 100.0;

    if (_pickedImageFile != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(_pickedImageFile!),
        backgroundColor: AppDesignSystem.of(context).primary.withOpacity(0.2),
      );
    }

    // Fallback: placeholder icon
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppDesignSystem.of(context).primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppDesignSystem.of(context).primary, width: 2),
      ),
      child: Icon(
        Icons.person_add,
        size: 40,
        color: AppDesignSystem.of(context).primary,
      ),
    );
  }
}
