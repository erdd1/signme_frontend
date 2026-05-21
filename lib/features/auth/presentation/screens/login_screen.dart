import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();
  bool  _rememberMe = false;

  late final AnimationController _animCtrl;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    // Forcer la barre de statut transparente
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref.read(authNotifierProvider.notifier).login(
      email:      _emailCtrl.text.trim(),
      password:   _passCtrl.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      final failure = ref.read(authNotifierProvider).failure;
      if (failure != null) AppSnackbar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final size      = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  // Responsive: centré sur tablette
                  final w = constraints.maxWidth > 480 ? 440.0 : double.infinity;
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // ── Logo ────────────────────────────────────
                              _buildLogo(size),
                              const SizedBox(height: 28),

                              // ── Titre ───────────────────────────────────
                              Text(
                                AppStrings.welcome,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.loginSubtitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 36),

                              // ── Email ────────────────────────────────────
                              AppTextField(
                                label:      AppStrings.email,
                                hint:       AppStrings.emailHint,
                                controller: _emailCtrl,
                                focusNode:  _emailFocus,
                                leadingIcon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                onSubmitted: (_) => _passFocus.requestFocus(),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return AppStrings.requiredField;
                                  if (!v.contains('@') || !v.contains('.')) return AppStrings.invalidEmail;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // ── Mot de passe ─────────────────────────────
                              AppTextField(
                                label:      AppStrings.password,
                                hint:       AppStrings.passwordHint,
                                controller: _passCtrl,
                                focusNode:  _passFocus,
                                leadingIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onSubmitted: (_) => _login(),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return AppStrings.requiredField;
                                  if (v.length < 6)           return AppStrings.minPassword;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // ── Forgot password ───────────────────────────
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => context.push(AppRoutes.forgotPassword),
                                  child: Text(
                                    AppStrings.forgotPassword,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Bouton connexion ──────────────────────────
                              AppPrimaryButton(
                                label:     AppStrings.loginBtn,
                                onPressed: _login,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 32),

                              // ── Footer ───────────────────────────────────
                              Text(
                                AppStrings.appTagline,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.verified_user_rounded,
            size: 56,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
