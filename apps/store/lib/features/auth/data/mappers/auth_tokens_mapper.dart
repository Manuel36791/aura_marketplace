import '../../domain/entities/auth_tokens.dart';
import '../models/auth_tokens_model.dart';

abstract final class AuthTokensMapper {
  static AuthTokens toEntity(AuthTokensModel model) {
    return AuthTokens(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
    );
  }

  static AuthTokensModel toModel(AuthTokens entity) {
    return AuthTokensModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
    );
  }

  static AuthTokens? toEntityNullable(AuthTokensModel? model) {
    if (model == null) return null;
    return toEntity(model);
  }

  static AuthTokensModel? toModelNullable(AuthTokens? entity) {
    if (entity == null) return null;
    return toModel(entity);
  }
}

extension AuthTokensModelMappingX on AuthTokensModel {
  AuthTokens toEntity() => AuthTokensMapper.toEntity(this);
}

extension AuthTokensEntityMappingX on AuthTokens {
  AuthTokensModel toModel() => AuthTokensMapper.toModel(this);
}
