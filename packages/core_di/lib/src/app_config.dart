class AppConfig {
  const AppConfig({
    required this.flavorName,
    required this.baseUrl,
    this.enableLogging = false,
  });

  final String flavorName;
  final String baseUrl;
  final bool enableLogging;
}
