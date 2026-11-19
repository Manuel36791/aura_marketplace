import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();

  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clearUser();

  Future<void> clearAll();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userKey = 'auth_user';

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  @override
  Future<AuthTokens?> getTokens() async {
    final access = await _storage.read(key: _accessTokenKey);
    final refresh = await _storage.read(key: _refreshTokenKey);
    if (access == null || refresh == null) {
      return null;
    }
    return AuthTokensModel(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<void> saveUser(User user) async {
    final model = UserModel.fromEntity(user);
    await _storage.write(key: _userKey, value: jsonEncode(model.toJson()));
  }

  @override
  Future<User?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() => _storage.delete(key: _userKey);

  @override
  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
  }
}
