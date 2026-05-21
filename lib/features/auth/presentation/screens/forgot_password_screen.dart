import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _sent      = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier)
        .forgotPassword(email: _emailCtrl.text.trim());

    if (!mounted) return;
    final failure = ref.read(authNotifierProvider).failure;
    if (failure != null) {
      AppSnackbar.error(context, failure.message);
    } else {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _sent ? _buildSuccess() : _buildForm(isLoading),
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            AppStrings.resetPassword,
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.resetSubtitle,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),
          AppTextField(
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            controller: _emailCtrl,
            leadingIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _send(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return AppStrings.requiredField;
              if (!v.contains('@')) return AppStrings.invalidEmail;
              return null;
            },
          ),
          const SizedBox(height: 32),
          AppPrimaryButton(
            label: AppStrings.sendResetLink,
            onPressed: _send,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded, size: 40, color: AppColors.success),
        ),
        const SizedBox(height: 24),
        Text(
          'Email envoyé !',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          'Vérifiez votre boîte mail et suivez les instructions pour réinitialiser votre mot de passe.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 36),
        AppPrimaryButton(
          label: AppStrings.backToLogin,
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
