import 'package:verd/l10n/app_localizations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONNECTIVITY BANNER
// Auto-shows when offline, auto-hides when back online.
// Wrap your Scaffold body with ConnectivityBanner.
// ═══════════════════════════════════════════════════════════════════════════

/// Wrap the Scaffold body with this widget.
/// It listens to [ConnectivityNotifier] and shows/hides automatically.
///
/// Usage:
///   body: ConnectivityBanner(
///     child: YourScreenContent(),
///   )
///
/// To trigger manually (e.g. from a Riverpod provider watching connectivity):
///   ConnectivityNotifier.of(context).setOffline(true);
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final bool? forceOffline; // override for testing in preview

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.forceOffline,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _heightFactor;

  // In production, swap this with a stream from connectivity_plus package:
  // StreamSubscription<ConnectivityResult>? _sub;
  bool _isOffline = false;
  bool _justReconnected = false;
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightFactor =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    if (widget.forceOffline != null) {
      _setStatus(widget.forceOffline!);
    }

    // ── Production wiring (uncomment when connectivity_plus is added) ──
    // _sub = Connectivity().onConnectivityChanged.listen((result) {
    //   _setStatus(result == ConnectivityResult.none);
    // });
  }

  void _setStatus(bool offline) {
    if (!mounted) return;
    if (!offline && _isOffline) {
      // Just came back online — show "Back online" briefly
      setState(() {
        _isOffline = false;
        _justReconnected = true;
      });
      _ctrl.forward();
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _ctrl.reverse().then((_) {
            if (mounted) setState(() => _justReconnected = false);
          });
        }
      });
    } else if (offline && !_isOffline) {
      setState(() {
        _isOffline = true;
        _justReconnected = false;
      });
      _reconnectTimer?.cancel();
      _ctrl.forward();
    }
  }

  @override
  void didUpdateWidget(ConnectivityBanner old) {
    super.didUpdateWidget(old);
    if (widget.forceOffline != null &&
        widget.forceOffline != old.forceOffline) {
      _setStatus(widget.forceOffline!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _reconnectTimer?.cancel();
    // _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner slides down from top
        AnimatedBuilder(
          animation: _heightFactor,
          builder: (_, child) => ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
          child: Builder(
            builder: (context) {
              final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
              return _justReconnected
                  ? _BannerContent(
                      message: AppLocalizations.of(context)!.back_online,
                      icon: Icons.wifi,
                      backgroundColor: designTheme.accentGreen,
                    )
                  : _BannerContent(
                      message: AppLocalizations.of(context)!.no_internet,
                      icon: Icons.wifi_off_outlined,
                      backgroundColor: designTheme.surface,
                      trailing: TextButton(
                        onPressed: () {
                          // Trigger manual retry logic here
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: designTheme.textMain,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0),
                          minimumSize: Size(designTheme.touchTargetMin, designTheme.touchTargetMin),
                        ),
                        child: Text(AppLocalizations.of(context)!.retry,
                            style: designTheme.bodyRegular.copyWith(fontWeight: FontWeight.w500, color: designTheme.textDim)),
                      ),
                    );
            }
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _BannerContent extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Widget? trailing;

  const _BannerContent({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final designTheme = Theme.of(context).extension<AppDesignSystem>()!;
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 10.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(icon, color: designTheme.textMain, size: 16),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                message,
                style: designTheme.bodyRegular.copyWith(
                  color: designTheme.textMain,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0, // mapping bodySmall size
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
