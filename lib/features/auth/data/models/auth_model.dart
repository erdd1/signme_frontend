import '../../domain/entities/auth_entity.dart';
import 'user_model.dart';

/// Modèle Auth — réponse d'authentification complète
class AuthModel extends AuthEntity {
  const AuthModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    super.isAuthenticated,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final Map<String, dynamic> userData = rawData is Map<String, dynamic>
        ? rawData
        : (json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : <String, dynamic>{});

    final user = UserModel.fromJson(userData);

    return AuthModel(
      user: user,
      accessToken: _readToken(json, userData, const ['access_token', 'token']),
      refreshToken: _readToken(json, userData, const ['refresh_token']),
      isAuthenticated: true,
    );
  }

  /// Les tokens Laravel sont dans `data` avec l'utilisateur, pas à la racine.
  static String _readToken(
    Map<String, dynamic> root,
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final fromRoot = root[key]?.toString();
      if (fromRoot != null && fromRoot.isNotEmpty) return fromRoot;

      final fromData = data[key]?.toString();
      if (fromData != null && fromData.isNotEmpty) return fromData;
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
        'user': (user as UserModel).toJson(),
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
}
