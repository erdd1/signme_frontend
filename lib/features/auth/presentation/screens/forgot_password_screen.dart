import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_feedback.dart';
import '../widgets/auth_asset_text_field.dart';
import '../widgets/auth_screen_header.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).forgotPassword(
          email: _emailCtrl.text.trim(),
        );

    if (!mounted) return;
    final failure = ref.read(authNotifierProvider).failure;
    if (failure != null) {
      showAuthFailure(context, failure);
    } else {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

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
          child: _sent ? _buildSuccess() : _buildForm(authState.isLoading),
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthScreenHeader(
            title: 'Mot de passe oublié',
            subtitle: AppStrings.resetSubtitle,
            logoSize: 72,
          ),
          SignmeSpacing.vGapLg,
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
          SignmeSpacing.vGapLg,
          SignmePrimaryButton(
            label: AppStrings.sendResetLink,
            isLoading: isLoading,
            onPressed: isLoading ? null : _send,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    final email = _emailCtrl.text.trim();

    return Column(
      children: [
        SignmeSpacing.vGapLg,
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: SignmeColors.success.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 36,
            color: SignmeColors.success,
          ),
        ),
        SignmeSpacing.vGapMd,
        Text(
          'Email envoyé',
          style: SignmeTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SignmeSpacing.vGapSm,
        Text(
          'Un code OTP a été envoyé à $email.',
          textAlign: TextAlign.center,
          style: SignmeTypography.bodyMedium.copyWith(
            color: SignmeColors.mediumGray,
            height: 1.4,
          ),
        ),
        SignmeSpacing.vGapLg,
        SignmePrimaryButton(
          label: 'Saisir le code',
          onPressed: () => context.push(
            '${AppRoutes.otpVerification}?email=${Uri.encodeComponent(email)}',
          ),
        ),
        SignmeSpacing.vGapSm,
        TextButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
          child: Text(
            AppStrings.backToLogin,
            style: SignmeTypography.labelMedium.copyWith(
              color: SignmeColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
