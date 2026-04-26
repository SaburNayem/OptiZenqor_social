import 'package:flutter/services.dart';

class DeviceSettingsService {
  const DeviceSettingsService._();

  static const MethodChannel _channel = MethodChannel(
    'optizenqor_social/device_settings',
  );

  static Future<bool> openNetworkSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openNetworkSettings') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
