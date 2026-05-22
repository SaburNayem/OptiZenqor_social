import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../firebase_masseging/notification_permission.dart';

enum StartupPermissionType {
  notifications,
  camera,
  microphone,
  mediaLibrary,
  location,
}

class StartupPermissionItem {
  const StartupPermissionItem({
    required this.type,
    required this.granted,
    this.permanentlyDenied = false,
  });

  final StartupPermissionType type;
  final bool granted;
  final bool permanentlyDenied;

  String get label {
    switch (type) {
      case StartupPermissionType.notifications:
        return 'Notifications';
      case StartupPermissionType.camera:
        return 'Camera';
      case StartupPermissionType.microphone:
        return 'Microphone';
      case StartupPermissionType.mediaLibrary:
        return 'Photos and videos';
      case StartupPermissionType.location:
        return 'Location';
    }
  }
}

class StartupPermissionResult {
  const StartupPermissionResult(this.items);

  final List<StartupPermissionItem> items;

  bool get canEnterApp => deniedItems.isEmpty;

  bool get hasPermanentDenials =>
      deniedItems.any((StartupPermissionItem item) => item.permanentlyDenied);

  List<StartupPermissionItem> get deniedItems => items
      .where((StartupPermissionItem item) => !item.granted)
      .toList(growable: false);

  String get deniedLabels => deniedItems
      .map((StartupPermissionItem item) => '- ${item.label}')
      .join('\n');
}

class StartupPermissionService {
  const StartupPermissionService();

  Future<StartupPermissionResult> requestRequiredPermissions() async {
    final List<StartupPermissionItem> items = <StartupPermissionItem>[
      StartupPermissionItem(
        type: StartupPermissionType.notifications,
        granted: await requestNotificationPermission(),
      ),
    ];

    if (!kIsWeb) {
      items.addAll(<StartupPermissionItem>[
        await _requestPermission(
          type: StartupPermissionType.camera,
          permission: Permission.camera,
        ),
        await _requestPermission(
          type: StartupPermissionType.microphone,
          permission: Permission.microphone,
        ),
        await _requestPermission(
          type: StartupPermissionType.location,
          permission: Permission.locationWhenInUse,
        ),
        await _requestMediaLibraryPermission(),
      ]);
    }

    return StartupPermissionResult(items);
  }

  Future<bool> openSettings() => openAppSettings();

  Future<StartupPermissionItem> _requestPermission({
    required StartupPermissionType type,
    required Permission permission,
  }) async {
    PermissionStatus status = await permission.status;
    if (!_isGranted(status)) {
      status = await permission.request();
    }

    return StartupPermissionItem(
      type: type,
      granted: _isGranted(status),
      permanentlyDenied: status.isPermanentlyDenied || status.isRestricted,
    );
  }

  Future<StartupPermissionItem> _requestMediaLibraryPermission() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    final bool granted =
        permission.isAuth || permission == PermissionState.limited;

    return StartupPermissionItem(
      type: StartupPermissionType.mediaLibrary,
      granted: granted,
    );
  }

  bool _isGranted(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }
}
