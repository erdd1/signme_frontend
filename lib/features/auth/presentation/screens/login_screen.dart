import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_feedback.dart';
import '../widgets/auth_asset_text_field.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_screen_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  bool _isObscured = true;
  bool _credentialsLoaded = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final email = await ref.read(secureStorageProvider).getRememberedEmail();
    if (!mounted) return;
    setState(() {
      if (email != null && email.isNotEmpty) {
        _emailController.text = email;
      }
      _credentialsLoaded = true;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref.read(authNotifierProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (!ok) {
      final failure = ref.read(authNotifierProvider).failure;
      if (failure != null) showAuthFailure(context, failure);
    }
  }

  Future<void> _performGoogleLogin() async {
    FocusScope.of(context).unfocus();

    final ok = await ref.read(authNotifierProvider.notifier).loginWithGoogle();

    if (!mounted) return;
    if (!ok) {
      // Pas de message si l'utilisateur a simplement annulé (pas de failure posée).
      final failure = ref.read(authNotifierProvider).failure;
      if (failure != null) showAuthFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: SignmeSpacing.screenPaddingHorizontal,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header : logo + titre + subtitle ──────────────────
                  const SizedBox(height: SignmeSpacing.xxl),
                  const AuthScreenHeader(
                    subtitle: AppStrings.loginSubtitle,
                    logoSize: 88,
                  ),
                  const SizedBox(height: SignmeSpacing.xxl),

                  // ── Bannière rate-limit ────────────────────────────────
                  if (authState.failure is RateLimitFailure) ...[
                    AuthMessageBanner(
                      message: authState.failure!.message,
                      icon: Icons.timer_outlined,
                    ),
                    const SizedBox(height: SignmeSpacing.md),
                  ],

                  // ── Champ email ───────────────────────────────────────
                  AuthAssetTextField(
                    label: AppStrings.email,
                    hint: AppStrings.emailHint,
                    controller: _emailController,
                    assetPath: SignmeAssets.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: _credentialsLoaded && !authState.isLoading,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return AppStrings.requiredField;
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                        return AppStrings.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: SignmeSpacing.md),

                  // ── Champ mot de passe ────────────────────────────────
                  AuthAssetTextField(
                    label: AppStrings.password,
                    hint: AppStrings.passwordHint,
                    controller: _passwordController,
                    assetPath: SignmeAssets.lock,
                    isPassword: true,
                    obscureText: _isObscured,
                    onToggleObscure: () =>
                        setState(() => _isObscured = !_isObscured),
                    textInputAction: TextInputAction.done,
                    enabled: !authState.isLoading,
                    onChanged: (_) {},
                    validator: (v) => v == null || v.isEmpty
                        ? AppStrings.requiredField
                        : null,
                  ),
                  const SizedBox(height: SignmeSpacing.sm),

                  // ── Mot de passe oublié ───────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => context.push(AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SignmeSpacing.md,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.forgotPassword,
                          style: SignmeTypography.labelMedium.copyWith(
                            color: SignmeColors.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SignmeSpacing.xxl),

                  // ── Bouton Se connecter (pill shape) ──────────────────
                  _LoginButton(
                    isLoading: authState.isLoading,
                    onPressed: authState.isLoading ? null : _performLogin,
                  ),
                  const SizedBox(height: SignmeSpacing.xl),

                  // ── Divider "ou continuer avec" ───────────────────────
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: SignmeColors.lightGrayBorder),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SignmeSpacing.md,
                        ),
                        child: Text(
                          'ou continuer avec',
                          style: SignmeTypography.bodySmall.copyWith(
                            color: SignmeColors.mediumGray,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: SignmeColors.lightGrayBorder),
                      ),
                    ],
                  ),
                  const SizedBox(height: SignmeSpacing.md),

                  // ── Bouton Google (même forme que "Se connecter") ─────
                  _SocialButton(
                    imagePath: SignmeAssets.google,
                    label: 'Google',
                    isLoading: authState.isLoading,
                    onTap: authState.isLoading ? null : _performGoogleLogin,
                  ),
                  const SizedBox(height: SignmeSpacing.xl),

                  // ── Footer sécurité ───────────────────────────────────
                  const _SecurityFooter(),
                  const SizedBox(height: SignmeSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bouton connexion pill ──────────────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SignmeSpacing.buttonHeight,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? const LinearGradient(
          colors: SignmeColors.buttonGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : const LinearGradient(
          colors: [SignmeColors.disabled, SignmeColors.disabled],
        ),
        borderRadius: BorderRadius.circular(
          SignmeSpacing.radiusFull, // pill
        ),
        boxShadow: onPressed != null
            ? [
          BoxShadow(
            color: SignmeColors.primaryLight.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation(SignmeColors.onPrimary),
              ),
            )
                : Text(
              AppStrings.loginBtn,
              style: SignmeTypography.buttonText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bouton social ─────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String imagePath;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
      child: Container(
        height: SignmeSpacing.buttonHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: SignmeColors.lightGrayBorder,
            width: SignmeSpacing.borderMedium,
          ),
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
          color: SignmeColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SignmeColors.mediumGray,
                ),
              )
            else
              Image.asset(imagePath, width: 22, height: 22),
            const SizedBox(width: SignmeSpacing.sm),
            Text(
              label,
              style: SignmeTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Footer "données sécurisées" ───────────────────────────────────────────
class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(SignmeSpacing.sm),
          decoration: const BoxDecoration(
            color: SignmeColors.accentSky,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.security_rounded,
            size: 18,
            color: SignmeColors.primaryLight,
          ),
        ),
        const SizedBox(width: SignmeSpacing.sm),
        Flexible(
          child: Text(
            'Vos données sont sécurisées et\nprotégées avec le plus grand soin.',
            style: SignmeTypography.bodySmall.copyWith(
              color: SignmeColors.mediumGray,
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
