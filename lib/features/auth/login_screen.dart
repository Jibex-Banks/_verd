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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_isLoading || _isGoogleLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(AppLocalizations.of(context)!.fill_all_fields);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).login(email, password);
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.unexpected_error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleSignIn() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null && mounted) {
        // Refresh the provider state to show the new user
        ref.invalidate(authStateProvider);
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 FirebaseAuthException during Google Sign-In: ${e.code} - ${e.message}');
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e, st) {
      debugPrint('🔥 Exact Google Sign-In Exception: $e');
      debugPrint('🔥 Stacktrace: $st');
      if (mounted) _showError('Google Sign-In failed: $e');
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

  Future<void> _onSendEmailLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError(AppLocalizations.of(context)!.enter_email_link_error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).sendSignInLink(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.sign_in_link_sent(email)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.send_link_failed);
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

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    return Scaffold(
      backgroundColor: designTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SvgPicture.asset(AppAssets.logoSvg, height: 64),
                const SizedBox(height: 32.0),

                Text(
                  AppLocalizations.of(context)!.login_welcome,
                  style: designTheme.displayLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: designTheme.textMain,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  AppLocalizations.of(context)!.login,
                  style: designTheme.bodyRegular.copyWith(
                    color: designTheme.textDim,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48.0),

                AppTextField.email(controller: _emailController),
                const SizedBox(height: 24.0),
                AppTextField.password(controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onLogin(),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _onSendEmailLink,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.email_me_link,
                        style: designTheme.bodyRegular.copyWith(
                          fontSize: 13,
                          color: designTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.forgot_password,
                        style: designTheme.bodyRegular.copyWith(
                          fontSize: 13,
                          color: designTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),

                AppButton(
                  text: _isLoading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.sign_in.toUpperCase(),
                  onPressed: _isLoading || _isGoogleLoading ? null : _onLogin,
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

                // ── Google Sign In Button ──
                AppButton(
                  text: _isGoogleLoading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.google_sign_in,
                  onPressed: _isLoading || _isGoogleLoading ? null : _onGoogleSignIn,
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
                      AppLocalizations.of(context)!.dont_have_account,
                      style: designTheme.bodyRegular.copyWith(
                        fontSize: 13,
                        color: designTheme.textDim,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Text(
                        AppLocalizations.of(context)!.sign_up,
                        style: designTheme.bodyRegular.copyWith(
                          fontSize: 14,
                          color: designTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
