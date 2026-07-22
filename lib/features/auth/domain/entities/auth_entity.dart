import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Entité Auth — contient le user + les tokens
class AuthEntity extends Equatable {
  const AuthEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.isAuthenticated = true,
  });

  final UserEntity user;
  final String accessToken;
  final String refreshToken;
  final bool isAuthenticated;

  static const AuthEntity unauthenticated = AuthEntity(
    user: UserEntity(id: 0, nom: '', email: '', role: ''),
    accessToken: '',
    refreshToken: '',
    isAuthenticated: false,
  );

  @override
  List<Object?> get props => [user, accessToken, isAuthenticated];
}
