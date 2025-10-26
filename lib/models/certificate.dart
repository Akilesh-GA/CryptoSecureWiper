class Certificate {
  final String deviceId;
  final String wipeMethod;
  final String timestamp;
  final String hash;

  Certificate({
    required this.deviceId,
    required this.wipeMethod,
    required this.timestamp,
    required this.hash,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'wipeMethod': wipeMethod,
    'timestamp': timestamp,
    'hash': hash,
  };
}
