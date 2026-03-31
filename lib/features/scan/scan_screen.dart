import 'package:verd/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:verd/providers/ai_provider.dart';
import 'package:verd/providers/auth_provider.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isInit = false;
  bool _isProcessing = false;
  bool _isCameraInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      // Resume preview when app comes to foreground
      if (_cameraController != null && _isInit) {
        _cameraController!.resumePreview();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Pause preview when app goes to background
      if (_cameraController != null && _isInit) {
        _cameraController!.pausePreview();
      }
    }
  }

  @override
  void didUpdateWidget(ScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _initCamera() async {
    // Guard to prevent multiple initializations
    if (_isCameraInitializing || _isInit) return;

    _isCameraInitializing = true;
    try {
      await Permission.camera.request();
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("Camera Error: No cameras available");
        _isCameraInitializing = false;
        return;
      }

      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInit = true;
        });
        debugPrint("Camera initialized successfully");
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    } finally {
      _isCameraInitializing = false;
    }
  }

  Future<void> _takeScanPicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      AppToast.show(
        context,
        message: AppLocalizations.of(context)!.please_log_in_scanner,
        variant: ToastVariant.error,
      );
      return;
    }

    // Check if guest has reached limit
    final isAnonymous =
        ref.read(firebaseAuthServiceProvider).currentUser?.isAnonymous ?? false;
    if (isAnonymous) {
      final prefs = await SharedPreferences.getInstance();
      final scanCount = prefs.getInt('guest_scan_count') ?? 0;

      if (scanCount >= 3) {
        if (!mounted) return;
        _showLimitReachedDialog();
        return;
      }

      // Increment counter for this successful scan initiation
      await prefs.setInt('guest_scan_count', scanCount + 1);
    }

    setState(() => _isProcessing = true);

    try {
      final xFile = await _cameraController!.takePicture();
      // Freeze the camera preview immediately
      await _cameraController!.pausePreview();

      final imageFile = File(xFile.path);

      final scanId = const Uuid().v4();

      // Route the scan through the AI service (handles online Gemini Extension & offline TFLite)
      final result = await ref
          .read(aiRoutingServiceProvider)
          .routeScan(userId: user.uid, scanId: scanId, image: imageFile);

      if (mounted) {
        AppToast.show(
          context,
          message: AppLocalizations.of(context)!.analysis_complete,
          variant: ToastVariant.info,
        );
        context.pushNamed(
          'scan_result',
          extra: result,
          queryParameters: {'image_url': result['imageUrl'] ?? ''},
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Error analyzing image: $e',
          variant: ToastVariant.error,
        );
        debugPrint('Scan error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        // Resume preview when done or if error occurs
        _cameraController?.resumePreview();
      }
    }
  }

  Future<void> _pickImageAndAnalyze() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      AppToast.show(
        context,
        message: AppLocalizations.of(context)!.please_log_in_scanner,
        variant: ToastVariant.error,
      );
      return;
    }

    // Check if guest has reached limit
    final isAnonymous =
        ref.read(firebaseAuthServiceProvider).currentUser?.isAnonymous ?? false;
    if (isAnonymous) {
      final prefs = await SharedPreferences.getInstance();
      final scanCount = prefs.getInt('guest_scan_count') ?? 0;

      if (scanCount >= 3) {
        if (!mounted) return;
        _showLimitReachedDialog();
        return;
      }
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return; // User canceled picking

      if (isAnonymous) {
        // Increment counter only after successful pick
        final prefs = await SharedPreferences.getInstance();
        final scanCount = prefs.getInt('guest_scan_count') ?? 0;
        await prefs.setInt('guest_scan_count', scanCount + 1);
      }

      setState(() => _isProcessing = true);

      final imageFile = File(image.path);
      final scanId = const Uuid().v4();

      final result = await ref
          .read(aiRoutingServiceProvider)
          .routeScan(userId: user.uid, scanId: scanId, image: imageFile);

      if (mounted) {
        AppToast.show(
          context,
          message: AppLocalizations.of(context)!.analysis_complete,
          variant: ToastVariant.info,
        );
        context.pushNamed(
          'scan_result',
          extra: result,
          queryParameters: {'image_url': result['imageUrl'] ?? ''},
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Error analyzing uploaded image: $e',
          variant: ToastVariant.error,
        );
        debugPrint('Upload scan error: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for camera
      body: Stack(
        children: [
          // ── Camera Background ──
          if (_isInit &&
              _cameraController != null &&
              _cameraController!.value.isInitialized)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // ── UI Overlay ──
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // ── Top Bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCircularIconButton(
                          icon: Icons.history,
                          onPressed: () {
                            context.push('/scan-history');
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Instruction Pill ──
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50), // Green
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.position_crop_instruction,
                      style: AppTypography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ── Viewfinder Area ──
                  const Spacer(),
                  Center(
                    child: Stack(
                      children: [
                        // Main Viewfinder Box
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: MediaQuery.sizeOf(context).width * 0.8,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF4CAF50),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            children: [
                              // Rule of Thirds Grid Lines (Horizontal)
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                              // Rule of Thirds Grid Lines (Vertical)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 1,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  Container(
                                    width: 1,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Corner Brackets ──
                        ..._buildCornerBrackets(
                          MediaQuery.sizeOf(context).width * 0.8,
                          24.0,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // ── Bottom Action Buttons ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxxl * 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircularIconButton(
                          icon: Icons.upload_outlined,
                          onPressed: _pickImageAndAnalyze,
                          size: 64,
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: _isProcessing
                              ? const Padding(
                                  padding: EdgeInsets.all(22.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed: _takeScanPicture,
                                ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        _buildCircularIconButton(
                          icon: Icons.insert_photo_outlined,
                          onPressed: () {
                            context.push('/gallery');
                          },
                          size: 64,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Analyzing Overlay ──
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        AppLocalizations.of(context)!.analyzing_crop,
                        style: AppTypography.h3.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppLocalizations.of(context)!.analyzing_delay_desc,
                        style: AppTypography.body.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF333333), // Darker grey for buttons
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.45),
        onPressed: onPressed,
      ),
    );
  }

  List<Positioned> _buildCornerBrackets(double boxSize, double strokeWidth) {
    const double lineLength = 40.0;
    const double thickness = 4.0;
    const Color color = Colors.white;

    return [
      // Top Left
      Positioned(
        top: -1,
        left: -1,
        child: _buildCorner(
          lineLength,
          thickness,
          color,
          isTop: true,
          isLeft: true,
        ),
      ),
      // Top Right
      Positioned(
        top: -1,
        right: -1,
        child: _buildCorner(
          lineLength,
          thickness,
          color,
          isTop: true,
          isLeft: false,
        ),
      ),
      // Bottom Left
      Positioned(
        bottom: -1,
        left: -1,
        child: _buildCorner(
          lineLength,
          thickness,
          color,
          isTop: false,
          isLeft: true,
        ),
      ),
      // Bottom Right
      Positioned(
        bottom: -1,
        right: -1,
        child: _buildCorner(
          lineLength,
          thickness,
          color,
          isTop: false,
          isLeft: false,
        ),
      ),
    ];
  }

  Widget _buildCorner(
    double length,
    double thickness,
    Color color, {
    required bool isTop,
    required bool isLeft,
  }) {
    // Instead of using complex paths, define an L shape with containers
    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          // Horizontal part
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: length,
              height: thickness,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isTop && isLeft ? thickness : 0),
                  topRight: Radius.circular(isTop && !isLeft ? thickness : 0),
                  bottomLeft: Radius.circular(!isTop && isLeft ? thickness : 0),
                  bottomRight: Radius.circular(
                    !isTop && !isLeft ? thickness : 0,
                  ),
                ),
              ),
            ),
          ),
          // Vertical part
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              height: length,
              width: thickness,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isTop && isLeft ? thickness : 0),
                  topRight: Radius.circular(isTop && !isLeft ? thickness : 0),
                  bottomLeft: Radius.circular(!isTop && isLeft ? thickness : 0),
                  bottomRight: Radius.circular(
                    !isTop && !isLeft ? thickness : 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)?.free_trial_ended ?? 'Free Trial Ended',
          style: AppTypography.h3,
        ),
        content: Text(
          AppLocalizations.of(context)?.free_trial_desc ??
              'You have reached your limit of 3 free scans. Sign up to unlock unlimited scanning and save your farm history!',
          style: AppTypography.body.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/signup');
            },
            child: Text(
              AppLocalizations.of(context)!.sign_up,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
