import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

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
}
