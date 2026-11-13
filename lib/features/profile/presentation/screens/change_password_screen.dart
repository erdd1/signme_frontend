import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/signme_page_app_bar.dart';
import '../../../auth/domain/utils/password_policy.dart';
import '../../../auth/presentation/utils/auth_feedback.dart';
import '../../../auth/presentation/widgets/auth_asset_text_field.dart';
import '../../../auth/presentation/widgets/password_strength_indicator.dart';
import '../providers/change_password_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _currentCtrl  = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscureCurrent  = true;
  bool _obscureNew      = true;
  bool _obscureConfirm  = true;

  // ── État réactif de l'indicateur ─────────────────────────────────────────
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() {
      setState(() => _passwordValue = _passwordCtrl.text);
    });
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final result = await ref.read(changePasswordProvider.notifier).submit(
          currentPassword: _currentCtrl.text,
          password: _passwordCtrl.text,
          passwordConfirmation: _confirmCtrl.text,
        );

    if (!mounted) return;

    switch (result) {
      case ChangePasswordSuccess(:final message):
        AppSnackbar.success(context, message);
        context.go(AppRoutes.login);
      case ChangePasswordFailure(:final failure):
        showAuthFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(changePasswordProvider);

    // Bouton désactivé tant que la politique n'est pas satisfaite
    final bool passwordValid = PasswordPolicy.isValid(_passwordValue);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: SignmePageAppBar(
        title: AppStrings.changePassword,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: SignmeSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.changePasswordHint,
                  style: SignmeTypography.bodyMedium.copyWith(
                    color: SignmeColors.mediumGray,
                    height: 1.35,
                  ),
                ),
                SignmeSpacing.vGapLg,

                // ── Mot de passe actuel ──────────────────────────────────
                AuthAssetTextField(
                  label: AppStrings.currentPassword,
                  hint: AppStrings.passwordHint,
                  controller: _currentCtrl,
                  assetPath: SignmeAssets.lock,
                  isPassword: true,
                  obscureText: _obscureCurrent,
                  onToggleObscure: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.isEmpty ? AppStrings.requiredField : null,
                ),
                SignmeSpacing.vGapMd,

                // ── Nouveau mot de passe ─────────────────────────────────
                AuthAssetTextField(
                  label: AppStrings.newPassword,
                  hint: 'Min. 10 caractères avec majuscule, chiffre et symbole',
                  controller: _passwordCtrl,
                  assetPath: SignmeAssets.lock,
                  isPassword: true,
                  obscureText: _obscureNew,
                  onToggleObscure: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final policyError = PasswordPolicy.validate(v);
                    if (policyError != null) return policyError;
                    if (v == _currentCtrl.text) {
                      return AppStrings.newPasswordMustDiffer;
                    }
                    return null;
                  },
                ),

                // ── Indicateur dynamique ─────────────────────────────────
                if (_passwordValue.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: PasswordStrengthIndicator(password: _passwordValue),
                  ),
                ],

                SignmeSpacing.vGapMd,

                // ── Confirmation ─────────────────────────────────────────
                AuthAssetTextField(
                  label: AppStrings.confirmNewPassword,
                  hint: AppStrings.confirmPasswordHint,
                  controller: _confirmCtrl,
                  assetPath: SignmeAssets.lock,
                  isPassword: true,
                  obscureText: _obscureConfirm,
                  onToggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v != _passwordCtrl.text) {
                      return AppStrings.passwordMismatch;
                    }
                    return null;
                  },
                ),

                SignmeSpacing.vGapLg,

                // ── Bouton désactivé tant que les critères ne sont pas remplis
                SignmePrimaryButton(
                  label: AppStrings.savePassword,
                  isLoading: isLoading,
                  onPressed: (isLoading || !passwordValid) ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
