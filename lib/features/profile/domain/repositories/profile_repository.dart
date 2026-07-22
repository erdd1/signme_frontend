import 'package:dartz/dartz.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';

/// Interface du repository du profil
/// Définit les contrats pour les opérations du profil utilisateur
abstract class ProfileRepository {
  /// Mettre à jour le profil utilisateur
  /// 
  /// Paramètres:
  ///   - userId: ID de l'utilisateur à mettre à jour
  ///   - updateData: Map avec les champs à mettre à jour (clés snake_case: "originaire_de", "profession", etc.)
  /// 
  /// Retourne:
  ///   - Right(UserEntity): Succès avec les données utilisateur mises à jour
  ///   - Left(Failure): Erreur avec message descriptif
  Future<Either<Failure, UserEntity>> updateProfile({
    required int userId,
    required Map<String, dynamic> updateData,
  });
}
