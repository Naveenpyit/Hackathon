import 'dart:async';
import 'dart:io';

/// Connection state stream — pings a known host every few seconds
/// to detect online/offline transitions. Pure Dart, no plugin needed.
enum ConnectionStatus { online, offline, reconnecting }

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  static const Duration _checkInterval = Duration(seconds: 5);
  static const Duration _lookupTimeout = Duration(seconds: 3);
  static const String _probeHost = 'google.com';

  final StreamController<ConnectionStatus> _controller =
      StreamController<ConnectionStatus>.broadcast();
  Timer? _timer;
  ConnectionStatus _last = ConnectionStatus.online;
  bool _started = false;

  /// Listen to connection state changes.
  Stream<ConnectionStatus> get stream => _controller.stream;

  /// Last known status.
  ConnectionStatus get current => _last;

  /// Start periodic checks. Idempotent — safe to call multiple times.
  void start() {
    if (_started) return;
    _started = true;
    // Initial check
    _check();
    _timer = Timer.periodic(_checkInterval, (_) => _check());
  }

  /// Manually force a check (e.g. on retry button).
  Future<void> recheck() async {
    if (_last == ConnectionStatus.offline) {
      _emit(ConnectionStatus.reconnecting);
    }
    await _check();
  }

  Future<void> _check() async {
    try {
      final result = await InternetAddress.lookup(_probeHost)
          .timeout(_lookupTimeout);
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        _emit(ConnectionStatus.online);
        return;
      }
      _emit(ConnectionStatus.offline);
    } on SocketException {
      _emit(ConnectionStatus.offline);
    } on TimeoutException {
      _emit(ConnectionStatus.offline);
    } catch (_) {
      _emit(ConnectionStatus.offline);
    }
  }

  void _emit(ConnectionStatus status) {
    if (status == _last) return;
    _last = status;
    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _started = false;
    _controller.close();
  }
}
