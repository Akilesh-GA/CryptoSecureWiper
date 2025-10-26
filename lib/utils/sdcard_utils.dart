import 'package:flutter/services.dart';

class SdCardUtils {
  static const MethodChannel _channel =
  MethodChannel('com.example.securewipe/sdcard_utils');

  /// Fetch real SD card stats
  static Future<Map<String, dynamic>> getSdCardStats() async {
    try {
      final result = await _channel.invokeMethod('getSdCardStats');

      return {
        'total': (result['total'] as num?)?.toDouble() ?? 0.0,
        'used': (result['used'] as num?)?.toDouble() ?? 0.0,
        'free': (result['free'] as num?)?.toDouble() ?? 0.0,
        'path': result['path']?.toString() ?? '',
        'found': result['found'] ?? false,
      };
    } on PlatformException {
      return {
        'total': 0.0,
        'used': 0.0,
        'free': 0.0,
        'path': '',
        'found': false,
      };
    }
  }
}
