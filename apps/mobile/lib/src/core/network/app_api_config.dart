class AppApiConfig {
  const AppApiConfig({required this.baseUrl});

  factory AppApiConfig.fromEnvironment() {
    return const AppApiConfig(
      baseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080',
      ),
    );
  }

  final String baseUrl;
}
