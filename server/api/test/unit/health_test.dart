import 'dart:convert';

import 'package:api_server/app.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('GET /health returns ok payload', () async {
    final handler = buildApp();
    final response = await handler(
      Request('GET', Uri.parse('http://localhost/health')),
    );

    expect(response.statusCode, 200);
    expect(response.headers['content-type'], 'application/json');

    final body = await response.readAsString();
    final payload = jsonDecode(body) as Map<String, dynamic>;

    expect(payload, <String, dynamic>{
      'status': 'ok',
      'version': '0.1.0',
    });
  });

  test('unknown route returns not found', () async {
    final handler = buildApp();
    final response = await handler(
      Request('GET', Uri.parse('http://localhost/unknown')),
    );

    expect(response.statusCode, 404);
  });
}
