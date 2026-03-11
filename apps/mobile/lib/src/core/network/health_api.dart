import 'package:dio/dio.dart';

import 'app_api_config.dart';
import 'health_status.dart';

abstract interface class HealthApi {
  Future<HealthStatus> fetchHealthStatus();
}

class DioHealthApi implements HealthApi {
  DioHealthApi({
    Dio? dio,
    AppApiConfig? config,
  })  : _config = config ?? AppApiConfig.fromEnvironment(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: (config ?? AppApiConfig.fromEnvironment()).baseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  final AppApiConfig _config;
  final Dio _dio;

  @override
  Future<HealthStatus> fetchHealthStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${_config.baseUrl}/health',
    );

    final payload = response.data;
    if (payload == null) {
      throw const FormatException('Health response payload is empty.');
    }

    return HealthStatus.fromJson(payload);
  }
}
