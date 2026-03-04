import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/features/auth/forgot_password_screen.dart';
import 'package:verd/features/auth/login_screen.dart';
import 'package:verd/features/auth/signup_screen.dart';
import 'package:verd/features/main/main_screen.dart';
import 'package:verd/features/onboarding/onboarding_screen.dart';
import 'package:verd/features/permissions/permissions_screen.dart';
import 'package:verd/features/splash/splash_screen.dart';
import 'package:verd/features/utility/design_system_preview.dart';

// Profile screens
import 'package:verd/features/profile/about_screen.dart';
import 'package:verd/features/profile/change_password_screen.dart';
import 'package:verd/features/profile/language_screen.dart';
import 'package:verd/features/profile/notification_settings_screen.dart';
import 'package:verd/features/profile/help_support_screen.dart';
import 'package:verd/features/profile/edit_profile_screen.dart';

// Scan screens
import 'package:verd/features/scan/gallery_screen.dart';
import 'package:verd/features/scan/scan_history_screen.dart';

// Learning screens
import 'package:verd/features/learning/learning_center_screen.dart';
import 'package:verd/features/learning/article_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/permissions',
      name: 'permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change_password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/language',
      name: 'language',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/help-support',
      name: 'help_support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'edit_profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/gallery',
      name: 'gallery',
      builder: (context, state) => const GalleryScreen(),
    ),
    GoRoute(
      path: '/scan-history',
      name: 'scan_history',
      builder: (context, state) => const ScanHistoryScreen(),
    ),
    GoRoute(
      path: '/learning-center',
      name: 'learning_center',
      builder: (context, state) => const LearningCenterScreen(),
    ),
    GoRoute(
      path: '/article/:id',
      name: 'article',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ArticleDetailScreen(articleId: id);
      },
    ),
    if (kDebugMode)
      GoRoute(
        path: '/preview',
        builder: (_, __) => const DesignSystemPreview(),
      ),
  ],
);