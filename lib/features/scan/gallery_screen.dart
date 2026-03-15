import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/providers/ai_provider.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

enum _GalleryPermissionStatus { checking, granted, denied, permanentlyDenied }

class _GalleryScreenState extends ConsumerState<GalleryScreen>
    with WidgetsBindingObserver {
  _GalleryPermissionStatus _permissionStatus = _GalleryPermissionStatus.checking;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check permissions when the user comes back from Settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  /// Determines the current photo-library permission state.
  Future<void> _checkPermission() async {
    setState(() => _permissionStatus = _GalleryPermissionStatus.checking);

    // On Android 13+ READ_MEDIA_IMAGES; on older Android / iOS READ_PHOTOS / PHOTOS
    final status = await _photoPermission().status;

    if (!mounted) return;
    if (status.isGranted || status.isLimited) {
      setState(() => _permissionStatus = _GalleryPermissionStatus.granted);
    } else if (status.isPermanentlyDenied) {
      setState(() => _permissionStatus = _GalleryPermissionStatus.permanentlyDenied);
    } else {
      // not determined or denied — request now
      await _requestPermission();
    }
  }

  /// Returns the correct [Permission] for the running platform/OS version.
  Permission _photoPermission() {
    if (Platform.isAndroid) {
      // Android 13 (API 33) and above use READ_MEDIA_IMAGES
      return Permission.photos;
    }
    return Permission.photos;
  }

  Future<void> _requestPermission() async {
    final result = await _photoPermission().request();
    if (!mounted) return;

    if (result.isGranted || result.isLimited) {
      setState(() => _permissionStatus = _GalleryPermissionStatus.granted);
      // Auto-open picker now that we have permission
      await _pickAndScan();
    } else if (result.isPermanentlyDenied) {
      setState(() => _permissionStatus = _GalleryPermissionStatus.permanentlyDenied);
    } else {
      setState(() => _permissionStatus = _GalleryPermissionStatus.denied);
    }
  }

  Future<void> _pickAndScan() async {
    // 1. Auth guard
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (!mounted) return;
      AppToast.show(context, message: 'Please log in to scan crops.', variant: ToastVariant.error);
      return;
    }

    // 2. Guest scan-limit guard
    final isAnonymous = ref.read(firebaseAuthServiceProvider).currentUser?.isAnonymous ?? false;
    if (isAnonymous) {
      final prefs = await SharedPreferences.getInstance();
      final scanCount = prefs.getInt('guest_scan_count') ?? 0;
      if (scanCount >= 3) {
        if (!mounted) return;
        _showLimitReachedDialog();
        return;
      }
    }

    // 3. Pick image
    final ImagePicker picker = ImagePicker();
    XFile? picked;
    try {
      picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: 'Failed to open gallery: $e', variant: ToastVariant.error);
      }
      return;
    }

    if (picked == null) return; // User cancelled

    // 4. Increment guest counter after a successful pick
    if (isAnonymous) {
      final prefs = await SharedPreferences.getInstance();
      final scanCount = prefs.getInt('guest_scan_count') ?? 0;
      await prefs.setInt('guest_scan_count', scanCount + 1);
    }

    // 5. Analyse
    setState(() => _isProcessing = true);
    try {
      final imageFile = File(picked.path);
      final scanId = const Uuid().v4();

      final result = await ref.read(aiRoutingServiceProvider).routeScan(
        userId: user.uid,
        scanId: scanId,
        image: imageFile,
      );

      if (mounted) {
        AppToast.show(context, message: 'Analysis complete!', variant: ToastVariant.info);
        context.pushNamed(
          'scan_result',
          extra: result,
          queryParameters: {'image_url': result['imageUrl'] ?? ''},
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: 'Error analysing image: $e', variant: ToastVariant.error);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
                onPressed: () => context.canPop() ? context.pop() : null,
              ),
            ),
          ),
        ),
        title: Text(
          'Gallery',
          style: AppTypography.h3.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_permissionStatus) {
      case _GalleryPermissionStatus.checking:
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));

      case _GalleryPermissionStatus.granted:
        return _buildPickerPrompt(theme);

      case _GalleryPermissionStatus.denied:
        return _buildPermissionState(
          theme: theme,
          icon: Icons.photo_library_outlined,
          title: 'Gallery Access Needed',
          subtitle: 'Verd needs access to your photo library so you can select crop images for scanning.',
          buttonLabel: 'Grant Permission',
          onTap: _requestPermission,
        );

      case _GalleryPermissionStatus.permanentlyDenied:
        return _buildPermissionState(
          theme: theme,
          icon: Icons.no_photography_outlined,
          title: 'Permission Denied',
          subtitle:
              'Photo library access has been permanently denied. Please open Settings and grant "Photos" or "Media" permission to Verd.',
          buttonLabel: 'Open Settings',
          onTap: openAppSettings,
        );
    }
  }

  /// The main prompt shown when permission is granted.
  Widget _buildPickerPrompt(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_photo_alternate_outlined, size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Pick a Crop Photo',
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Choose a clear, well-lit photo of a leaf or crop from your photo library. Verd will analyse it for diseases and health status.',
              style: AppTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Pick button
            _isProcessing
                ? Column(
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Analysing crop…',
                        style: AppTypography.body.copyWith(color: AppColors.primary),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _pickAndScan,
                      icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                      label: Text(
                        'Choose from Gallery',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

            const SizedBox(height: AppSpacing.xl),

            // Tips row
            _buildTipRow(
              theme,
              icon: Icons.light_mode_outlined,
              label: 'Good lighting improves accuracy',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildTipRow(
              theme,
              icon: Icons.center_focus_strong_outlined,
              label: 'Focus on a single leaf or area',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildTipRow(
              theme,
              icon: Icons.image_search_outlined,
              label: 'Clear, close-up photos work best',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(ThemeData theme, {required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// Generic permission-denied / settings prompt.
  Widget _buildPermissionState({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: theme.colorScheme.error),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              style: AppTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onTap,
                child: Text(
                  buttonLabel,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Free Trial Ended', style: AppTypography.h3),
        content: Text(
          'You have reached your limit of 3 free scans. Sign up for unlimited scanning and save your farm history!',
          style: AppTypography.body.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/signup');
            },
            child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
