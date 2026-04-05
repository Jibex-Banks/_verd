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
import 'package:verd/core/theme/app_design_system.dart';
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
    final designTheme = AppDesignSystem.of(context);
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for camera stays as it's the standard for camera UIs
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
            Center(
              child: CircularProgressIndicator(color: designTheme.primary),
            ),

          // ── UI Overlay ──
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // ── Top Bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCircularIconButton(
                          designTheme: designTheme,
                          icon: Icons.history,
                          onPressed: () {
                            context.push('/scan-history');
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Instruction Pill ──
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: designTheme.primary,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: designTheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.position_crop_instruction,
                      style: designTheme.bodyRegular.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
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
                              color: designTheme.primary.withOpacity(0.5),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(28),
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
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.15),
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
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                  Container(
                                    width: 1,
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Corner Brackets ──
                        ..._buildCornerBrackets(
                          designTheme,
                          MediaQuery.sizeOf(context).width * 0.8,
                          2.0,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // ── Bottom Action Buttons ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircularIconButton(
                          designTheme: designTheme,
                          icon: Icons.upload_outlined,
                          onPressed: _pickImageAndAnalyze,
                          size: 64,
                        ),
                        const SizedBox(width: 32.0),
                        GestureDetector(
                          onTap: _isProcessing ? null : _takeScanPicture,
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: designTheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: designTheme.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 4,
                              ),
                            ),
                            child: _isProcessing
                                ? const Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 32.0),
                        _buildCircularIconButton(
                          designTheme: designTheme,
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
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: designTheme.primary),
                      const SizedBox(height: 24.0),
                      Text(
                        AppLocalizations.of(context)!.analyzing_crop,
                        style: designTheme.titleLarge.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        AppLocalizations.of(context)!.analyzing_delay_desc,
                        style: designTheme.bodyRegular.copyWith(
                          color: Colors.white.withOpacity(0.7),
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
    required AppDesignSystem designTheme,
    required IconData icon,
    required VoidCallback onPressed,
    double size = 52,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.45),
        onPressed: onPressed,
      ),
    );
  }

  List<Positioned> _buildCornerBrackets(AppDesignSystem designTheme, double boxSize, double strokeWidth) {
    const double lineLength = 32.0;
    const double thickness = 4.0;
    final Color color = designTheme.primary;

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
    final designTheme = AppDesignSystem.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: designTheme.surface,
        shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(designTheme.radiusStandard),
            ),
        title: Text(
          AppLocalizations.of(context)?.free_trial_ended ?? 'Free Trial Ended',
          style: designTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        content: Text(
          AppLocalizations.of(context)?.free_trial_desc ??
              'You have reached your limit of 3 free scans. Sign up to unlock unlimited scanning and save your farm history!',
          style: designTheme.bodyRegular.copyWith(
                color: designTheme.textDim,
                height: 1.5,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: designTheme.textDim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                  backgroundColor: designTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/signup');
            },
            child: Text(
              AppLocalizations.of(context)!.sign_up,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
