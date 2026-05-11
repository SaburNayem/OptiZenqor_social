import 'package:flutter/material.dart';

import '../../app_route/route_names.dart';
import '../data/service/app_session_event_service.dart';
import '../data/service/network_status_service.dart';
import '../navigation/app_navigator.dart';

class AppStateGuard extends StatefulWidget {
  const AppStateGuard({required this.child, super.key});

  final Widget child;

  @override
  State<AppStateGuard> createState() => _AppStateGuardState();
}

class _AppStateGuardState extends State<AppStateGuard> {
  bool _offlineDialogVisible = false;
  bool _redirectingToLogin = false;

  @override
  void initState() {
    super.initState();
    NetworkStatusService.instance.isOffline.addListener(
      _handleConnectivityChanged,
    );
    AppSessionEventService.instance.sessionExpiredVersion.addListener(
      _handleSessionExpired,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _handleConnectivityChanged();
    });
  }

  @override
  void dispose() {
    NetworkStatusService.instance.isOffline.removeListener(
      _handleConnectivityChanged,
    );
    AppSessionEventService.instance.sessionExpiredVersion.removeListener(
      _handleSessionExpired,
    );
    super.dispose();
  }

  void _handleConnectivityChanged() {
    if (!mounted) {
      return;
    }
    if (NetworkStatusService.instance.isOffline.value) {
      _showOfflineDialog();
      return;
    }
    _dismissOfflineDialogIfNeeded();
  }

  void _showOfflineDialog() {
    if (_offlineDialogVisible) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _offlineDialogVisible) {
        return;
      }
      final BuildContext? navigatorContext = AppNavigator.context;
      if (navigatorContext == null) {
        return;
      }
      _offlineDialogVisible = true;
      showDialog<void>(
        context: navigatorContext,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('No internet connection'),
            content: const Text(
              'Please turn on your internet connection to continue using the app.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (!NetworkStatusService.instance.isOffline.value) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          );
        },
      ).whenComplete(() {
        _offlineDialogVisible = false;
        if (mounted && NetworkStatusService.instance.isOffline.value) {
          _showOfflineDialog();
        }
      });
    });
  }

  void _dismissOfflineDialogIfNeeded() {
    if (!_offlineDialogVisible) {
      return;
    }
    final NavigatorState? navigator = AppNavigator.navigatorKey.currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
    }
  }

  void _handleSessionExpired() {
    if (!mounted || _redirectingToLogin) {
      return;
    }
    _redirectingToLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _redirectingToLogin = false;
        return;
      }
      _dismissOfflineDialogIfNeeded();
      await AppNavigator.offAllNamed(RouteNames.login);
      AppNavigator.showSnackBar(
        title: 'Session expired',
        message: 'Please log in again.',
      );
      _redirectingToLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
