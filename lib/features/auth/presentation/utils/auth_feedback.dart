import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/app_snackbar.dart';

/// Affiche le message d'échec auth (429, 401, réseau, etc.).
void showAuthFailure(BuildContext context, Failure failure) {
  if (failure is RateLimitFailure) {
    AppSnackbar.warning(context, failure.message);
    return;
  }
  if (failure is ForbiddenFailure) {
    AppSnackbar.error(context, failure.message);
    return;
  }
  AppSnackbar.error(context, failure.message);
}
