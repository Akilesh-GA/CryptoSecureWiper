import 'package:flutter/services.dart';

class WipeChannel {
  static const platform = MethodChannel('com.example.securewipe/wipe');

  static Future<bool> performCryptoErase() async {
    try {
      final result = await platform.invokeMethod('performCryptoErase');
      return result == "success";
    } catch (e) {
      return false;
    }
  }
}
