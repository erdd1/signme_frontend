import 'package:dartz/dartz.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// UseCase pour la mise à jour du profil utilisateur
/// Encapsule la logique métier et gère l'interaction avec le repository
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  /// Exécute la mise à jour du profil
  /// 
  /// Paramètres:
  ///   - userId: ID de l'utilisateur
  ///   - updateData: Données à mettre à jour (clés snake_case)
  /// 
  /// Retourne: Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> call({
    required int userId,
    required Map<String, dynamic> updateData,
  }) async {
    // On pourrait ajouter de la validation métier ici si nécessaire
    // Pour l'instant, on délègue directement au repository
    return await repository.updateProfile(
      userId: userId,
      updateData: updateData,
    );
  }
}
