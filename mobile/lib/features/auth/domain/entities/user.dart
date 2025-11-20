import 'package:equatable/equatable.dart';

enum UserStatus {
  active,
  inactive,
  suspended,
  pendingVerification,
}

class User extends Equatable {
  final String id;
  final String? fullName;
  final String phone;
  final String? email;
  final String? avatar;
  final UserStatus status;
  final bool phoneVerified;
  final bool emailVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatar,
    required this.status,
    required this.phoneVerified,
    required this.emailVerified,
    this.lastLoginAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        email,
        avatar,
        status,
        phoneVerified,
        emailVerified,
        lastLoginAt,
        createdAt,
      ];
}

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object> get props => [accessToken, refreshToken];
}

class AuthResponse extends Equatable {
  final User user;
  final AuthTokens tokens;

  const AuthResponse({
    required this.user,
    required this.tokens,
  });

  @override
  List<Object> get props => [user, tokens];
}