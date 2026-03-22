import 'dart:developer' as dev;

class AppLogger {
  AppLogger._();

  static void info(String message) {
    dev.log(message, name: 'OptiZenqor');
  }

  static void error(String message, Object error) {
    dev.log('$message: $error', name: 'OptiZenqor', level: 1000);
  }
}
