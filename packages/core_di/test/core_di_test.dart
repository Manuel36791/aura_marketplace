import 'package:core_di/core_di.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;

void main() {
  test('AppConfig keeps the values it is created with', () {
    const config = AppConfig(
      flavorName: 'dev',
      baseUrl: 'https://example.test',
      enableLogging: true,
    );

    expect(config.flavorName, 'dev');
    expect(config.baseUrl, 'https://example.test');
    expect(config.enableLogging, isTrue);
  });

  test('AppConfig has logging disabled by default', () {
    const config = AppConfig(
      flavorName: 'prod',
      baseUrl: 'https://example.test',
    );

    expect(config.enableLogging, isFalse);
  });

  for (final env in ['dev', 'stg', 'prod']) {
    test('core_di registers AppConfig and Dio for $env', () async {
      final getIt = GetIt.asNewInstance();
      await CoreDiPackageModule().init(GetItHelper(getIt, env));

      final config = getIt<AppConfig>();
      expect(config.flavorName, env);
      expect(getIt<Dio>().options.baseUrl, config.baseUrl);
    });
  }
}
