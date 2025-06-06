import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceManager {
  static const _storage = FlutterSecureStorage();
  static const _deviceKey = 'device_uid';

  static Future<String> getDeviceId() async {
    String? storedId = await _storage.read(key: _deviceKey);
    if (storedId != null) return storedId;

    if (Platform.isAndroid) {
      const androidIdPlugin = AndroidId();

      final String? androidId = await androidIdPlugin.getId();
      return _storeDeviceId(androidId ?? const Uuid().v4());
    } else if (Platform.isIOS) {
      final String? iosId = await _storage.read(key: _deviceKey);
      return _storeDeviceId(iosId ?? const Uuid().v4());
    }
    return _storeDeviceId(const Uuid().v4());
  }

  static Future<String> _storeDeviceId(String id) async {
    await _storage.write(key: _deviceKey, value: id);
    return id;
  }

  static Future<void> clearDeviceId() async {
    await _storage.delete(key: _deviceKey);
  }
}
