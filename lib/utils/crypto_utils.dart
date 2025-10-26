import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

class CryptoUtils {
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }
}
