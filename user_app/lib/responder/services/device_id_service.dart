import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

<<<<<<< HEAD
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
=======
/// Retrieves a stable, unique device identifier.
///
/// Used as the anonymous reporter ID since the user app has no login/
/// registration flow.  The returned value is:
///   • Android – the `id` field from [AndroidDeviceInfo] (changes on factory
///     reset, but is stable for the life of the install).
///   • iOS – the `identifierForVendor` from [IosDeviceInfo].
///
/// Both values are non-null on real hardware.  A short UUID-style fallback
/// is generated only if the plugin returns an empty string (e.g. simulators
/// in certain edge-cases).
/// Holds the device identifier and human-readable name together.
class DeviceInfo {
  const DeviceInfo({required this.id, required this.name});
  final String id;
  final String name;
}

class DeviceIdService {
  DeviceIdService._();

  static final DeviceIdService instance = DeviceIdService._();

  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  DeviceInfo? _cached;

  /// Returns both the device ID and device name, reading once and caching.
  Future<DeviceInfo> getDeviceInfo() async {
    if (_cached != null) return _cached!;

    String id = '';
    String name = '';

    try {
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        id = info.id;                                    // Build.ID
        name = '${info.brand} ${info.model}'.trim();    // e.g. "Samsung Galaxy A54"
      } else if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        id = info.identifierForVendor ?? '';
        name = info.utsname.machine;                    // e.g. "iPhone14,3"
      }
    } catch (e) {
      debugPrint('[DeviceIdService] getDeviceInfo error: $e');
    }

    if (id.isEmpty) id = 'device_${DateTime.now().millisecondsSinceEpoch}';
    if (name.isEmpty) name = 'Unknown Device';

    _cached = DeviceInfo(id: id, name: name);
    return _cached!;
  }

  /// Convenience wrapper – returns only the ID.
  Future<String> getDeviceId() async => (await getDeviceInfo()).id;
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
}
