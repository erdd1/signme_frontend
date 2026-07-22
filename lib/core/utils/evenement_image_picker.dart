import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Sélection et validation locale de l'image d'un événement (module collecte
/// de fonds). Contrainte métier : taille maximale 100 Ko (bien plus stricte
/// que la photo de profil), donc qualité de compression réduite par défaut.
abstract final class EvenementImagePicker {
  static const int maxBytes = 100 * 1024; // 100 Ko
  static const int maxDimension = 720;
  static const int imageQuality = 60;

  static final ImagePicker _picker = ImagePicker();

  /// Affiche le choix galerie / appareil photo.
  static Future<File?> pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Appareil photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: maxDimension.toDouble(),
      maxHeight: maxDimension.toDouble(),
      imageQuality: imageQuality,
    );

    if (xFile == null) return null;

    final file = File(xFile.path);
    final length = await file.length();
    if (length > maxBytes) {
      throw EvenementImageTooLargeException(
        'L\'image est trop lourde (${(length / 1024).toStringAsFixed(0)} Ko). '
        'Maximum : 100 Ko.',
      );
    }
    return file;
  }
}

class EvenementImageTooLargeException implements Exception {
  EvenementImageTooLargeException(this.message);
  final String message;

  @override
  String toString() => message;
}
