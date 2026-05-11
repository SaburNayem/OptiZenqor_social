import 'package:flutter/foundation.dart';

class AppSessionEventService {
  AppSessionEventService._();

  static final AppSessionEventService instance = AppSessionEventService._();

  final ValueNotifier<int> sessionExpiredVersion = ValueNotifier<int>(0);

  void notifySessionExpired() {
    sessionExpiredVersion.value++;
  }
}
