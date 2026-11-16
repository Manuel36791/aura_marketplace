import 'package:injectable/injectable.dart';

import '../app_config.dart';

const staging = Environment('stg');

@module
abstract class AppConfigModule {
  @dev
  @singleton
  AppConfig devConfig() => const AppConfig(
    flavorName: 'dev',
    baseUrl: 'https://dev.api.aura-marketplace.example',
    enableLogging: true,
  );

  @staging
  @singleton
  AppConfig stagingConfig() => const AppConfig(
    flavorName: 'stg',
    baseUrl: 'https://staging.api.aura-marketplace.example',
    enableLogging: true,
  );

  @prod
  @singleton
  AppConfig prodConfig() => const AppConfig(
    flavorName: 'prod',
    baseUrl: 'https://api.aura-marketplace.example',
  );
}
