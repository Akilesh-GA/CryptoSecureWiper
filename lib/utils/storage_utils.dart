import 'package:get_storage_info/get_storage_info.dart';

class StorageUtils {
  /// Returns storage details in GB
  static Future<Map<String, double>> getStorageStats() async {
    int total = await GetStorageInfo.getStorageTotalSpace ?? 0;
    int free = await GetStorageInfo.getStorageFreeSpace ?? 0;
    int used = total - free;

    return {
      'total': total / (1024 * 1024 * 1024), // GB
      'used': used / (1024 * 1024 * 1024),
      'free': free / (1024 * 1024 * 1024),
    };
  }
}
