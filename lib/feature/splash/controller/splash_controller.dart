import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/data/models/user_model.dart';
import '../../../core/permissions/startup_permission_service.dart';
import '../../auth/repository/auth_repository.dart';
import '../../../app_route/route_names.dart';
import '../model/splash_state_model.dart';

class SplashController {
  SplashController({
    AuthRepository? authRepository,
    StartupPermissionService? permissionService,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _permissionService =
           permissionService ?? const StartupPermissionService();

  final AuthRepository _authRepository;
  final StartupPermissionService _permissionService;
  SplashStateModel state = const SplashStateModel();
  static Future<String>? _routeResolutionFuture;
  static const Duration _debugBootstrapTimeout = Duration(seconds: 2);
  static const Duration _releaseBootstrapTimeout = Duration(seconds: 5);

  Duration get _bootstrapTimeout =>
      kDebugMode ? _debugBootstrapTimeout : _releaseBootstrapTimeout;

  Future<String> resolveInitialRoute({bool force = false}) {
    if (!force) {
      final Future<String>? inFlight = _routeResolutionFuture;
      if (inFlight != null) {
        return inFlight;
      }
    }

    final Future<String> future = _performResolveInitialRoute();
    _routeResolutionFuture = future;
    return future.whenComplete(() {
      if (identical(_routeResolutionFuture, future)) {
        _routeResolutionFuture = null;
      }
    });
  }

  Future<String> _performResolveInitialRoute() async {
    state = state.copyWith(status: SplashStatus.bootstrapping);
    final Future<bool> sessionFuture = _safeBool(
      () => _authRepository.hasSession(),
      fallback: false,
      label: 'hasSession',
    );
    final List<Object?> bootstrapResults = await Future.wait<Object?>(
      <Future<Object?>>[sessionFuture],
    );
    final bool hasSession = bootstrapResults[0] as bool;

    state = state.copyWith(status: SplashStatus.ready);
    if (!hasSession) {
      return RouteNames.login;
    }
    final UserModel? user = await _authRepository.currentUser();
    return user?.isAccountSuspended == true
        ? RouteNames.accountSuspended
        : RouteNames.shell;
  }

  Future<void> bootstrap(BuildContext context) async {
    final bool permissionsReady = await _ensureStartupPermissions(context);
    if (!permissionsReady || !context.mounted) {
      return;
    }

    final Future<String> routeFuture = resolveInitialRoute().timeout(
      _bootstrapTimeout,
      onTimeout: () {
        if (kDebugMode) {
          debugPrint(
            '[SplashController] bootstrap timed out after $_bootstrapTimeout',
          );
        }
        return RouteNames.login;
      },
    );
    if (!context.mounted) {
      return;
    }
    final String nextRoute = await routeFuture;
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  Future<bool> _ensureStartupPermissions(BuildContext context) async {
    StartupPermissionResult result = await _permissionService
        .requestRequiredPermissions();

    while (!result.canEnterApp) {
      if (!context.mounted) {
        return false;
      }

      final _PermissionDialogAction?
      action = await showDialog<_PermissionDialogAction>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Allow permissions to continue'),
            content: Text(
              'OptiZenqor Social needs these permissions before the app opens:\n\n'
              '${result.deniedLabels}\n\n'
              'Tap Try again to show permission prompts, or open settings if the phone blocks the prompt.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(_PermissionDialogAction.openSettings),
                child: const Text('Open settings'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(_PermissionDialogAction.tryAgain),
                child: const Text('Try again'),
              ),
            ],
          );
        },
      );

      if (!context.mounted) {
        return false;
      }
      if (action == _PermissionDialogAction.openSettings) {
        await _permissionService.openSettings();
      }

      result = await _permissionService.requestRequiredPermissions();
    }

    return true;
  }

  Future<bool> _safeBool(
    Future<bool> Function() action, {
    required bool fallback,
    required String label,
  }) async {
    try {
      return await action().timeout(
        _bootstrapTimeout,
        onTimeout: () {
          if (kDebugMode) {
            debugPrint(
              '[SplashController] $label timed out after $_bootstrapTimeout',
            );
          }
          return fallback;
        },
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[SplashController] $label failed: $error');
      }
      return fallback;
    }
  }
}

enum _PermissionDialogAction { tryAgain, openSettings }
