import 'auth_tokens_model.dart';
import 'user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.user, required this.tokens});

  final UserModel user;
  final AuthTokensModel tokens;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        tokens: AuthTokensModel.fromJson(
          json['tokens'] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'tokens': tokens.toJson(),
  };
}
