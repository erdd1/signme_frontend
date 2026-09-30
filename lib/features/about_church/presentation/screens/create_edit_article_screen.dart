import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/utils/profile_image_picker.dart';
import '../../../../core/widgets/index.dart';
import '../../../main/presentation/screens/main_shell.dart' show kFloatingNavClearance;
import '../../domain/entities/about_article_entity.dart';
import '../providers/about_church_provider.dart';
import '../utils/max_words_input_formatter.dart';

class CreateEditArticleScreen extends ConsumerStatefulWidget {
  const CreateEditArticleScreen({super.key, this.articleUuid});
  final String? articleUuid;

  @override
  ConsumerState<CreateEditArticleScreen> createState() => _CreateEditArticleScreenState();
}

class _CreateEditArticleScreenState extends ConsumerState<CreateEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _contenuCtrl = TextEditingController();
  String _type = AboutArticleEntity.typeActivity;
  String _statutPasteur = AboutArticleEntity.statutPasteurActuel;

  /// Photos déjà sur le serveur (URLs), conservées si non retirées.
  List<String> _existingImages = [];

  /// Nouvelles photos choisies localement, à uploader.
  final List<File> _newImages = [];
  bool _isSaving = false;
  bool _prefilled = false;

  /// `true` dès qu'on ajoute et/ou retire une photo (même pour tout
  /// retirer sans rien ajouter) — sans interaction, les photos existantes
  /// restent automatiquement inchangées à l'enregistrement.
  bool _photosTouched = false;
  int _contenuWordCount = 0;

  int get _totalImageCount => _existingImages.length + _newImages.length;

  bool get _contenuAtMaxLength => _contenuWordCount >= AboutArticleEntity.maxMotsContenu;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _contenuCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_totalImageCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 3 images')));
      return;
    }
    try {
      final file = await ProfileImagePicker.pick(context);
      if (file != null) {
        setState(() {
          _newImages.add(file);
          _photosTouched = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
      _photosTouched = true;
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
      _photosTouched = true;
    });
  }

  void _prefillIfNeeded(AboutArticleEntity? article) {
    if (_prefilled || article == null) return;
    _prefilled = true;
    _titreCtrl.text = article.titre;
    _contenuCtrl.text = article.contenu;
    _contenuWordCount = MaxWordsInputFormatter.countWords(article.contenu);
    _type = article.type;
    _statutPasteur = article.statutPasteur ?? AboutArticleEntity.statutPasteurActuel;
    _existingImages = List.of(article.images);
  }

  static const _typeLabels = {
    AboutArticleEntity.typeActivity: 'Activité majeure',
    AboutArticleEntity.typeGroup: 'Groupe',
    AboutArticleEntity.typePastor: 'Pasteur',
  };

  static const _statutPasteurLabels = {
    AboutArticleEntity.statutPasteurActuel: 'Pasteur actuel',
    AboutArticleEntity.statutPasteurAncien: 'Ancien pasteur',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(aboutChurchProvider.notifier);
      final isPastor = _type == AboutArticleEntity.typePastor;
      if (widget.articleUuid == null) {
        await notifier.createArticle(
          type: _type,
          titre: _titreCtrl.text.trim(),
          contenu: _contenuCtrl.text.trim(),
          statutPasteur: isPastor ? _statutPasteur : null,
          images: _newImages,
        );
      } else {
        await notifier.updateArticle(
          uuid: widget.articleUuid!,
          titre: _titreCtrl.text.trim(),
          contenu: _contenuCtrl.text.trim(),
          statutPasteur: isPastor ? _statutPasteur : null,
          photosTouched: _photosTouched,
          keepImages: _existingImages,
          images: _newImages,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = ref.watch(aboutChurchProvider);
    AboutArticleEntity? article;
    final data = payload.asData?.value;
    if (widget.articleUuid != null && data != null) {
      article = data.articles.where((a) => a.uuid == widget.articleUuid).firstOrNull;
    }
    _prefillIfNeeded(article);

    return SignmeUnsavedChangesGuard(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: SignmeColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
            onPressed: _isSaving ? null : () => context.pop(),
          ),
          title: Text(
            widget.articleUuid == null ? 'Nouvel article' : 'Modifier l\'article',
            style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            // Padding bas dynamique : dégage la navbar flottante sur tous les
            // appareils (voir kFloatingNavClearance).
            padding: EdgeInsets.fromLTRB(
              SignmeSpacing.lg,
              SignmeSpacing.md,
              SignmeSpacing.lg,
              kFloatingNavClearance + MediaQuery.of(context).padding.bottom + SignmeSpacing.xl,
            ),
            children: [
              SignmeCompactDropdown<String>(
                label: 'Type',
                value: _type,
                items: [
                  AboutArticleEntity.typeActivity,
                  AboutArticleEntity.typeGroup,
                  AboutArticleEntity.typePastor,
                ],
                itemLabel: (s) => _typeLabels[s] ?? s,
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              if (_type == AboutArticleEntity.typePastor) ...[
                const SizedBox(height: SignmeSpacing.lg),
                SignmeCompactDropdown<String>(
                  label: 'Statut du pasteur',
                  value: _statutPasteur,
                  items: [
                    AboutArticleEntity.statutPasteurActuel,
                    AboutArticleEntity.statutPasteurAncien,
                  ],
                  itemLabel: (s) => _statutPasteurLabels[s] ?? s,
                  onChanged: (v) => setState(() => _statutPasteur = v ?? _statutPasteur),
                ),
              ],
              const SizedBox(height: SignmeSpacing.lg),
              SignmeTextInput(
                label: 'Titre',
                hint: 'Titre de l\'article',
                controller: _titreCtrl,
                enabled: !_isSaving,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
              ),
              const SizedBox(height: SignmeSpacing.lg),
              SignmeTextInput(
                label: 'Contenu',
                hint: 'Texte complet de l\'article',
                controller: _contenuCtrl,
                enabled: !_isSaving,
                maxLines: 12,
                inputFormatters: [MaxWordsInputFormatter(AboutArticleEntity.maxMotsContenu)],
                onChanged: (v) => setState(() => _contenuWordCount = MaxWordsInputFormatter.countWords(v)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Contenu requis' : null,
                helperText: _contenuAtMaxLength
                    ? 'Vous avez atteint la longueur maximale autorisée pour cet article.'
                    : null,
              ),
              const SizedBox(height: SignmeSpacing.lg),
              Text('Photos (max 3)', style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: SignmeSpacing.sm),
              Wrap(
                spacing: SignmeSpacing.sm,
                runSpacing: SignmeSpacing.sm,
                children: [
                  for (var i = 0; i < _existingImages.length; i++) _existingImagePreview(i),
                  for (var i = 0; i < _newImages.length; i++) _newImagePreview(i),
                  if (_totalImageCount < 3)
                    GestureDetector(
                      onTap: _isSaving ? null : _pickImage,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: SignmeColors.accentSky.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                          border: Border.all(color: SignmeColors.lightGrayBorder),
                        ),
                        child: const Icon(Icons.add_a_photo_rounded, color: SignmeColors.primaryLight),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.xl),
              SignmePrimaryButton(
                label: widget.articleUuid == null ? 'Publier' : 'Enregistrer',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newImagePreview(int index) {
    final file = _newImages[index];
    return _imagePreviewFrame(
      image: Image.file(file, width: 88, height: 88, fit: BoxFit.cover),
      onRemove: () => _removeNewImage(index),
    );
  }

  Widget _existingImagePreview(int index) {
    final url = _existingImages[index];
    return _imagePreviewFrame(
      image: Image.network(
        url,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: 88,
          height: 88,
          color: SignmeColors.accentSky.withOpacity(0.2),
          child: const Icon(Icons.broken_image_rounded, color: SignmeColors.mediumGray),
        ),
      ),
      onRemove: () => _removeExistingImage(index),
    );
  }

  Widget _imagePreviewFrame({required Widget image, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          child: image,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _isSaving ? null : onRemove,
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
