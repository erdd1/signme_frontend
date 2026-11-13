import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../design_system/index.dart';
import '../network/dio_exception_mapper.dart';
import '../services/pdf_download_service.dart';
import 'app_button.dart';
import 'app_snackbar.dart';

/// Bouton "Télécharger (PDF)" réutilisable — lance le téléchargement dans une
/// boîte de dialogue avec barre de progression, puis propose d'ouvrir le
/// fichier avec une application externe (jamais dans SignMe lui-même).
class PdfDownloadButton extends StatelessWidget {
  const PdfDownloadButton({
    super.key,
    required this.label,
    required this.path,
    required this.filename,
    this.queryParameters,
  });

  final String label;
  final String path;
  final String filename;
  final Map<String, dynamic>? queryParameters;

  @override
  Widget build(BuildContext context) {
    return SignmeSecondaryButton(
      label: label,
      icon: Icons.picture_as_pdf_rounded,
      onPressed: () => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PdfDownloadProgressDialog(
          path: path,
          filename: filename,
          queryParameters: queryParameters,
        ),
      ),
    );
  }
}

enum _DownloadState { running, success, error }

/// Boîte de dialogue de progression — démarre le téléchargement dès
/// l'ouverture, affiche le pourcentage, puis l'emplacement du fichier avec
/// un bouton "Ouvrir le PDF" (ou le message d'erreur en cas d'échec).
class PdfDownloadProgressDialog extends ConsumerStatefulWidget {
  const PdfDownloadProgressDialog({
    super.key,
    required this.path,
    required this.filename,
    this.queryParameters,
  });

  final String path;
  final String filename;
  final Map<String, dynamic>? queryParameters;

  @override
  ConsumerState<PdfDownloadProgressDialog> createState() =>
      _PdfDownloadProgressDialogState();
}

class _PdfDownloadProgressDialogState
    extends ConsumerState<PdfDownloadProgressDialog> {
  _DownloadState _state = _DownloadState.running;
  double _progress = 0;
  String? _filePath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startDownload());
  }

  Future<void> _startDownload() async {
    try {
      final filePath = await ref.read(pdfDownloadServiceProvider).download(
            path: widget.path,
            filename: widget.filename,
            queryParameters: widget.queryParameters,
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );
      if (!mounted) return;
      setState(() {
        _state = _DownloadState.success;
        _filePath = filePath;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _DownloadState.error;
        _errorMessage = messageFromError(e);
      });
    }
  }

  /// Ouvre le fichier avec une application externe. Retourne `true` en cas
  /// de succès (la boîte de dialogue peut alors se fermer) ; en cas d'échec,
  /// reste ouverte et affiche le message d'erreur.
  Future<bool> _openFile() async {
    final filePath = _filePath;
    if (filePath == null) return false;

    final result = await OpenFilex.open(filePath);
    if (result.type == ResultType.done) return true;

    if (!mounted) return false;
    AppSnackbar.error(context, result.type == ResultType.noAppToOpen
              ? 'Aucune application installée ne peut ouvrir ce PDF.'
              : 'Impossible d\'ouvrir le fichier.');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _state != _DownloadState.running,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        ),
        backgroundColor: SignmeColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(SignmeSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _title,
                style: SignmeTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SignmeSpacing.lg),
              _buildContent(),
              const SizedBox(height: SignmeSpacing.lg),
              ..._buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  String get _title => switch (_state) {
        _DownloadState.running => 'Téléchargement en cours',
        _DownloadState.success => 'Téléchargement terminé',
        _DownloadState.error => 'Échec du téléchargement',
      };

  Widget _buildContent() {
    switch (_state) {
      case _DownloadState.running:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                minHeight: 8,
                backgroundColor: SignmeColors.accentSky,
                valueColor: const AlwaysStoppedAnimation(SignmeColors.primaryLight),
              ),
            ),
            const SizedBox(height: SignmeSpacing.sm),
            Text(
              '${(_progress * 100).clamp(0, 100).toStringAsFixed(0)} %',
              style: SignmeTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: SignmeColors.primaryLight,
              ),
            ),
          ],
        );
      case _DownloadState.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: SignmeColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: SignmeColors.success,
                size: 32,
              ),
            ),
            const SizedBox(height: SignmeSpacing.md),
            Text(
              'Fichier enregistré :',
              style: SignmeTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _filePath ?? '',
              style: SignmeTypography.labelSmall.copyWith(
                color: SignmeColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case _DownloadState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: SignmeColors.error, size: 40),
            const SizedBox(height: SignmeSpacing.md),
            Text(
              _errorMessage ?? 'Une erreur est survenue.',
              style: SignmeTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    switch (_state) {
      case _DownloadState.running:
        return const [];
      case _DownloadState.success:
        return [
          Row(
            children: [
              Expanded(
                child: SignmeSecondaryButton(
                  label: 'Fermer',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: SignmePrimaryButton(
                  label: 'Ouvrir le PDF',
                  onPressed: () async {
                    final opened = await _openFile();
                    if (opened && context.mounted) Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ];
      case _DownloadState.error:
        return [
          SizedBox(
            width: double.infinity,
            child: SignmeSecondaryButton(
              label: 'Fermer',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ];
    }
  }
}
