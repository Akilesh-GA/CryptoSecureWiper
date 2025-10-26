import 'file_wipe_utils.dart';

class CryptoEraseUtils {
  /// Simulated Crypto Erase:
  /// Deletes all app-accessible internal files and SD card folder
  static Future<void> wipeAllData({
    String? internalPath,
    String? sdCardPath,
  }) async {
    // Wipe internal app files
    if (internalPath != null) {
      await FileWipeUtils.wipeInternalAppData(internalPath);
    }

    // Wipe SD card folder
    if (sdCardPath != null) {
      await FileWipeUtils.wipeSdCardFolder(sdCardPath);
    }

    // Clear app storage (SharedPreferences, Hive, SQLite)
    await FileWipeUtils.clearAppStorage();
  }
}
