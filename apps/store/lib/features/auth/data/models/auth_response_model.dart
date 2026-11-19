import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'auth_tokens_model.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthResponseModel extends Equatable {
  const AuthResponseModel({required this.user, required this.tokens});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  final UserModel user;
  final AuthTokensModel tokens;

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Object?> get props => [user, tokens];
}
