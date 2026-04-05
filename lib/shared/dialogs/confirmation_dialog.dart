import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONFIRMATION DIALOG
// Use for destructive or irreversible actions (delete, logout, etc.)
// and for general confirm/cancel prompts.
//
// Usage:
//   final confirmed = await ConfirmationDialog.show(context,
//     title: 'Delete Scan?',
//     message: 'This cannot be undone.',
//     isDangerous: true,
//   );
//   if (confirmed == true) doDelete();
// ═══════════════════════════════════════════════════════════════════════════

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDangerous;
  final Widget? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDangerous = false,
    this.icon,
  });

  // ── Static show helpers ────────────────────────────────────────────────

  /// Generic confirm/cancel dialog. Returns true if confirmed.
  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
        bool isDangerous = false,
        Widget? icon,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDangerous: isDangerous,
        icon: icon,
      ),
    );
  }

  /// Shortcut for delete confirmations.
  static Future<bool?> delete(
      BuildContext context, {
        required String itemName,
        String? customMessage,
      }) {
    return show(
      context,
      title: 'Delete $itemName?',
      message: customMessage ??
          'This action cannot be undone. "$itemName" will be permanently deleted.',
      confirmLabel: AppLocalizations.of(context)!.delete,
      cancelLabel: AppLocalizations.of(context)!.cancel,
      isDangerous: true,
      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 32),
    );
  }

  /// Shortcut for logout confirmation.
  static Future<bool?> logout(BuildContext context) {
    return show(
      context,
      title: AppLocalizations.of(context)!.logout_q,
      message: AppLocalizations.of(context)!.logout_desc,
      confirmLabel: AppLocalizations.of(context)!.logout,
      cancelLabel: AppLocalizations.of(context)!.stay,
      isDangerous: false,
      icon: Icon(Icons.logout_outlined,
          color: Theme.of(context).extension<AppDesignSystem>()?.textDim, size: 32),
    );
  }

  /// Shortcut for discard unsaved changes.
  static Future<bool?> discardChanges(BuildContext context) {
    return show(
      context,
      title: AppLocalizations.of(context)!.discard_changes_q,
      message: AppLocalizations.of(context)!.discard_changes_desc,
      confirmLabel: AppLocalizations.of(context)!.discard,
      cancelLabel: AppLocalizations.of(context)!.keep_editing,
      isDangerous: true,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    final sw = MediaQuery.sizeOf(context).width;
    final confirmColor = isDangerous ? Theme.of(context).colorScheme.error : designTheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0)), // Use a generous radius for premium feel
      backgroundColor: designTheme.surface,
      // Constrain width on tablets
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sw < 600 ? sw * 0.88 : 400),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              if (icon != null) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDangerous
                         ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                        : designTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: icon),
                ),
                const SizedBox(height: 16.0),
              ],

              // Title
              Text(
                title,
                style: designTheme.titleLarge.copyWith(
                  color: designTheme.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 22.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),

              // Message
              Text(
                message,
                style: designTheme.bodyRegular.copyWith(
                  color: designTheme.textDim,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),

              // Buttons
              Row(children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: designTheme.textMain,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                          color: designTheme.textMain.withOpacity(0.1), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12.0)),
                    ),
                    child: Text(cancelLabel,
                        style: designTheme.bodyRegular.copyWith(
                          fontWeight: FontWeight.w600,
                          color: designTheme.textMain,
                        )),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12.0)),
                    ),
                    child: Text(confirmLabel,
                        style: designTheme.bodyRegular.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}