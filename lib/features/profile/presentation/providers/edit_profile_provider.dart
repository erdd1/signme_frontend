import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/profile_remote_datasource.dart';

// ── Providers Infrastructure ────────────────────────────────────────────────

/// Provider pour la DataSource distante
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRemoteDataSourceImpl(dio);
});

/// Provider pour le Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

/// Provider pour le UseCase
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

// ── Provider pour la mise à jour du profil ────────────────────────────────

/// Provider FutureProvider.family pour mettre à jour un champ du profil
/// 
/// Paramètre: Map<String, dynamic> avec les données à mettre à jour
/// Retourne: Either<Failure, UserEntity>
///   - Right(UserEntity) = succès avec données mises à jour
///   - Left(Failure) = erreur avec message descriptif
/// 
/// Flux:
/// 1. Appelle le UseCase avec userId et données
/// 2. UseCase appelle Repository.updateProfile()
/// 3. Repository délègue à DataSource et convertit Exception → Failure
/// 4. Met à jour l'auth state avec les nouvelles données
final submitProfileUpdateProvider = FutureProvider.family<Either<Failure, UserEntity>, Map<String, dynamic>>(
  (ref, updateData) async {
    final useCase = ref.watch(updateProfileUseCaseProvider);
    final authState = ref.watch(authNotifierProvider);
    
    // Vérifier que l'utilisateur est authentifié
    final userId = authState.auth?.user.id;
    if (userId == null) {
      return Left(AuthFailure(message: 'Utilisateur non authentifié'));
    }
    
    // Appeler le UseCase pour mettre à jour le profil
    final result = await useCase(
      userId: userId,
      updateData: updateData,
    );
    
    // Mettre à jour l'auth state avec les nouvelles données si succès
    result.fold(
      (failure) {
        // Erreur: ne rien faire, juste retourner l'erreur
      },
      (updatedUser) {
        // Succès: mettre à jour l'auth state
        // Cela garantit que le profil screen se rafraîchit car il écoute authNotifierProvider
        ref.read(authNotifierProvider.notifier).updateUserData(updatedUser);
      },
    );
    
    return result;
  },
);
