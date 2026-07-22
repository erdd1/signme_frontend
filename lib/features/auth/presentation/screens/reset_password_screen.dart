import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/utils/password_policy.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_feedback.dart';
import '../widgets/auth_asset_text_field.dart';
import '../widgets/auth_screen_header.dart';
import '../widgets/password_strength_indicator.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.initialEmail,
    this.initialToken,
    this.initialResetToken,
  });

  final String? initialEmail;
  final String? initialToken;
  final String? initialResetToken;

  /// Déterminer si c'est le flux OTP moderne ou l'ancien flux
  bool get isOTPFlow => initialResetToken != null && initialResetToken!.isNotEmpty;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _tokenCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  bool _obscure1      = true;
  bool _obscure2      = true;
  bool _isSubmitting  = false;

  // ── État dynamique de l'indicateur ──────────────────────────────────────
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail ?? '';
    _tokenCtrl.text = widget.initialToken ?? '';

    // Mise à jour réactive de l'indicateur à chaque frappe
    _passwordCtrl.addListener(() {
      setState(() => _passwordValue = _passwordCtrl.text);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    bool ok = false;

    if (widget.isOTPFlow) {
      ok = await ref.read(authNotifierProvider.notifier).confirmPasswordReset(
            resetToken: widget.initialResetToken!,
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            passwordConfirmation: _confirmCtrl.text,
          );
    } else {
      ok = await ref.read(authNotifierProvider.notifier).resetPassword(
            email: _emailCtrl.text.trim(),
            token: _tokenCtrl.text.trim(),
            password: _passwordCtrl.text,
            passwordConfirmation: _confirmCtrl.text,
          );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!ok) {
      final failure = ref.read(authNotifierProvider).failure;
      if (failure != null) showAuthFailure(context, failure);
      return;
    }

    AppSnackbar.success(context, 'Mot de passe réinitialisé. Connectez-vous.');
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    // Le bouton est désactivé tant que la politique n'est pas complète
    final bool passwordValid = PasswordPolicy.isValid(_passwordValue);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: SignmeColors.black,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: SignmeSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthScreenHeader(
                  title: 'Nouveau mot de passe',
                  subtitle: widget.isOTPFlow
                      ? 'Choisissez un nouveau mot de passe sécurisé.'
                      : 'Collez le code reçu par email, puis choisissez un nouveau mot de passe.',
                  logoSize: 72,
                ),
                SignmeSpacing.vGapLg,

                // ── Champs Email + Token (flux non-OTP uniquement) ──────────
                if (!widget.isOTPFlow) ...[
                  AuthAssetTextField(
                    label: AppStrings.email,
                    hint: AppStrings.emailHint,
                    controller: _emailCtrl,
                    assetPath: SignmeAssets.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return AppStrings.requiredField;
                      }
                      if (!v.contains('@')) return AppStrings.invalidEmail;
                      return null;
                    },
                  ),
                  SignmeSpacing.vGapMd,
                  AuthAssetTextField(
                    label: 'Code de réinitialisation',
                    hint: 'Collez le code de l\'email',
                    controller: _tokenCtrl,
                    assetPath: SignmeAssets.lock,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? AppStrings.requiredField : null,
                  ),
                  SignmeSpacing.vGapMd,
                ],

                // ── Champ Nouveau mot de passe ──────────────────────────────
                AuthAssetTextField(
                  label: 'Nouveau mot de passe',
                  hint: 'Min. 10 caractères avec majuscule, chiffre et symbole',
                  controller: _passwordCtrl,
                  assetPath: SignmeAssets.lock,
                  isPassword: true,
                  obscureText: _obscure1,
                  onToggleObscure: () => setState(() => _obscure1 = !_obscure1),
                  validator: PasswordPolicy.validate,
                ),

                // ── Indicateur dynamique de force ───────────────────────────
                if (_passwordValue.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: PasswordStrengthIndicator(password: _passwordValue),
                  ),
                ],

                SignmeSpacing.vGapMd,

                // ── Confirmation mot de passe ───────────────────────────────
                AuthAssetTextField(
                  label: 'Confirmer le mot de passe',
                  hint: 'Répétez le mot de passe',
                  controller: _confirmCtrl,
                  assetPath: SignmeAssets.lock,
                  isPassword: true,
                  obscureText: _obscure2,
                  onToggleObscure: () => setState(() => _obscure2 = !_obscure2),
                  validator: (v) {
                    if (v != _passwordCtrl.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                SignmeSpacing.vGapLg,

                // ── Bouton désactivé tant que les critères ne sont pas remplis
                SignmePrimaryButton(
                  label: 'Réinitialiser',
                  isLoading: _isSubmitting,
                  onPressed: (_isSubmitting || !passwordValid) ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
