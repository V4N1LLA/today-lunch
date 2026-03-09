import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router()
    ..get('/health', (Request request) {
      return Response.ok(
        '{"status":"ok","version":"0.1.0"}',
        headers: {'content-type': 'application/json'},
      );
    });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final port = int.tryParse(Platform.environment['SERVER_PORT'] ?? '') ?? 8080;
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln('API server listening on port ${server.port}');
}
