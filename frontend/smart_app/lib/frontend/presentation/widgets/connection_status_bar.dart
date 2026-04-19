import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/connectivity_service.dart';

/// A slim status banner that sits just under the OS status bar.
///
/// - Hidden when [ConnectionStatus.online]
/// - Red when [ConnectionStatus.offline]
/// - Amber/animated when [ConnectionStatus.reconnecting]
///
/// Place at the top of an [AppShell] / [MaterialApp.builder] so it appears
/// above every screen in the app.
class ConnectionStatusBar extends StatefulWidget {
  const ConnectionStatusBar({super.key});

  @override
  State<ConnectionStatusBar> createState() => _ConnectionStatusBarState();
}

class _ConnectionStatusBarState extends State<ConnectionStatusBar> {
  late StreamSubscription<ConnectionStatus> _sub;
  ConnectionStatus _status = ConnectionStatus.online;

  // True for a few seconds after going back online so we can
  // briefly show a green "Back online" confirmation.
  bool _justRecovered = false;
  Timer? _recoveryTimer;

  @override
  void initState() {
    super.initState();
    ConnectivityService.instance.start();
    _status = ConnectivityService.instance.current;
    _sub = ConnectivityService.instance.stream.listen(_onStatus);
  }

  void _onStatus(ConnectionStatus s) {
    if (!mounted) return;
    final wasOffline = _status != ConnectionStatus.online;
    setState(() => _status = s);

    if (s == ConnectionStatus.online && wasOffline) {
      setState(() => _justRecovered = true);
      _recoveryTimer?.cancel();
      _recoveryTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _justRecovered = false);
      });
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _recoveryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible =
        _status != ConnectionStatus.online || _justRecovered;

    final config = _styleFor(_status, _justRecovered);

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: visible
          ? Material(
              color: config.color,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_status == ConnectionStatus.reconnecting)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Icon(config.icon, color: Colors.white, size: 16),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        config.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppTheme.fontSizeS,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  _BannerStyle _styleFor(ConnectionStatus status, bool recovered) {
    if (recovered) {
      return const _BannerStyle(
        color: AppTheme.successColor,
        icon: Icons.wifi_rounded,
        label: 'Back online',
      );
    }
    switch (status) {
      case ConnectionStatus.offline:
        return const _BannerStyle(
          color: AppTheme.errorColor,
          icon: Icons.wifi_off_rounded,
          label: 'No internet connection',
        );
      case ConnectionStatus.reconnecting:
        return const _BannerStyle(
          color: AppTheme.warningColor,
          icon: Icons.refresh_rounded,
          label: 'Reconnecting…',
        );
      case ConnectionStatus.online:
        return const _BannerStyle(
          color: AppTheme.successColor,
          icon: Icons.wifi_rounded,
          label: 'Online',
        );
    }
  }
}

class _BannerStyle {
  final Color color;
  final IconData icon;
  final String label;
  const _BannerStyle({
    required this.color,
    required this.icon,
    required this.label,
  });
}
