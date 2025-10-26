class WipeLog {
  final String deviceId;
  final String method;
  final String status;

  WipeLog({required this.deviceId, required this.method, required this.status});

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'method': method,
    'status': status,
  };
}
