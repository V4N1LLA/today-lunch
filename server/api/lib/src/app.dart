import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'features/health/health_routes.dart';

Handler buildApp() {
  final router = Router();
  registerHealthRoutes(router);

  return Pipeline().addMiddleware(logRequests()).addHandler(router.call);
}
