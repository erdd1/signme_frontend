/// Pont entre Dio (intercepteur) et AuthNotifier sans dépendance circulaire Riverpod.
class AuthSessionListener {
  Future<void> Function()? onExpired;
}
