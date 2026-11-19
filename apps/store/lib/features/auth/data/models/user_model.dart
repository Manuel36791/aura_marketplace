import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Object?> get props => [id, email, name, avatarUrl];
}
