import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/usecases/change_password_usecase.dart';

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(authRepositoryProvider));
});

final changePasswordProvider =
    StateNotifierProvider.autoDispose<ChangePasswordNotifier, bool>(
  (ref) => ChangePasswordNotifier(
    ref.watch(changePasswordUseCaseProvider),
    ref.read(authNotifierProvider.notifier),
  ),
);

/// `true` = requête en cours.
class ChangePasswordNotifier extends StateNotifier<bool> {
  ChangePasswordNotifier(this._useCase, this._authNotifier) : super(false);

  final ChangePasswordUseCase _useCase;
  final AuthNotifier _authNotifier;

  Future<ChangePasswordResult> submit({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = true;
    final result = await _useCase(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    state = false;

    return await result.fold(
      (failure) async => ChangePasswordResult.failure(failure),
      (_) async {
        await _authNotifier.onSessionExpired();
        return const ChangePasswordResult.success(
          'Mot de passe modifié. Reconnectez-vous avec le nouveau mot de passe.',
        );
      },
    );
  }
}

sealed class ChangePasswordResult {
  const ChangePasswordResult();

  const factory ChangePasswordResult.success(String message) = ChangePasswordSuccess;
  const factory ChangePasswordResult.failure(Failure failure) =
      ChangePasswordFailure;
}

final class ChangePasswordSuccess extends ChangePasswordResult {
  const ChangePasswordSuccess(this.message);
  final String message;
}

final class ChangePasswordFailure extends ChangePasswordResult {
  const ChangePasswordFailure(this.failure);
  final Failure failure;
}
