import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens_model.g.dart';

@JsonSerializable()
class AuthTokensModel extends Equatable {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);

  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toJson() => _$AuthTokensModelToJson(this);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Object?> get props => [accessToken, refreshToken];
}
