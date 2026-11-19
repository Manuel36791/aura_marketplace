import '../entities/auth_tokens.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});

  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User?> restoreSession();

  Future<AuthTokens> refreshToken(String refreshToken);

  Stream<User?> get authStateChanges;
}
