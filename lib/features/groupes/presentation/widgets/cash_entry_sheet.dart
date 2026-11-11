import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../providers/groupes_provider.dart';
import 'groupe_sheet.dart';

/// Enregistre de l'argent reçu HORS application (cash) dans la caisse du
/// groupe — président ou trésorier. Toujours distinct de l'argent en ligne.
Future<bool?> showCashEntrySheet(BuildContext context, {required String groupeUuid}) {
  return showGroupeSheet<bool>(
    context,
    title: 'Argent reçu hors application',
    subtitle: 'Enregistrez un don reçu en main propre. Il reste séparé de l\'argent reçu par l\'application.',
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
            donateur: _donateur.text.trim(),
            note: _note.text.trim(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        GroupeField(controller: _donateur, hint: 'De la part de (ex. le parrain)', icon: Icons.person_outline_rounded, maxLength: 150),
        const SizedBox(height: SignmeSpacing.md),
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
