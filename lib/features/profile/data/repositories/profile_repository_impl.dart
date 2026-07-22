import 'package:dartz/dartz.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/update_profile_request_model.dart';

/// Implémentation du ProfileRepository
/// Gère la logique de conversion Exception → Failure et délègue à la DataSource
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required int userId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      // Créer le modèle de requête à partir des données
      final requestModel = UpdateProfileRequestModel.fromMap(updateData);
      
      // Appeler la DataSource
      final result = await remoteDataSource.updateProfile(
        userId: userId,
        requestModel: requestModel,
      );
      
      // Retourner le succès
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    } catch (e) {
      return Left(const UnknownFailure());
    }
  }
}
