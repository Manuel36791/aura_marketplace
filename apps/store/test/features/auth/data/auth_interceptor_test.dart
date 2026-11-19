import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:store/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:store/features/auth/data/models/auth_tokens_model.dart';
import 'package:store/features/auth/domain/entities/auth_tokens.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockDio mockDio;
  late AuthInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(const AuthTokens(accessToken: '', refreshToken: ''));
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  setUp(() {
    mockLocalDataSource = MockAuthLocalDataSource();
    mockDio = MockDio();
    interceptor = AuthInterceptor(mockLocalDataSource, mockDio);
  });

  group('AuthInterceptor', () {
    group('onRequest', () {
      test(
        'attaches Bearer token to outgoing request when token exists',
        () async {
          when(() => mockLocalDataSource.getAccessToken())
              .thenAnswer((_) async => 'stored-access-token');

          final options = RequestOptions(path: '/api/cart');
          final handler = RequestInterceptorHandler();

          await interceptor.onRequest(options, handler);

          expect(
            options.headers['Authorization'],
            equals('Bearer stored-access-token'),
          );
        },
      );

      test('does not attach token on public auth endpoints', () async {
        when(() => mockLocalDataSource.getAccessToken())
            .thenAnswer((_) async => 'stored-access-token');

        final options = RequestOptions(path: '/auth/login');
        final handler = RequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(options.headers.containsKey('Authorization'), isFalse);
      });
    });

    group('onError & refresh-and-retry', () {
      test(
        'on 401: refreshes token, updates header, and retries original request',
        () async {
          when(() => mockLocalDataSource.getRefreshToken())
              .thenAnswer((_) async => 'valid-refresh-token');

          when(() => mockLocalDataSource.saveTokens(any()))
              .thenAnswer((_) async {});

          when(
            () => mockDio.post<Map<String, dynamic>>(
              '/auth/refresh',
              data: {'refreshToken': 'valid-refresh-token'},
              options: any(named: 'options'),
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: '/auth/refresh'),
              statusCode: 200,
              data: {
                'accessToken': 'new-access-token',
                'refreshToken': 'new-refresh-token',
              },
            ),
          );

          final originalRequest = RequestOptions(
            path: '/api/profile',
            headers: {'Authorization': 'Bearer expired-token'},
          );

          when(() => mockDio.fetch<dynamic>(any())).thenAnswer(
            (_) async => Response(
              requestOptions: originalRequest,
              statusCode: 200,
              data: {'success': true},
            ),
          );

          final err = DioException(
            requestOptions: originalRequest,
            response: Response(
              requestOptions: originalRequest,
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          );

          Response<dynamic>? resolvedResponse;

          // Using custom completion tracking
          await interceptor.onError(
            err,
            _TestErrorInterceptorHandler(
              onResolve: (r) => resolvedResponse = r,
            ),
          );

          expect(resolvedResponse, isNotNull);
          expect((resolvedResponse as Response).statusCode, equals(200));
          expect(
            originalRequest.headers['Authorization'],
            equals('Bearer new-access-token'),
          );
          expect(originalRequest.extra['_retry'], isTrue);

          verify(
            () => mockLocalDataSource.saveTokens(
              const AuthTokensModel(
                accessToken: 'new-access-token',
                refreshToken: 'new-refresh-token',
              ),
            ),
          ).called(1);
        },
      );

      test(
        'guards against infinite loops when request is already retried',
        () async {
          final retriedRequest = RequestOptions(
            path: '/api/profile',
            extra: {'_retry': true},
          );

          final err = DioException(
            requestOptions: retriedRequest,
            response: Response(requestOptions: retriedRequest, statusCode: 401),
            type: DioExceptionType.badResponse,
          );

          var rejected = false;

          await interceptor.onError(
            err,
            _TestErrorInterceptorHandler(onNext: (_) => rejected = true),
          );

          expect(rejected, isTrue);
          verifyNever(() => mockLocalDataSource.getRefreshToken());
        },
      );

      test('clears tokens and rejects when refresh fails', () async {
        when(() => mockLocalDataSource.getRefreshToken())
            .thenAnswer((_) async => 'invalid-refresh-token');

        when(
          () => mockDio.post<Map<String, dynamic>>(
            '/auth/refresh',
            data: {'refreshToken': 'invalid-refresh-token'},
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/refresh'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        when(() => mockLocalDataSource.clearTokens()).thenAnswer((_) async {});

        final originalRequest = RequestOptions(path: '/api/orders');
        final err = DioException(
          requestOptions: originalRequest,
          response: Response(requestOptions: originalRequest, statusCode: 401),
          type: DioExceptionType.badResponse,
        );

        var rejected = false;

        await interceptor.onError(
          err,
          _TestErrorInterceptorHandler(onReject: (_) => rejected = true),
        );

        expect(rejected, isTrue);
        verify(() => mockLocalDataSource.clearTokens()).called(1);
      });
    });
  });
}

class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  _TestErrorInterceptorHandler({this.onResolve, this.onReject, this.onNext});

  final void Function(Response response)? onResolve;
  final void Function(DioException err)? onReject;
  final void Function(DioException err)? onNext;

  @override
  void resolve(Response response, [bool callCycle = false]) {
    onResolve?.call(response);
  }

  @override
  void reject(DioException err, [bool callCycle = false]) {
    onReject?.call(err);
  }

  @override
  void next(DioException err) {
    onNext?.call(err);
  }
}
