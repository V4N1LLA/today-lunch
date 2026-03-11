import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/core/network/health_status.dart';

void main() {
  test('parses valid health payload', () {
    final status = HealthStatus.fromJson(<String, dynamic>{
      'status': 'ok',
      'version': '0.1.0',
    });

    expect(status.status, 'ok');
    expect(status.version, '0.1.0');
  });

  test('throws for invalid payload', () {
    expect(
      () => HealthStatus.fromJson(<String, dynamic>{'status': 'ok'}),
      throwsFormatException,
    );
  });
}
