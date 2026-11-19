import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:store/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:store/features/auth/data/models/auth_response_model.dart';
import 'package:store/features/auth/data/models/auth_tokens_model.dart';
import 'package:store/features/auth/data/models/user_model.dart';
import 'package:store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:store/features/auth/domain/entities/auth_tokens.dart';
import 'package:store/features/auth/domain/entities/user.dart';
import 'package:store/features/auth/domain/failures/auth_failure.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepositoryImpl repository;

  const testUserModel = UserModel(
    id: 'usr_1',
    email: 'user@aura.example',
    name: 'Aura Shopper',
  );

  const testTokensModel = AuthTokensModel(
    accessToken: 'access-123',
    refreshToken: 'refresh-123',
  );

  const testAuthResponse = AuthResponseModel(
    user: testUserModel,
    tokens: testTokensModel,
  );

  const testUser = User(
    id: 'usr_1',
    email: 'user@aura.example',
    name: 'Aura Shopper',
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      test(
        'saves tokens, saves user, emits user, and returns user on success',
        () async {
          when(
            () => mockRemoteDataSource.login(
              email: 'user@aura.example',
              password: 'password123',
            ),
          ).thenAnswer((_) async => testAuthResponse);

          when(() => mockLocalDataSource.saveTokens(testTokensModel))
              .thenAnswer((_) async {});
          when(() => mockLocalDataSource.saveUser(testUserModel))
              .thenAnswer((_) async {});

          final result = await repository.login(
            email: 'user@aura.example',
            password: 'password123',
          );

          expect(result, equals(testUser));
          verify(
            () => mockRemoteDataSource.login(
              email: 'user@aura.example',
              password: 'password123',
            ),
          ).called(1);
          verify(() => mockLocalDataSource.saveTokens(testTokensModel))
              .called(1);
          verify(() => mockLocalDataSource.saveUser(testUserModel)).called(1);
        },
      );

      test(
        'maps DioException with status 401 to InvalidCredentialsFailure',
        () async {
          when(
            () => mockRemoteDataSource.login(
              email: 'user@aura.example',
              password: 'wrong',
            ),
          ).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/auth/login'),
              response: Response(
                requestOptions: RequestOptions(path: '/auth/login'),
                statusCode: 401,
                data: {'error': 'Invalid credentials'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );

          expect(
            () =>
                repository.login(email: 'user@aura.example', password: 'wrong'),
            throwsA(isA<InvalidCredentialsFailure>()),
          );
        },
      );
    });

    group('register', () {
      test('registers and saves tokens locally', () async {
        when(
          () => mockRemoteDataSource.register(
            name: 'Aura Shopper',
            email: 'user@aura.example',
            password: 'password123',
          ),
        ).thenAnswer((_) async => testAuthResponse);

        when(() => mockLocalDataSource.saveTokens(testTokensModel))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveUser(testUserModel))
            .thenAnswer((_) async {});

        final result = await repository.register(
          name: 'Aura Shopper',
          email: 'user@aura.example',
          password: 'password123',
        );

        expect(result, equals(testUser));
      });

      test('maps 409 status to EmailAlreadyInUseFailure', () async {
        when(
          () => mockRemoteDataSource.register(
            name: 'Aura Shopper',
            email: 'existing@aura.example',
            password: 'password123',
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/register'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/register'),
              statusCode: 409,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => repository.register(
            name: 'Aura Shopper',
            email: 'existing@aura.example',
            password: 'password123',
          ),
          throwsA(isA<EmailAlreadyInUseFailure>()),
        );
      });
    });

    group('logout', () {
      test('clears local tokens and user', () async {
        when(() => mockRemoteDataSource.logout()).thenAnswer((_) async {});
        when(() => mockLocalDataSource.clearAll()).thenAnswer((_) async {});

        await repository.logout();

        verify(() => mockRemoteDataSource.logout()).called(1);
        verify(() => mockLocalDataSource.clearAll()).called(1);
      });
    });

    group('restoreSession', () {
      test('returns null when no stored tokens', () async {
        when(() => mockLocalDataSource.getTokens())
            .thenAnswer((_) async => null);

        final result = await repository.restoreSession();

        expect(result, isNull);
        verify(() => mockLocalDataSource.getTokens()).called(1);
        verifyNever(() => mockRemoteDataSource.getCurrentUser());
      });

      test(
        'fetches current user and updates local storage when tokens exist',
        () async {
          when(() => mockLocalDataSource.getTokens())
              .thenAnswer((_) async => testTokensModel);
          when(() => mockRemoteDataSource.getCurrentUser())
              .thenAnswer((_) async => testUserModel);
          when(() => mockLocalDataSource.saveUser(testUserModel))
              .thenAnswer((_) async {});

          final result = await repository.restoreSession();

          expect(result, equals(testUser));
          verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
          verify(() => mockLocalDataSource.saveUser(testUserModel)).called(1);
        },
      );

      test('clears storage and returns null on 401 from remote', () async {
        when(() => mockLocalDataSource.getTokens())
            .thenAnswer((_) async => testTokensModel);
        when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/me'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/me'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocalDataSource.clearAll()).thenAnswer((_) async {});

        final result = await repository.restoreSession();

        expect(result, isNull);
        verify(() => mockLocalDataSource.clearAll()).called(1);
      });

      test('falls back to cached user on network error', () async {
        when(() => mockLocalDataSource.getTokens())
            .thenAnswer((_) async => testTokensModel);
        when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/me'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        when(() => mockLocalDataSource.getUser())
            .thenAnswer((_) async => testUserModel);

        final result = await repository.restoreSession();

        expect(result, equals(testUser));
      });
    });

    group('refreshToken', () {
      test('fetches new tokens and saves them locally', () async {
        const newTokensModel = AuthTokensModel(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );
        const expectedTokens = AuthTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );
        when(() => mockRemoteDataSource.refreshToken('old-refresh'))
            .thenAnswer((_) async => newTokensModel);
        when(() => mockLocalDataSource.saveTokens(newTokensModel))
            .thenAnswer((_) async {});

        final result = await repository.refreshToken('old-refresh');

        expect(result, equals(expectedTokens));
        verify(() => mockLocalDataSource.saveTokens(newTokensModel)).called(1);
      });
    });
  });
}
