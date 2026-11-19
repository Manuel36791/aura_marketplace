import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FakeAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;

    if (path.endsWith('/auth/login')) {
      final data = _parseData(options.data);
      final email = data['email'] as String? ?? '';
      final password = data['password'] as String? ?? '';

      if (password == 'wrongpassword' || password == 'invalid') {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'error': 'Invalid email or password'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'user': {
              'id': 'usr_aura_1',
              'email': email.isEmpty ? 'user@aura.example' : email,
              'name': email.contains('@')
                  ? email.split('@').first
                  : 'Aura Shopper',
              'avatarUrl': null,
            },
            'tokens': {
              'accessToken': 'valid-access-token',
              'refreshToken': 'valid-refresh-token',
            },
          },
        ),
      );
      return;
    }

    if (path.endsWith('/auth/register')) {
      final data = _parseData(options.data);
      final email = data['email'] as String? ?? '';
      final name = data['name'] as String? ?? 'Aura Shopper';

      if (email == 'existing@aura.example') {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 409,
              data: {'error': 'Email already in use'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 201,
          data: {
            'user': {
              'id': 'usr_aura_2',
              'email': email,
              'name': name,
              'avatarUrl': null,
            },
            'tokens': {
              'accessToken': 'valid-access-token',
              'refreshToken': 'valid-refresh-token',
            },
          },
        ),
      );
      return;
    }

    if (path.endsWith('/auth/refresh')) {
      final data = _parseData(options.data);
      final refreshToken = data['refreshToken'] as String? ?? '';

      if (refreshToken == 'invalid-refresh-token' || refreshToken.isEmpty) {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'error': 'Invalid refresh token'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'accessToken': 'new-valid-access-token',
            'refreshToken': 'new-valid-refresh-token',
          },
        ),
      );
      return;
    }

    if (path.endsWith('/auth/me')) {
      final authHeader = options.headers['Authorization'] as String?;

      if (authHeader == 'Bearer expired-access-token' ||
          authHeader == null ||
          !authHeader.startsWith('Bearer ')) {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'error': 'Token expired'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'id': 'usr_aura_1',
            'email': 'user@aura.example',
            'name': 'Aura Shopper',
            'avatarUrl': null,
          },
        ),
      );
      return;
    }

    if (path.endsWith('/auth/logout')) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true},
        ),
      );
      return;
    }

    handler.next(options);
  }

  Map<String, dynamic> _parseData(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    }
    return {};
  }
}
