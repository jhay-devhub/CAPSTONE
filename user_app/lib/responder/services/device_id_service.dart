import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Service that retrieves and caches the unique hardware device ID.
///
/// On Android this returns [AndroidDeviceInfo.id] (Android ID / SSAID).
/// On iOS this returns [IosDeviceInfo.identifierForVendor].
///
/// The value is cached after the first fetch so subsequent calls are instant.
class DeviceIdService {
  DeviceIdService._();
  static final DeviceIdService instance = DeviceIdService._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedDeviceId;
  String? _cachedDeviceName;

  /// Returns the unique device identifier.
  /// Throws on unsupported platforms.
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        _cachedDeviceId = android.id; // e.g. "QGB6BA55W45LMFRO"
      } else if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        _cachedDeviceId = ios.identifierForVendor ?? 'unknown_ios';
      } else {
        _cachedDeviceId = 'unsupported_platform';
      }
    } catch (e) {
      debugPrint('[DeviceIdService] Error fetching device ID: $e');
      _cachedDeviceId = 'unknown_device';
    }

    debugPrint('[DeviceIdService] Device ID: $_cachedDeviceId');
    return _cachedDeviceId!;
  }

  /// Returns a human-readable device name (e.g. "Samsung SM-A127F").
  Future<String> getDeviceName() async {
    if (_cachedDeviceName != null) return _cachedDeviceName!;

    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        final brand = android.brand;
        final model = android.model;
        _cachedDeviceName = '${brand[0].toUpperCase()}${brand.substring(1)} $model';
      } else if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        _cachedDeviceName = ios.utsname.machine;
      } else {
        _cachedDeviceName = 'Unknown Device';
      }
    } catch (e) {
      debugPrint('[DeviceIdService] Error fetching device name: $e');
      _cachedDeviceName = 'Unknown Device';
    }

    return _cachedDeviceName!;
  }
}
