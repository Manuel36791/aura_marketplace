import 'package:flutter_test/flutter_test.dart';
import 'package:store/features/auth/data/mappers/auth_tokens_mapper.dart';
import 'package:store/features/auth/data/mappers/user_mapper.dart';
import 'package:store/features/auth/data/models/auth_tokens_model.dart';
import 'package:store/features/auth/data/models/user_model.dart';
import 'package:store/features/auth/domain/entities/auth_tokens.dart';
import 'package:store/features/auth/domain/entities/user.dart';

void main() {
  group('UserMapper', () {
    const model = UserModel(
      id: 'usr_1',
      email: 'user@aura.example',
      name: 'Aura Shopper',
      avatarUrl: 'https://example.com/avatar.png',
    );

    const entity = User(
      id: 'usr_1',
      email: 'user@aura.example',
      name: 'Aura Shopper',
      avatarUrl: 'https://example.com/avatar.png',
    );

    test('toEntity converts UserModel to User entity', () {
      final result = UserMapper.toEntity(model);
      expect(result, equals(entity));
      expect(result.id, equals('usr_1'));
      expect(result.email, equals('user@aura.example'));
      expect(result.name, equals('Aura Shopper'));
      expect(result.avatarUrl, equals('https://example.com/avatar.png'));
    });

    test('toModel converts User entity to UserModel', () {
      final result = UserMapper.toModel(entity);
      expect(result, equals(model));
      expect(result.id, equals('usr_1'));
      expect(result.email, equals('user@aura.example'));
      expect(result.name, equals('Aura Shopper'));
      expect(result.avatarUrl, equals('https://example.com/avatar.png'));
    });

    test('toEntityNullable handles null and non-null correctly', () {
      expect(UserMapper.toEntityNullable(null), isNull);
      expect(UserMapper.toEntityNullable(model), equals(entity));
    });

    test('toModelNullable handles null and non-null correctly', () {
      expect(UserMapper.toModelNullable(null), isNull);
      expect(UserMapper.toModelNullable(entity), equals(model));
    });

    test('extension methods toEntity and toModel map correctly', () {
      expect(model.toEntity(), equals(entity));
      expect(entity.toModel(), equals(model));
    });
  });

  group('AuthTokensMapper', () {
    const model = AuthTokensModel(
      accessToken: 'acc_123',
      refreshToken: 'ref_456',
    );

    const entity = AuthTokens(accessToken: 'acc_123', refreshToken: 'ref_456');

    test('toEntity converts AuthTokensModel to AuthTokens entity', () {
      final result = AuthTokensMapper.toEntity(model);
      expect(result, equals(entity));
      expect(result.accessToken, equals('acc_123'));
      expect(result.refreshToken, equals('ref_456'));
    });

    test('toModel converts AuthTokens entity to AuthTokensModel', () {
      final result = AuthTokensMapper.toModel(entity);
      expect(result, equals(model));
      expect(result.accessToken, equals('acc_123'));
      expect(result.refreshToken, equals('ref_456'));
    });

    test('extension methods toEntity and toModel map correctly', () {
      expect(model.toEntity(), equals(entity));
      expect(entity.toModel(), equals(model));
    });
  });
}
