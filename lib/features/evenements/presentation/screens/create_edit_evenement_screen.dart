import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/signme_unsaved_changes_guard.dart';
import '../../../../core/utils/evenement_image_picker.dart';
import '../../../main/presentation/screens/main_shell.dart' show kFloatingNavClearance;
import '../providers/evenements_provider.dart';
import '../../../../core/widgets/signme_page_app_bar.dart';

/// Création d'un événement (pasteur/secrétaire uniquement).
class CreateEditEvenementScreen extends ConsumerStatefulWidget {
  const CreateEditEvenementScreen({super.key});

  @override
  ConsumerState<CreateEditEvenementScreen> createState() => _CreateEditEvenementScreenState();
}

class _CreateEditEvenementScreenState extends ConsumerState<CreateEditEvenementScreen> {
  final _titreCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _objectifCtrl = TextEditingController();

  DateTime _dateDebut = DateTime.now();
  DateTime? _dateFin;
  String _mode = 'brouillon';
  DateTime? _scheduledPublishAt;
  File? _image;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(formDirtyProvider.notifier).state = false;
    });
    for (final controller in [_titreCtrl, _descriptionCtrl, _objectifCtrl]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _objectifCtrl.dispose();
    super.dispose();
  }

  /// Point d'écriture unique du drapeau global — appelé par tout champ
  /// modifié par l'utilisateur (texte, image, dates, mode de publication).
  void _markDirty() {
    if (!ref.read(formDirtyProvider)) {
      ref.read(formDirtyProvider.notifier).state = true;
    }
  }

  Future<void> _pickImage() async {
    try {
      final file = await EvenementImagePicker.pick(context);
      if (!mounted) return;
      if (file != null) {
        _markDirty();
        setState(() => _image = file);
      }
    } on EvenementImageTooLargeException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _pickDate({required bool isDebut}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? _dateDebut : (_dateFin ?? _dateDebut.add(const Duration(days: 1))),
      firstDate: isDebut ? now : _dateDebut,
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    _markDirty();
    setState(() {
      if (isDebut) {
        _dateDebut = picked;
      } else {
        _dateFin = picked;
      }
    });
  }

  Future<void> _pickScheduledDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;
    _markDirty();
    setState(() {
      _scheduledPublishAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_titreCtrl.text.trim().length < 5) {
      setState(() => _error = 'Le titre doit contenir au moins 5 caractères.');
      return;
    }
    if (_descriptionCtrl.text.trim().length < 20) {
      setState(() => _error = 'La description doit contenir au moins 20 caractères.');
      return;
    }
    if (_mode == 'planifie' && _scheduledPublishAt == null) {
      setState(() => _error = 'Choisissez une date/heure de publication planifiée.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(evenementFormProvider.notifier).create(
            titre: _titreCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            dateDebut: _dateDebut,
            dateFin: _dateFin,
            objectifMontant: _objectifCtrl.text.trim().isEmpty ? null : int.tryParse(_objectifCtrl.text.trim()),
            mode: _mode,
            scheduledPublishAt: _scheduledPublishAt,
            image: _image,
          );
      if (mounted) {
        ref.read(formDirtyProvider.notifier).state = false;
        AppSnackbar.success(context, 'Événement créé avec succès.');
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Erreur lors de la création de l\'événement.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignmeUnsavedChangesGuard(
      child: Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: SignmePageAppBar(title: 'Créer un événement', backEnabled: !_submitting),
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding bas dynamique : dégage la navbar flottante sur tous les
          // appareils (voir kFloatingNavClearance). SafeArea a déjà consommé
          // l'inset système ici, donc MediaQuery.padding.bottom vaut 0 à ce
          // niveau — la formule reste correcte dans les deux cas.
          padding: EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            SignmeSpacing.md,
            SignmeSpacing.lg,
            kFloatingNavClearance + MediaQuery.of(context).padding.bottom + SignmeSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imagePicker(),
              const SizedBox(height: SignmeSpacing.xl),
              _FieldLabel(icon: Icons.title_rounded, label: 'Titre'),
              const SizedBox(height: SignmeSpacing.sm),
              _SignmeOutlinedField(
                controller: _titreCtrl,
                hint: 'Ex: Excellence scolaire 2026',
                maxLength: 150,
              ),
              const SizedBox(height: SignmeSpacing.lg),
              _FieldLabel(icon: Icons.description_rounded, label: 'Description'),
              const SizedBox(height: SignmeSpacing.sm),
              _SignmeOutlinedField(
                controller: _descriptionCtrl,
                hint: 'Décrivez l\'événement et son objectif...',
                maxLines: 5,
                maxLength: 5000,
              ),
              const SizedBox(height: SignmeSpacing.lg),
              _dateField('Date de début', _dateDebut, () => _pickDate(isDebut: true)),
              const SizedBox(height: SignmeSpacing.md),
              _dateField('Date de fin (optionnelle)', _dateFin, () => _pickDate(isDebut: false),
                  onClear: _dateFin == null
                      ? null
                      : () {
                          _markDirty();
                          setState(() => _dateFin = null);
                        }),
              const SizedBox(height: SignmeSpacing.lg),
              Text('Objectif financier (optionnel, FCFA)',
                  style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: SignmeSpacing.sm),
              _objectifField(),
              const SizedBox(height: SignmeSpacing.xl),
              _modeSelector(),
              if (_mode == 'planifie') ...[
                const SizedBox(height: SignmeSpacing.md),
                _scheduledField(),
              ],
              const SizedBox(height: SignmeSpacing.xl),
              SignmePrimaryButton(
                label: 'Créer l\'événement',
                icon: Icons.auto_awesome_rounded,
                isLoading: _submitting,
                onPressed: _submit,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_error!, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: SignmeColors.accentSky.withOpacity(0.3),
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.primaryLight.withOpacity(0.4), width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_image == null)
              Positioned(
                bottom: -10,
                left: -10,
                right: -10,
                child: Icon(
                  Icons.terrain_rounded,
                  size: 110,
                  color: SignmeColors.primaryLight.withOpacity(0.12),
                ),
              ),
            if (_image != null)
              Positioned.fill(child: Image.file(_image!, fit: BoxFit.cover))
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded, color: SignmeColors.primaryLight, size: 28),
                  ),
                  const SizedBox(height: SignmeSpacing.sm),
                  Text('Ajouter une image (optionnel)',
                      style: SignmeTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('JPG, PNG ou WebP • Max 100 Ko',
                      style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray)),
                ],
              ),
            if (_image != null)
              Positioned(
                top: SignmeSpacing.sm,
                right: SignmeSpacing.sm,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () {
                      _markDirty();
                      setState(() => _image = null);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback onTap, {VoidCallback? onClear}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md, vertical: SignmeSpacing.sm),
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          border: Border.all(color: SignmeColors.lightGrayBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SignmeColors.primaryLight.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_rounded, color: SignmeColors.primaryLight, size: 18),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray)),
                  const SizedBox(height: 2),
                  Text(
                    value == null ? 'Sélectionner une date' : _formatDate(value),
                    style: SignmeTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: value == null ? SignmeColors.mediumGray : SignmeColors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(icon: const Icon(Icons.close, size: 16), onPressed: onClear)
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SignmeColors.accentSky,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: SignmeColors.primaryLight, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')} / ${value.month.toString().padLeft(2, '0')} / ${value.year}';

  Widget _objectifField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SignmeColors.primaryLight.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: SignmeColors.primaryLight, size: 18),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: TextField(
              controller: _objectifCtrl,
              keyboardType: TextInputType.number,
              style: SignmeTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Ex: 2 000 000',
                hintStyle: SignmeTypography.placeholder,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
              ),
            ),
          ),
          Text('FCFA', style: SignmeTypography.labelLarge.copyWith(color: SignmeColors.primaryLight, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _modeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Publication', style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: SignmeSpacing.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ModeCard(
                  icon: Icons.visibility_rounded,
                  label: 'Brouillon',
                  description: 'Visible uniquement par vous',
                  selected: _mode == 'brouillon',
                  onTap: () {
                    _markDirty();
                    setState(() => _mode = 'brouillon');
                  },
                ),
              ),
              const SizedBox(width: SignmeSpacing.sm),
              Expanded(
                child: _ModeCard(
                  icon: Icons.send_rounded,
                  label: 'Publier Immédiatement',
                  description: 'Visible par tous maintenant',
                  selected: _mode == 'immediate',
                  onTap: () {
                    _markDirty();
                    setState(() => _mode = 'immediate');
                  },
                ),
              ),
              const SizedBox(width: SignmeSpacing.sm),
              Expanded(
                child: _ModeCard(
                  icon: Icons.event_available_rounded,
                  label: 'Planifier',
                  description: 'Choisir une date de publication',
                  selected: _mode == 'planifie',
                  onTap: () {
                    _markDirty();
                    setState(() => _mode = 'planifie');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scheduledField() {
    return _dateField(
      'Date/heure de publication',
      _scheduledPublishAt,
      _pickScheduledDateTime,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: SignmeColors.primaryLight.withOpacity(0.12),
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
          ),
          child: Icon(icon, color: SignmeColors.primaryLight, size: 16),
        ),
        const SizedBox(width: SignmeSpacing.sm),
        Text(label, style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SignmeOutlinedField extends StatelessWidget {
  const _SignmeOutlinedField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: SignmeTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: SignmeTypography.placeholder,
        filled: true,
        fillColor: SignmeColors.white,
        contentPadding: SignmeSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          borderSide: const BorderSide(color: SignmeColors.lightGrayBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          borderSide: const BorderSide(color: SignmeColors.lightGrayBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          borderSide: const BorderSide(color: SignmeColors.primaryLight, width: 1.5),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.sm, vertical: SignmeSpacing.md),
            decoration: BoxDecoration(
              color: selected ? SignmeColors.accentSky.withOpacity(0.5) : SignmeColors.white,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              border: Border.all(
                color: selected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: SignmeColors.primaryLight.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: SignmeColors.primaryLight, size: 18),
                ),
                const SizedBox(height: SignmeSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SignmeTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? SignmeColors.primaryLight : SignmeColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
                ),
              ],
            ),
          ),
          if (selected)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(color: SignmeColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}
