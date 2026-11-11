import 'package:core_di/core_di.dart';
import 'package:flutter_test/flutter_test.dart';

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
    const config = AppConfig(flavorName: 'prod', baseUrl: 'https://example.test');

    expect(config.enableLogging, isFalse);
  });
}
