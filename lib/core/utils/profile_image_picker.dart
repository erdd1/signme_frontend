import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Sélection et validation locale des photos de profil (léger, adapté mobile).
abstract final class ProfileImagePicker {
  static const int maxBytes = 2 * 1024 * 1024; // aligné API (2 Mo)
  static const int maxDimension = 1024;
  static const int imageQuality = 85;

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
      throw ProfileImageTooLargeException(
        'La photo est trop lourde (${(length / (1024 * 1024)).toStringAsFixed(1)} Mo). '
        'Maximum : 2 Mo.',
      );
    }
    return file;
  }
}

class ProfileImageTooLargeException implements Exception {
  ProfileImageTooLargeException(this.message);
  final String message;

  @override
  String toString() => message;
}
