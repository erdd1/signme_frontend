import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  ChangePasswordUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _authRepository.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
