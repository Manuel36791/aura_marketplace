import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../datasources/auth_local_data_source.dart';
import '../models/auth_tokens_model.dart';

@lazySingleton
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._localDataSource, this._dio);

  final AuthLocalDataSource _localDataSource;
  final Dio _dio;

  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isAuthEndpoint =
        path.endsWith('/auth/login') ||
        path.endsWith('/auth/register') ||
        path.endsWith('/auth/refresh');

    if (!isAuthEndpoint && !options.headers.containsKey('Authorization')) {
      final token = await _localDataSource.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isAuthEndpoint =
        path.endsWith('/auth/login') ||
        path.endsWith('/auth/register') ||
        path.endsWith('/auth/refresh');
    final isRetry = err.requestOptions.extra['_retry'] == true;

    if (statusCode != 401 || isAuthEndpoint || isRetry) {
      return handler.next(err);
    }

    err.requestOptions.extra['_retry'] = true;

    try {
      final newAccessToken = await _performTokenRefresh();
      if (newAccessToken == null) {
        return handler.reject(err);
      }

      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      return handler.resolve(response);
    } catch (_) {
      return handler.reject(err);
    }
  }

  Future<String?> _performTokenRefresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final currentRefreshToken = await _localDataSource.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        await _localDataSource.clearTokens();
        completer.complete(null);
        return null;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': currentRefreshToken},
        options: Options(extra: {'_retry': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final newTokens = AuthTokensModel.fromJson(response.data!);
        await _localDataSource.saveTokens(newTokens);
        completer.complete(newTokens.accessToken);
        return newTokens.accessToken;
      } else {
        await _localDataSource.clearTokens();
        completer.complete(null);
        return null;
      }
    } catch (e) {
      await _localDataSource.clearTokens();
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }
}
