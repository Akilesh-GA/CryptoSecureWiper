import '../models/wipe_log.dart';
import '../models/certificate.dart';
import '../utils/crypto_utils.dart';

class CertificateService {
  static Certificate generateCertificate(WipeLog log) {
    final hash = CryptoUtils.sha256Hash(log.toJson().toString()); // fixed method

    return Certificate(
      deviceId: log.deviceId,
      wipeMethod: log.method,
      timestamp: DateTime.now().toIso8601String(),
      hash: hash,
    );
  }
}
