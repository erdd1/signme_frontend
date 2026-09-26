import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Télécharge un PDF généré par le backend et l'enregistre sur l'appareil de
/// l'utilisateur (stockage local propre à l'application — SignMe ne conserve
/// aucun PDF côté serveur ni en mémoire au-delà de ce fichier).
class PdfDownloadService {
  PdfDownloadService(this._dio);

  final Dio _dio;

  /// Télécharge le PDF et retourne le chemin du fichier enregistré.
  /// [onProgress] reçoit une valeur entre 0.0 et 1.0.
  Future<String> download({
    required String path,
    required String filename,
    Map<String, dynamic>? queryParameters,
    void Function(double progress)? onProgress,
  }) async {
    final dir = await _resolveSaveDirectory();
    // Le fichier sur le disque est bien réécrit à chaque téléchargement,
    // mais il est ensuite remis à une application EXTERNE (OpenFilex) — de
    // nombreux visualiseurs PDF mettent en cache le contenu par nom de
    // fichier et peuvent réafficher une ancienne version déjà ouverte sous
    // ce même nom, même si le fichier réel est à jour. Un nom unique par
    // téléchargement garantit que le visualiseur ne peut jamais confondre
    // deux exports différents.
    final filePath = '${dir.path}/${_withTimestamp(filename)}';

    await _dio.download(
      path,
      filePath,
      queryParameters: queryParameters,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress?.call(received / total);
      },
    );

    return filePath;
  }

  String _withTimestamp(String filename) {
    final dot = filename.lastIndexOf('.');
    final base = dot == -1 ? filename : filename.substring(0, dot);
    final ext = dot == -1 ? '' : filename.substring(dot);
    return '${base}_${DateTime.now().millisecondsSinceEpoch}$ext';
  }

  /// Dossier de stockage propre à l'application (aucune permission requise,
  /// stable sur toutes les versions d'Android grâce au stockage scopé).
  ///
  /// `getExternalStorageDirectory()` n'existe que sur Android — sur iOS
  /// (sandbox applicative, pas de stockage "externe" exposé), l'appel lève
  /// un `UnsupportedError` au lieu de retourner `null` comme on pourrait s'y
  /// attendre. Sans cette garde de plateforme, cette exception n'était
  /// jamais rattrapée par le `if (external != null)` ci-dessous (il n'est
  /// jamais atteint) et remontait telle quelle jusqu'à l'UI, qui l'affichait
  /// comme "Une erreur inattendue s'est produite." — le téléchargement PDF
  /// échouait donc systématiquement sur iPhone alors qu'Android fonctionnait.
  Future<Directory> _resolveSaveDirectory() async {
    if (Platform.isAndroid) {
      final external = await getExternalStorageDirectory();
      if (external != null) return external;
    }
    return getApplicationDocumentsDirectory();
  }
}

final pdfDownloadServiceProvider = Provider<PdfDownloadService>((ref) {
  return PdfDownloadService(ref.watch(dioProvider));
});
