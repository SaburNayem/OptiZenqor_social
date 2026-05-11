import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NetworkStatusService {
  NetworkStatusService._({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  static final NetworkStatusService instance = NetworkStatusService._();

  final Connectivity _connectivity;
  final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;
  bool _retryScheduled = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    try {
      final List<ConnectivityResult> initialResults = await _connectivity
          .checkConnectivity();
      _updateStatus(initialResults);
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
      );
    } on MissingPluginException catch (error) {
      _started = false;
      if (kDebugMode) {
        debugPrint(
          '[NetworkStatusService] connectivity_plus is not registered yet: $error',
        );
      }
      _scheduleRetry();
    } on PlatformException catch (error) {
      _started = false;
      if (kDebugMode) {
        debugPrint(
          '[NetworkStatusService] connectivity check failed: ${error.message ?? error.code}',
        );
      }
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_retryScheduled) {
      return;
    }
    _retryScheduled = true;
    Future<void>.delayed(const Duration(seconds: 2), () async {
      _retryScheduled = false;
      if (_started) {
        return;
      }
      await start();
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final bool offline = !results.any(
      (ConnectivityResult result) => result != ConnectivityResult.none,
    );
    if (isOffline.value == offline) {
      return;
    }
    isOffline.value = offline;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
    _retryScheduled = false;
  }
}
