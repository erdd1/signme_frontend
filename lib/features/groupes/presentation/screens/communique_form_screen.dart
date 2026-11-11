import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/widgets/keyboard_dismiss_scope.dart';
import '../../domain/entities/groupe_entities.dart';
import '../providers/groupes_provider.dart';
import '../widgets/groupe_sheet.dart';

/// Création ou modification d'un communiqué (président du groupe).
/// [communique] null = création. Plein écran, hors coquille.
class CommuniqueFormScreen extends ConsumerStatefulWidget {
  const CommuniqueFormScreen({super.key, required this.groupeUuid, this.communique});

  final String groupeUuid;
  final CommuniqueEntity? communique;

  @override
  ConsumerState<CommuniqueFormScreen> createState() => _CommuniqueFormScreenState();
}

class _CommuniqueFormScreenState extends ConsumerState<CommuniqueFormScreen> {
  static final _date = DateFormat('dd/MM/yyyy');

  late final TextEditingController _titre;
  late final TextEditingController _message;
  late final TextEditingController _objectif;
  DateTime? _debut;
  DateTime? _fin;
  bool _saving = false;
  String? _error;

  bool get _edition => widget.communique != null;

  @override
  void initState() {
    super.initState();
    final c = widget.communique;
    _titre = TextEditingController(text: c?.titre ?? '');
    _message = TextEditingController(text: c?.message ?? '');
    _objectif = TextEditingController(text: c?.objectifMontant?.toString() ?? '');
    _debut = DateTime.tryParse(c?.dateDebut ?? '');
    _fin = DateTime.tryParse(c?.dateFin ?? '');
  }

  @override
  void dispose() {
    _titre.dispose();
    _message.dispose();
    _objectif.dispose();
    super.dispose();
  }

  int? get _objectifValeur => int.tryParse(_objectif.text);

  bool get _valide =>
      _titre.text.trim().isNotEmpty &&
      _message.text.trim().isNotEmpty &&
      (_objectif.text.isEmpty || (_objectifValeur ?? 0) >= 500) &&
      (_debut == null || _fin == null || !_fin!.isBefore(_debut!));

  String _iso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _choisir({required bool debut}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (debut ? _debut : _fin) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: debut ? 'Date de début' : 'Date de fin',
    );
    if (picked == null) return;
    setState(() => debut ? _debut = picked : _fin = picked);
  }

  Future<void> _enregistrer() async {
    if (_saving || !_valide) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final data = {
      'titre': _titre.text.trim(),
      'message': _message.text.trim(),
      'objectifMontant': _objectif.text.isEmpty ? null : _objectifValeur,
      'dateDebut': _debut == null ? null : _iso(_debut!),
      'dateFin': _fin == null ? null : _iso(_fin!),
    };
    try {
      final remote = ref.read(mesGroupesRemoteDataSourceProvider);
      if (_edition) {
        await remote.modifierCommunique(widget.groupeUuid, widget.communique!.uuid, data);
      } else {
        await remote.creerCommunique(widget.groupeUuid, data);
      }
      if (!mounted) return;
      refreshGroupe(ref, widget.groupeUuid);
      AppSnackbar.success(context, _edition ? 'Communiqué modifié.' : 'Communiqué publié.');
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = messageFromError(e);
      });
    }
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
        child: Text(t, style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          tooltip: 'Retour',
          onPressed: () => context.pop(),
        ),
      ),
      body: KeyboardDismissScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            0,
            SignmeSpacing.lg,
            MediaQuery.of(context).padding.bottom + SignmeSpacing.xxxl,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              _edition ? 'Modifier le communiqué' : 'Nouveau communiqué',
              style: SignmeTypography.displaySmall.copyWith(fontWeight: FontWeight.w900, height: 1.2),
            ),
            const SizedBox(height: SignmeSpacing.xl),
            _label('Titre'),
            GroupeField(
              controller: _titre,
              hint: 'Ex. Dons de reconnaissance',
              icon: Icons.title_rounded,
              maxLength: 150,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SignmeSpacing.lg),
            _label('Message'),
            GroupeField(
              controller: _message,
              hint: 'Ex. Nous portons à la connaissance des jeunes du groupe que…',
              icon: Icons.campaign_rounded,
              maxLines: 6,
              maxLength: 2000,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SignmeSpacing.lg),
            _label('Objectif (optionnel)'),
            GroupeField(
              controller: _objectif,
              hint: 'Montant à atteindre',
              icon: Icons.flag_rounded,
              suffixText: 'FCFA',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
            ),
            if (_objectif.text.isNotEmpty && (_objectifValeur ?? 0) < 500)
              Padding(
                padding: const EdgeInsets.only(top: SignmeSpacing.sm),
                child: Text(
                  'L\'objectif doit être d\'au moins 500 FCFA.',
                  style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error),
                ),
              ),
            const SizedBox(height: SignmeSpacing.lg),
            _label('Période (optionnelle)'),
            Row(
              children: [
                Expanded(
                  child: _DateChip(
                    label: 'Début',
                    value: _debut == null ? null : _date.format(_debut!),
                    onTap: () => _choisir(debut: true),
                    onClear: _debut == null ? null : () => setState(() => _debut = null),
                  ),
                ),
                const SizedBox(width: SignmeSpacing.md),
                Expanded(
                  child: _DateChip(
                    label: 'Fin',
                    value: _fin == null ? null : _date.format(_fin!),
                    onTap: () => _choisir(debut: false),
                    onClear: _fin == null ? null : () => setState(() => _fin = null),
                  ),
                ),
              ],
            ),
            if (_debut != null && _fin != null && _fin!.isBefore(_debut!))
              Padding(
                padding: const EdgeInsets.only(top: SignmeSpacing.sm),
                child: Text(
                  'La date de fin doit suivre la date de début.',
                  style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: SignmeSpacing.md),
              Text(_error!, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
            ],
            const SizedBox(height: SignmeSpacing.xl),
            SignmePrimaryButton(
              label: _edition ? 'Enregistrer' : 'Publier le communiqué',
              icon: _edition ? Icons.check_rounded : Icons.send_rounded,
              enabled: _valide,
              isLoading: _saving,
              onPressed: _enregistrer,
            ),
            if (!_edition) ...[
              const SizedBox(height: SignmeSpacing.sm),
              Text(
                'Les membres du groupe seront notifiés.',
                textAlign: TextAlign.center,
                style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.value, required this.onTap, this.onClear});

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md, vertical: SignmeSpacing.md),
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: value == null ? SignmeColors.lightGrayBorder : SignmeColors.primaryLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, size: 18, color: SignmeColors.primaryLight),
            const SizedBox(width: SignmeSpacing.sm),
            Expanded(
              child: Text(
                value ?? label,
                style: SignmeTypography.labelMedium.copyWith(
                  fontWeight: value == null ? FontWeight.w500 : FontWeight.w700,
                  color: value == null ? SignmeColors.mediumGray : SignmeColors.onSurface,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded, size: 16, color: SignmeColors.mediumGray),
              ),
          ],
        ),
      ),
    );
  }
}
