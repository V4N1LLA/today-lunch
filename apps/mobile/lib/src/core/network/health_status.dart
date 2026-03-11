class HealthStatus {
  const HealthStatus({
    required this.status,
    required this.version,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final version = json['version'];

    if (status is! String || version is! String) {
      throw const FormatException('Invalid health payload.');
    }

    return HealthStatus(status: status, version: version);
  }

  final String status;
  final String version;
}
