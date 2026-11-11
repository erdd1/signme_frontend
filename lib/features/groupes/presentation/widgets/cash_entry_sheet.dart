import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/groupe_entities.dart';
import '../providers/groupes_provider.dart';
import 'groupe_sheet.dart';

/// Enregistre de l'argent reçu HORS application (cash) dans la caisse du
/// groupe — président ou trésorier. Toujours distinct de l'argent en ligne.
Future<bool?> showCashEntrySheet(BuildContext context, {required String groupeUuid}) {
  return showGroupeSheet<bool>(
    context,
    title: 'Argent reçu hors application',
    subtitle: 'Enregistrez de l\'argent reçu en main propre. Il reste séparé de l\'argent reçu par l\'application.',
    builder: (_) => _CashEntryForm(groupeUuid: groupeUuid),
  );
}

class _CashEntryForm extends ConsumerStatefulWidget {
  const _CashEntryForm({required this.groupeUuid});

  final String groupeUuid;

  @override
  ConsumerState<_CashEntryForm> createState() => _CashEntryFormState();
}

class _CashEntryFormState extends ConsumerState<_CashEntryForm> {
  final _montant = TextEditingController();
  final _donateur = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;
  String? _error;

  // Choix facultatifs : « Aucun » est une vraie ligne du menu (comme les autres
  // sélecteurs de l'application, qui n'offrent pas d'effacement séparé).
  static const _aucunCommunique = _Choix<String>(null, 'Aucun communiqué');
  static const _aucunMembre = _Choix<int>(null, 'Aucun membre');
  _Choix<String> _communique = _aucunCommunique;
  _Choix<int> _membre = _aucunMembre;

  @override
  void dispose() {
    _montant.dispose();
    _donateur.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _valeur => int.tryParse(_montant.text) ?? 0;

  Future<void> _submit() async {
    if (_saving || _valeur <= 0) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(mesGroupesRemoteDataSourceProvider).enregistrerCash(
            widget.groupeUuid,
            montant: _valeur,
            // Un membre choisi remplace le donateur saisi à la main.
            donateur: _membre.valeur == null ? _donateur.text.trim() : null,
            note: _note.text.trim(),
            communiqueUuid: _communique.valeur,
            membreId: _membre.valeur,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = messageFromError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final communiques = ref.watch(communiquesProvider(widget.groupeUuid)).valueOrNull ?? const <CommuniqueEntity>[];
    final membres = ref.watch(groupeMembresProvider(widget.groupeUuid)).valueOrNull ?? const <MembreGroupeEntity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignmeCompactDropdown<_Choix<String>>(
          label: 'Communiqué (optionnel)',
          hint: 'Sélectionner un communiqué',
          value: _communique,
          items: [_aucunCommunique, for (final c in communiques) _Choix(c.uuid, c.titre)],
          itemLabel: (c) => c.libelle,
          enabled: !_saving,
          onChanged: (c) => setState(() => _communique = c ?? _aucunCommunique),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        SignmeCompactDropdown<_Choix<int>>(
          label: 'Remis par un membre (optionnel)',
          hint: 'Sélectionner un membre du groupe',
          value: _membre,
          items: [_aucunMembre, for (final m in membres) _Choix(m.id, m.nom)],
          itemLabel: (m) => m.libelle,
          enabled: !_saving,
          onChanged: (m) => setState(() => _membre = m ?? _aucunMembre),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        GroupeField(
          controller: _montant,
          hint: 'Montant reçu',
          icon: Icons.payments_outlined,
          suffixText: 'FCFA',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textStyle: SignmeTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: SignmeSpacing.md),
        // Donateur extérieur au groupe (ex. le parrain) : seulement si aucun membre n'est choisi.
        if (_membre.valeur == null) ...[
          GroupeField(controller: _donateur, hint: 'Autre donateur (ex. le parrain)', icon: Icons.person_outline_rounded, maxLength: 150),
          const SizedBox(height: SignmeSpacing.md),
        ],
        GroupeField(controller: _note, hint: 'Note (optionnelle)', icon: Icons.notes_rounded, maxLength: 255),
        if (_error != null) ...[
          const SizedBox(height: SignmeSpacing.md),
          Text(_error!, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
        ],
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(
          label: 'Enregistrer',
          icon: Icons.check_rounded,
          enabled: _valeur > 0,
          isLoading: _saving,
          onPressed: _submit,
        ),
      ],
    );
  }
}

/// Une ligne d'un sélecteur facultatif : [valeur] null = « Aucun ». Égalité par
/// valeur (le menu retrouve la ligne sélectionnée après chaque reconstruction).
class _Choix<T> {
  const _Choix(this.valeur, this.libelle);

  final T? valeur;
  final String libelle;

  @override
  bool operator ==(Object other) => other is _Choix<T> && other.valeur == valeur;

  @override
  int get hashCode => valeur.hashCode;
}
