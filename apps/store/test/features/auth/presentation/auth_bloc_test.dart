import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/features/auth/domain/entities/user.dart';
import 'package:store/features/auth/domain/failures/auth_failure.dart';
import 'package:store/features/auth/domain/usecases/login_usecase.dart';
import 'package:store/features/auth/domain/usecases/logout_usecase.dart';
import 'package:store/features/auth/domain/usecases/register_usecase.dart';
import 'package:store/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:store/features/auth/presentation/bloc/auth_event.dart';
import 'package:store/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockRestoreSessionUseCase mockRestoreSessionUseCase;

  const testUser = User(
    id: 'usr_1',
    email: 'user@aura.example',
    name: 'Aura Shopper',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockRestoreSessionUseCase = MockRestoreSessionUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
    loginUseCase: mockLoginUseCase,
    registerUseCase: mockRegisterUseCase,
    logoutUseCase: mockLogoutUseCase,
    restoreSessionUseCase: mockRestoreSessionUseCase,
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(buildBloc().state, equals(const AuthInitial()));
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when session restored successfully',
        build: () {
          when(() => mockRestoreSessionUseCase())
              .thenAnswer((_) async => testUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [const AuthLoading(), const Authenticated(testUser)],
        verify: (_) {
          verify(() => mockRestoreSessionUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when no active session',
        build: () {
          when(() => mockRestoreSessionUseCase()).thenAnswer((_) async => null);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when restoreSession fails',
        build: () {
          when(() => mockRestoreSessionUseCase())
              .thenThrow(const SessionExpiredFailure());
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] on successful login',
        build: () {
          when(
            () => mockLoginUseCase(
              email: 'user@aura.example',
              password: 'password123',
            ),
          ).thenAnswer((_) async => testUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'user@aura.example',
            password: 'password123',
          ),
        ),
        expect: () => [const AuthLoading(), const Authenticated(testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] on invalid credentials',
        build: () {
          when(
            () => mockLoginUseCase(
              email: 'user@aura.example',
              password: 'wrongpassword',
            ),
          ).thenThrow(const InvalidCredentialsFailure());
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'user@aura.example',
            password: 'wrongpassword',
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(message: 'Invalid email or password'),
        ],
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] on successful registration',
        build: () {
          when(
            () => mockRegisterUseCase(
              name: 'Aura Shopper',
              email: 'user@aura.example',
              password: 'password123',
            ),
          ).thenAnswer((_) async => testUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            name: 'Aura Shopper',
            email: 'user@aura.example',
            password: 'password123',
          ),
        ),
        expect: () => [const AuthLoading(), const Authenticated(testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when email already exists',
        build: () {
          when(
            () => mockRegisterUseCase(
              name: 'Aura Shopper',
              email: 'existing@aura.example',
              password: 'password123',
            ),
          ).thenThrow(const EmailAlreadyInUseFailure());
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            name: 'Aura Shopper',
            email: 'existing@aura.example',
            password: 'password123',
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(
            message: 'An account with this email already exists',
          ),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] on logout',
        build: () {
          when(() => mockLogoutUseCase()).thenAnswer((_) async {});
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [const AuthLoading(), const Unauthenticated()],
        verify: (_) {
          verify(() => mockLogoutUseCase()).called(1);
        },
      );
    });
  });
}
