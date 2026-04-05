import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/l10n/app_localizations.dart';
import 'package:verd/providers/ai_provider.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:verd/data/services/ai_routing_service.dart';
import 'package:verd/data/services/firebase_auth_service.dart';

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
    final designTheme = AppDesignSystem.of(context);

    return Scaffold(
      backgroundColor: designTheme.background,
      appBar: AppBar(
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: designTheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.chevron_left, color: designTheme.textMain),
                onPressed: () => context.canPop() ? context.pop() : null,
              ),
            ),
          ),
        ),
        title: Text(
          'Gallery Scan',
          style: designTheme.titleLarge.copyWith(
            color: designTheme.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: designTheme.background,
        elevation: 0,
      ),
      body: _buildBody(designTheme),
    );
  }

  Widget _buildBody(AppDesignSystem designTheme) {
    switch (_permissionStatus) {
      case _GalleryPermissionStatus.checking:
        return Center(child: CircularProgressIndicator(color: designTheme.primary));

      case _GalleryPermissionStatus.granted:
        return _buildPickerPrompt(designTheme);

      case _GalleryPermissionStatus.denied:
        return _buildPermissionState(
          designTheme: designTheme,
          icon: Icons.photo_library_outlined,
          title: 'Gallery Access Needed',
          subtitle: 'Verd needs access to your photo library so you can select crop images for scanning.',
          buttonLabel: 'Grant Permission',
          onTap: _requestPermission,
        );

      case _GalleryPermissionStatus.permanentlyDenied:
        return _buildPermissionState(
          designTheme: designTheme,
          icon: Icons.no_photography_outlined,
          title: 'Permission Denied',
          subtitle: 'Photo library access has been permanently denied. Please open Settings and grant it manually.',
          buttonLabel: 'Open Settings',
          onTap: openAppSettings,
        );
    }
  }

  /// The main prompt shown when permission is granted.
  Widget _buildPickerPrompt(AppDesignSystem dt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration circle
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: dt.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_photo_alternate_rounded, size: 64, color: dt.primary),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Pick a Crop Photo',
              style: dt.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: dt.textMain,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Choose a clear, well-lit photo of a leaf or crop from your photo library. Verd will analyse it for diseases and health status.',
              style: dt.bodyRegular.copyWith(
                color: dt.textDim,
                height: 1.6,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48.0),

            // Pick button
            _isProcessing
                ? Column(
                    children: [
                      CircularProgressIndicator(color: dt.primary),
                      const SizedBox(height: 16.0),
                      Text(
                        'Analysing crop…',
                        style: dt.bodyRegular.copyWith(color: dt.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dt.primary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: dt.primary.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _pickAndScan,
                      icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                      label: Text(
                        'Choose from Gallery',
                        style: dt.bodyRegular.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

            const SizedBox(height: 32.0),

            // Tips section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dt.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: dt.textMain.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                    _buildTipRow(
                      dt,
                      icon: Icons.light_mode_rounded,
                      label: 'Good lighting improves accuracy',
                    ),
                    const SizedBox(height: 12.0),
                    _buildTipRow(
                      dt,
                      icon: Icons.center_focus_strong_rounded,
                      label: 'Focus on a single leaf or area',
                    ),
                    const SizedBox(height: 12.0),
                    _buildTipRow(
                      dt,
                      icon: Icons.image_search_rounded,
                      label: 'Clear, close-up photos work best',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(AppDesignSystem dt, {required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: 20, color: dt.primary),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            label,
            style: dt.bodyRegular.copyWith(
              color: dt.textDim,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  /// Generic permission-denied / settings prompt.
  Widget _buildPermissionState({
    required AppDesignSystem designTheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: designTheme.semanticError.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: designTheme.semanticError),
            ),
            const SizedBox(height: 32.0),
            Text(
              title,
              style: designTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: designTheme.textMain,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              subtitle,
              style: designTheme.bodyRegular.copyWith(
                color: designTheme.textDim,
                height: 1.6,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: designTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onTap,
                child: Text(
                  buttonLabel,
                  style: designTheme.bodyRegular.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
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
    final designTheme = AppDesignSystem.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: designTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: designTheme.semanticWarning),
            const SizedBox(width: 12),
            Text(
              'Limit Reached',
              style: designTheme.titleLarge.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'You have reached your limit of 3 free scans. Sign up for unlimited scanning and save your farm history!',
          style: designTheme.bodyRegular.copyWith(
            color: designTheme.textDim,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Later',
              style: designTheme.bodyRegular.copyWith(
                color: designTheme.textDim,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: designTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/signup');
            },
            child: Text(
              'Sign Up',
              style: designTheme.bodyRegular.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
