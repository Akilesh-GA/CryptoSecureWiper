import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class FileWipeUtils {
  /// Delete all files in app-accessible internal folder
  static Future<void> wipeInternalAppData(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Delete app folder on SD card
  static Future<void> wipeSdCardFolder(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Clear all app storage
  static Future<void> clearAppStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // TODO: Clear Hive/SQLite if used
  }
}
