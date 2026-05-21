import 'package:equatable/equatable.dart';

// ── Failures — couche Domain (Either<Failure, T>) ─────────────────────────────

abstract class Failure extends Equatable {
  const Failure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, this.errors = const {}});
  final Map<String, List<String>> errors;
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'Accès refusé'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Vérifiez votre connexion internet.'});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Erreur serveur. Veuillez réessayer.'});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Ressource introuvable.'});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'La connexion a expiré. Réessayez.'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Une erreur inattendue s\'est produite.'});
}
