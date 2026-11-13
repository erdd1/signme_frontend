import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../main/presentation/screens/main_shell.dart' show kFloatingNavClearance;
import '../../domain/entities/church_about_info_entity.dart';
import '../providers/about_church_provider.dart';
import '../../../../core/network/dio_exception_mapper.dart';

/// Formulaire d'édition des infos permanentes du Card principal
/// ("À propos de mon Église") — district, horaires de culte, activités
/// majeures. Réservé pasteur/secrétaire (accès contrôlé en amont par le
/// bouton crayon sur [AboutHeaderCard], visible seulement pour ces rôles).
class EditChurchInfoScreen extends ConsumerStatefulWidget {
  const EditChurchInfoScreen({super.key});

  @override
  ConsumerState<EditChurchInfoScreen> createState() => _EditChurchInfoScreenState();
}

class _EditChurchInfoScreenState extends ConsumerState<EditChurchInfoScreen> {
  static const _maxActivites = 5;
  static const _maxLongueurActivite = 80;

  final _formKey = GlobalKey<FormState>();
  final _districtCtrl = TextEditingController();
  final _horairesCtrl = TextEditingController();
  final List<TextEditingController> _activiteCtrls = [];
  bool _isSaving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _districtCtrl.dispose();
    _horairesCtrl.dispose();
    for (final c in _activiteCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefillIfNeeded(ChurchAboutInfoEntity info) {
    if (_prefilled) return;
    _prefilled = true;
    _districtCtrl.text = info.district ?? '';
    _horairesCtrl.text = info.horairesCulte ?? '';
    _activiteCtrls.addAll(info.activitesMajeures.map((a) => TextEditingController(text: a)));
  }

  void _addActivite() {
    if (_activiteCtrls.length >= _maxActivites) return;
    setState(() => _activiteCtrls.add(TextEditingController()));
  }

  void _removeActivite(int index) {
    setState(() => _activiteCtrls.removeAt(index).dispose());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final district = _districtCtrl.text.trim();
      final horaires = _horairesCtrl.text.trim();
      final activites = _activiteCtrls
          .map((c) => c.text.trim())
          .where((a) => a.isNotEmpty)
          .toList();

      await ref.read(aboutChurchProvider.notifier).updateInfo({
        'district': district.isEmpty ? null : district,
        'horairesCulte': horaires.isEmpty ? null : horaires,
        'activitesMajeures': activites,
      });
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) AppSnackbar.error(context, messageFromError(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = ref.watch(aboutChurchProvider).asData?.value;
    if (payload != null) _prefillIfNeeded(payload.info);

    return SignmeUnsavedChangesGuard(
      child: Scaffold(
        backgroundColor: SignmeColors.white,
        appBar: SignmePageAppBar(
          title: 'Infos de l\'Église',
          backEnabled: !_isSaving,
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
              SignmeTextInput(
                label: 'District',
                hint: 'Ex. District de Yaoundé',
                controller: _districtCtrl,
                enabled: !_isSaving,
                maxLength: 150,
              ),
              const SizedBox(height: SignmeSpacing.lg),
              SignmeTextInput(
                label: 'Horaires de culte',
                hint: 'Ex. Dimanche 9h - 12h',
                controller: _horairesCtrl,
                enabled: !_isSaving,
                maxLength: 255,
              ),
              const SizedBox(height: SignmeSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activités majeures (max $_maxActivites)',
                    style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_activiteCtrls.length < _maxActivites)
                    TextButton.icon(
                      onPressed: _isSaving ? null : _addActivite,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Ajouter'),
                    ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.sm),
              for (var i = 0; i < _activiteCtrls.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: SignmeTextInput(
                          label: 'Activité ${i + 1}',
                          hint: 'Ex. Réunion de prière',
                          controller: _activiteCtrls[i],
                          enabled: !_isSaving,
                          maxLength: _maxLongueurActivite,
                          validator: (v) => (v != null && v.length > _maxLongueurActivite)
                              ? 'Doit tenir sur une ligne (max $_maxLongueurActivite caractères)'
                              : null,
                        ),
                      ),
                      IconButton(
                        onPressed: _isSaving ? null : () => _removeActivite(i),
                        icon: const Icon(Icons.close_rounded, color: SignmeColors.error),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: SignmeSpacing.xl),
              SignmePrimaryButton(
                label: 'Enregistrer',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
