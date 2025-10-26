// File: utils/flash_utils.dart

import 'storage_utils.dart';
import 'sdcard_utils.dart';

class FlashUtils {
  /// Returns the total combined storage (Internal + SD Card) stats in GB.
  static Future<Map<String, double>> getCombinedStorageStats() async {
    // Get Internal Storage Stats
    final internalStats = await StorageUtils.getStorageStats();

    // Get SD Card Stats (safely, as it might fail)
    Map<String, dynamic> sdStats;
    try {
      sdStats = await SdCardUtils.getSdCardStats();
    } catch (e) {
      // If SD card fails to load, treat it as zero contribution
      sdStats = {"total": 0.0, "used": 0.0, "free": 0.0, "found": false};
    }

    // Convert SD card stats to double for aggregation (already in GB if sdcard_utils did its job)
    double sdTotal = (sdStats['total'] as double?) ?? 0.0;
    double sdUsed = (sdStats['used'] as double?) ?? 0.0;

    // Aggregate data
    double total = internalStats['total']! + sdTotal;
    double used = internalStats['used']! + sdUsed;
    double free = total - used;

    // Ensure total is at least 1 for safe use in graph widgets
    if (total < 1) total = 1;

    return {
      'total': total,
      'used': used,
      'free': free,
    };
  }
}