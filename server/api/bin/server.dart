import 'dart:io';

import 'package:api_server/app.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  final port = int.tryParse(Platform.environment['SERVER_PORT'] ?? '') ?? 8080;
  final server = await shelf_io.serve(buildApp(), InternetAddress.anyIPv4, port);
  stdout.writeln('API server listening on port ${server.port}');
}
