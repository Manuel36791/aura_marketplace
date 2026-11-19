import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  final _authStateController = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _localDataSource.saveTokens(response.tokens);
      await _localDataSource.saveUser(response.user);
      _authStateController.add(response.user);
      return response.user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw const UnknownAuthFailure();
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      await _localDataSource.saveTokens(response.tokens);
      await _localDataSource.saveUser(response.user);
      _authStateController.add(response.user);
      return response.user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw const UnknownAuthFailure();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Best-effort remote logout; always clear locally.
    } finally {
      await _localDataSource.clearAll();
      _authStateController.add(null);
    }
  }

  @override
  Future<User?> restoreSession() async {
    final tokens = await _localDataSource.getTokens();
    if (tokens == null) {
      _authStateController.add(null);
      return null;
    }

    try {
      final remoteUser = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUser(remoteUser);
      _authStateController.add(remoteUser);
      return remoteUser;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _localDataSource.clearAll();
        _authStateController.add(null);
        return null;
      }
      // If network failure, fall back to locally cached user
      final cachedUser = await _localDataSource.getUser();
      if (cachedUser != null) {
        _authStateController.add(cachedUser);
        return cachedUser;
      }
      return null;
    } catch (_) {
      final cachedUser = await _localDataSource.getUser();
      if (cachedUser != null) {
        _authStateController.add(cachedUser);
        return cachedUser;
      }
      return null;
    }
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    try {
      final newTokens = await _remoteDataSource.refreshToken(refreshToken);
      await _localDataSource.saveTokens(newTokens);
      return newTokens;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw const UnknownAuthFailure();
    }
  }

  AuthFailure _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      final msg = e.response?.data is Map
          ? (e.response?.data as Map)['error']?.toString()
          : null;
      return InvalidCredentialsFailure(msg ?? 'Invalid email or password');
    }
    if (statusCode == 409) {
      return const EmailAlreadyInUseFailure();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    return UnknownAuthFailure(
      e.message ?? 'An unexpected network error occurred',
    );
  }
}
