import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../app_config.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AppConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    if (config.enableLogging) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
    return dio;
  }
}
