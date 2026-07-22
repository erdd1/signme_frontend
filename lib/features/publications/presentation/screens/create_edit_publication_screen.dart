import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/publication_entity.dart';
import '../providers/publications_provider.dart';

/// Création ou édition d'une publication (pasteur / secrétaire).
class CreateEditPublicationScreen extends ConsumerStatefulWidget {
  const CreateEditPublicationScreen({super.key, this.publicationId});

  /// Si défini → mode édition.
  final int? publicationId;

  @override
  ConsumerState<CreateEditPublicationScreen> createState() =>
      _CreateEditPublicationScreenState();
}

class _CreateEditPublicationScreenState
    extends ConsumerState<CreateEditPublicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titreCtrl;
  late final TextEditingController _contenuCtrl;
  late final TextEditingController _refCtrl;
  late String _selectedType;
  PublicationEntity? _existing;
  bool _isPrefilling = false;

  bool get _isEdit => widget.publicationId != null;

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController();
    _contenuCtrl = TextEditingController();
    _refCtrl = TextEditingController();
    _selectedType = 'annonce';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(formDirtyProvider.notifier).state = false;
    });
    for (final controller in [_titreCtrl, _contenuCtrl, _refCtrl]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _contenuCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  /// Point d'écriture unique du drapeau global — appelé par tout champ
  /// modifié par l'utilisateur (texte, type de publication).
  void _markDirty() {
    if (_isPrefilling) return;
    if (!ref.read(formDirtyProvider)) {
      ref.read(formDirtyProvider.notifier).state = true;
    }
  }

  void _prefill(PublicationEntity pub) {
    // Le préremplissage en mode édition modifie les contrôleurs (donc
    // déclenche leurs listeners) sans être une vraie saisie utilisateur.
    _isPrefilling = true;
    _existing = pub;
    _titreCtrl.text = pub.titre;
    _contenuCtrl.text = pub.contenu;
    _refCtrl.text = pub.referenceBiblique ?? '';
    _selectedType = pub.type;
    _isPrefilling = false;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(publicationFormProvider);
    final isSaving = formState.isLoading;

    if (_isEdit && _existing == null) {
      final asyncPub =
          ref.watch(publicationDetailProvider(widget.publicationId!));
      return asyncPub.when(
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: SignmeColors.primaryLight),
          ),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: SignmeErrorState(
            title: 'Publication introuvable',
            message: messageFromError(e),
            onRetry: () => ref.invalidate(
              publicationDetailProvider(widget.publicationId!),
            ),
          ),
        ),
        data: (pub) {
          if (_existing == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _prefill(pub));
            });
          }
          return _buildScaffold(isSaving);
        },
      );
    }

    return _buildScaffold(isSaving);
  }

  Widget _buildScaffold(bool isSaving) {
    return SignmeUnsavedChangesGuard(
      child: Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: isSaving ? null : () => context.pop(),
        ),
        title: Text(
          _isEdit ? 'Modifier la publication' : 'Nouvelle publication',
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: SignmeColors.primaryDark,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            SignmeSpacing.md,
            SignmeSpacing.lg,
            120,
          ),
          children: [
            if (!_isEdit) ...[
              Text(
                'Type de publication',
                style: SignmeTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SignmeSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'annonce',
                    label: Text('Annonce'),
                    icon: Icon(Icons.campaign_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: 'meditation',
                    label: Text('Méditation'),
                    icon: Icon(Icons.menu_book_outlined, size: 18),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: isSaving
                    ? null
                    : (set) {
                        _markDirty();
                        setState(() => _selectedType = set.first);
                      },
              ),
              const SizedBox(height: SignmeSpacing.xl),
            ] else if (_existing != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SignmeSpacing.md,
                  vertical: SignmeSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: SignmeColors.accentSky.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                ),
                child: Text(
                  'Type : ${_existing!.typeLabel} (non modifiable)',
                  style: SignmeTypography.labelMedium.copyWith(
                    color: SignmeColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: SignmeSpacing.xl),
            ],
            SignmeTextInput(
              label: 'Titre',
              hint: 'Titre de la publication',
              controller: _titreCtrl,
              enabled: !isSaving,
              maxLines: 2,
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return 'Minimum 3 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: SignmeSpacing.lg),
            SignmeTextInput(
              label: 'Contenu',
              hint: 'Rédigez votre message…',
              controller: _contenuCtrl,
              enabled: !isSaving,
              maxLines: 8,
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'Minimum 10 caractères';
                }
                return null;
              },
            ),
            if (_selectedType == 'meditation') ...[
              const SizedBox(height: SignmeSpacing.lg),
              SignmeTextInput(
                label: 'Référence biblique',
                hint: 'ex. Psaumes 23:1',
                controller: _refCtrl,
                enabled: !isSaving,
                leadingIcon: Icons.menu_book_outlined,
                validator: (v) {
                  if (_selectedType == 'meditation' &&
                      (v == null || v.trim().isEmpty)) {
                    return 'Obligatoire pour une méditation';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: SignmeSpacing.xxl),
            SignmePrimaryButton(
              label: _isEdit ? 'Enregistrer' : 'Publier',
              isLoading: isSaving,
              onPressed: isSaving ? null : _handleSave,
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(publicationFormProvider.notifier);

    try {
      if (_isEdit) {
        await notifier.update(
          id: widget.publicationId!,
          titre: _titreCtrl.text.trim(),
          contenu: _contenuCtrl.text.trim(),
          referenceBiblique: _refCtrl.text.trim(),
          isMeditation: _selectedType == 'meditation',
        );
      } else {
        await notifier.create(
          titre: _titreCtrl.text.trim(),
          contenu: _contenuCtrl.text.trim(),
          type: _selectedType,
          referenceBiblique: _refCtrl.text.trim(),
        );
      }
      if (mounted) {
        ref.read(formDirtyProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit ? 'Publication mise à jour' : 'Publication publiée',
            ),
            backgroundColor: SignmeColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is AppException ? e.message : messageFromError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: SignmeColors.error),
      );
    }
  }
}
