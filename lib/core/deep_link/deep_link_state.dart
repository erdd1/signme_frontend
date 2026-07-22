import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chemin GoRouter en attente (cold start depuis email).
final pendingDeepLinkProvider = StateProvider<String?>((ref) => null);
