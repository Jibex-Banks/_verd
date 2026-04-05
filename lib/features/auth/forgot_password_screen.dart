import 'package:verd/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/data/services/firebase_auth_service.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_button.dart';
import 'package:verd/shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onResetPassword() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError(AppLocalizations.of(context)!.enter_email_error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).resetPassword(email);
      if (mounted) {
        setState(() => _emailSent = true);
        _showSuccess(AppLocalizations.of(context)!.password_reset_sent);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.unexpected_error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Bar (Back Button) ──
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back, color: designTheme.textMain, size: 20),
                  label: Text(
                    AppLocalizations.of(context)!.back,
                    style: designTheme.bodyRegular.copyWith(
                      color: designTheme.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Logo ──
              SvgPicture.asset(
                AppAssets.logoSvg,
                height: 64,
              ),
              const SizedBox(height: 32.0),

              // ── Title & Subtitle ──
              Text(
                AppLocalizations.of(context)!.forgot_password,
                style: designTheme.displayLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: designTheme.textMain,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _emailSent
                      ? AppLocalizations.of(context)!.password_reset_sent_desc
                      : AppLocalizations.of(context)!.password_reset_instructions,
                  style: designTheme.bodyRegular.copyWith(
                    color: _emailSent ? designTheme.accentGreen : designTheme.textDim,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // ── Form ──
              if (!_emailSent) ...[
                AppTextField.email(controller: _emailController,
                ),
                const SizedBox(height: 32),

                // ── Reset Button ──
                AppButton(
                  text: _isLoading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.forgot_password.toUpperCase(),
                  onPressed: _isLoading ? null : _onResetPassword,
                  isLoading: _isLoading,
                ),
              ] else ...[
                // ── Success State — show return to login ──
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: designTheme.accentGreen,
                ),
                const SizedBox(height: 24.0),
                AppButton(
                  text: AppLocalizations.of(context)!.back_to_login,
                  onPressed: () => context.pop(),
                ),
              ],
              const SizedBox(height: 32),

              // ── Back to Login Link ──
              if (!_emailSent)
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.back,
                      style: designTheme.bodyRegular.copyWith(
                        color: designTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
