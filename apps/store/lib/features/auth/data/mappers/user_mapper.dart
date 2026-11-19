import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract final class UserMapper {
  static User toEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      name: model.name,
      avatarUrl: model.avatarUrl,
    );
  }

  static UserModel toModel(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      avatarUrl: entity.avatarUrl,
    );
  }

  static User? toEntityNullable(UserModel? model) {
    if (model == null) return null;
    return toEntity(model);
  }

  static UserModel? toModelNullable(User? entity) {
    if (entity == null) return null;
    return toModel(entity);
  }
}

extension UserModelMappingX on UserModel {
  User toEntity() => UserMapper.toEntity(this);
}

extension UserEntityMappingX on User {
  UserModel toModel() => UserMapper.toModel(this);
}
