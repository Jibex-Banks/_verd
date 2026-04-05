import 'package:verd/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verd/core/theme/app_design_system.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_text_field.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:verd/shared/dialogs/confirmation_dialog.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;

  File? _pickedImageFile;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill from cached user — runs once
    if (!_initialized) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _nameController.text = user.displayName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
        _locationController.text = user.farmLocation ?? '';
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
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

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      AppToast.show(context, message: AppLocalizations.of(context)!.name_empty_error, variant: ToastVariant.error);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final currentUser = ref.read(currentUserProvider);
      await ref.read(authNotifierProvider.notifier).updateProfile(
        name: name != currentUser?.displayName ? name : null,
        phone: phone.isNotEmpty ? phone : null,
        location: location.isNotEmpty ? location : null,
        photoFile: _pickedImageFile,
      );
      if (mounted) {
        AppToast.show(context, message: AppLocalizations.of(context)!.profile_update_success, variant: ToastVariant.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: AppLocalizations.of(context)!.profile_update_error, variant: ToastVariant.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleCancel() async {
    final discard = await ConfirmationDialog.discardChanges(context);
    if (discard == true && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final designTheme = AppDesignSystem.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: designTheme.background,
      appBar: AppBar(
        backgroundColor: designTheme.background,
        elevation: 0,
        leadingWidth: 90,
        leading: TextButton(
          onPressed: _handleCancel,
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: designTheme.bodyRegular.copyWith(
              color: designTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppLocalizations.of(context)!.edit_profile,
            style: designTheme.titleLarge.copyWith(
              color: designTheme.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          _isSaving
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, 
                      color: designTheme.primary
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _handleSave,
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: designTheme.bodyRegular.copyWith(
                      color: designTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),

            // ── Profile Picture ──
            Center(
              child: GestureDetector(
                onTap: _pickedImageFile == null && !_isSaving ? _pickImage : null,
                child: Stack(
                  children: [
                    _buildAvatarCircle(user?.photoUrl, user?.displayName),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: designTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: designTheme.surface, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_pickedImageFile != null) ...[
              const SizedBox(height: 8.0),
              Text(
                AppLocalizations.of(context)!.new_photo_selected,
                style: designTheme.bodyRegular.copyWith(
                  color: designTheme.primary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 40.0),

            // ── Edit Fields ──
            AppTextField(
              label: AppLocalizations.of(context)!.full_name,
              hint: AppLocalizations.of(context)!.full_name_hint,
              controller: _nameController,
            ),
            const SizedBox(height: 24.0),
            AppTextField.email(label: AppLocalizations.of(context)!.email,
              hint: AppLocalizations.of(context)!.email_hint,
              controller: _emailController,
              enabled: false, // Email cannot be changed here
            ),
            const SizedBox(height: 24.0),
            AppTextField(
              label: AppLocalizations.of(context)!.phone_number,
              hint: AppLocalizations.of(context)!.phone_hint,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24.0),
            AppTextField(
              label: AppLocalizations.of(context)!.farm_location,
              hint: AppLocalizations.of(context)!.farm_location_hint,
              controller: _locationController,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(String? photoUrl, String? name) {
    const size = 100.0;
    final designTheme = AppDesignSystem.of(context);

    if (_pickedImageFile != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(_pickedImageFile!),
      );
    }

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: designTheme.primary.withOpacity(0.2),
      );
    }

    // Fallback: initials
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: designTheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: designTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
