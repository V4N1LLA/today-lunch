import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../core/app_metadata.dart';
import 'health_payload.dart';

void registerHealthRoutes(Router router) {
  router.get('/health', (Request request) {
    final payload = createHealthPayload(version: appVersion);

    return Response.ok(
      jsonEncode(payload),
      headers: const {'content-type': 'application/json'},
    );
  });
}
