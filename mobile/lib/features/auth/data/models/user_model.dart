import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.none)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.phone,
    super.fullName,
    super.email,
    super.avatar,
    required super.status,
    required super.phoneVerified,
    required super.emailVerified,
    super.lastLoginAt,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      phone: user.phone,
      email: user.email,
      avatar: user.avatar,
      status: user.status,
      phoneVerified: user.phoneVerified,
      emailVerified: user.emailVerified,
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.none)
class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) => _$AuthTokensModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none)
class AuthResponseModel extends AuthResponse {
  @override
  final UserModel user;
  @override
  final AuthTokensModel tokens;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
  }) : super(user: user, tokens: tokens);

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}