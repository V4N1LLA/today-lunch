import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_api_config.dart';
import '../../../core/network/health_api.dart';
import '../../../core/network/health_status.dart';

final appApiConfigProvider = Provider<AppApiConfig>((ref) {
  return AppApiConfig.fromEnvironment();
});

final healthApiProvider = Provider<HealthApi>((ref) {
  final config = ref.watch(appApiConfigProvider);
  return DioHealthApi(config: config);
});

final healthStatusProvider = FutureProvider<HealthStatus>((ref) async {
  final api = ref.watch(healthApiProvider);
  return api.fetchHealthStatus();
});
