import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_feedback.dart';
import '../widgets/auth_screen_header.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const OTPVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _countdownTimer;
  int _remainingSeconds = 0; // 0 = peut renvoyer
  int _resendAttempts = 0;   // nombre de renvois effectués (max 3)
  int _totalAttempts = 0;    // tentatives de vérification (max 5)

  // Délais progressifs en minutes : 1ʳᵉ → 1 min, 2ᵉ → 2 min, 3ᵉ → 5 min
  static const List<int> _resendDelaysMinutes = [1, 2, 5];
  static const int _maxResendAttempts = 3;
  static const int _maxVerifyAttempts = 5;

  @override
  void initState() {
    super.initState();
    // Le code vient d'être envoyé (depuis l'écran "mot de passe oublié") :
    // le backend applique déjà un délai avant le premier renvoi autorisé,
    // donc on démarre le décompte tout de suite plutôt qu'au premier clic.
    _startResendCountdown(_resendDelaysMinutes[0] * 60);
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _focusNode.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Countdown ────────────────────────────────────────────────────────────

  void _startResendCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() => _remainingSeconds = seconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          timer.cancel();
        }
      });
    });
  }

  // ── Vérification OTP ─────────────────────────────────────────────────────

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      showAuthFailure(
        context,
        ServerFailure(message: 'Veuillez entrer les 6 chiffres.'),
      );
      return;
    }

    _focusNode.unfocus();

    if (_totalAttempts >= _maxVerifyAttempts) {
      showAuthFailure(
        context,
        ServerFailure(message: 'Trop de tentatives. Veuillez réessayer plus tard.'),
      );
      return;
    }

    setState(() => _totalAttempts++);

    final result = await ref
        .read(authNotifierProvider.notifier)
        .verifyPasswordResetOTP(email: widget.email, otp: otp);

    if (!mounted) return;

    if (result == null) {
      final failure = ref.read(authNotifierProvider).failure;
      if (failure != null) showAuthFailure(context, failure);
      _otpCtrl.clear();
    } else {
      final resetToken = result['reset_token'] as String?;
      if (resetToken != null) {
        context.push(
          '${AppRoutes.resetPassword}'
              '?email=${Uri.encodeComponent(widget.email)}'
              '&reset_token=${Uri.encodeComponent(resetToken)}',
        );
      }
    }
  }

  // ── Renvoi OTP ───────────────────────────────────────────────────────────

  Future<void> _resend() async {
    if (_resendAttempts >= _maxResendAttempts) return;
    if (_remainingSeconds > 0) return;

    _focusNode.unfocus();

    final result = await ref
        .read(authNotifierProvider.notifier)
        .resendPasswordResetOTP(email: widget.email);

    if (!mounted) return;

    if (result == null) {
      final failure = ref.read(authNotifierProvider).failure;
      if (failure != null) showAuthFailure(context, failure);

      // Le backend refuse le renvoi car le délai d'attente n'est pas encore
      // écoulé (cas où le compte à rebours local a dérivé) : on resynchronise
      // le décompte visuel sur le `retry_after` reçu, qui est la valeur de
      // référence — ça couvre les 3 paliers (1/2/5 min) sans dupliquer
      // l'escalade côté frontend.
      if (failure is RateLimitFailure && failure.retryAfterSeconds != null) {
        _startResendCountdown(failure.retryAfterSeconds!);
      }
    } else {
      // Incrémenter seulement après succès, puis lancer le countdown sur la
      // valeur authoritative renvoyée par le backend (palier suivant de
      // l'escalade 1/2/5 min) — évite de dupliquer cette logique ici.
      final nextResendInSeconds = result['next_resend_in_seconds'] as int? ??
          (_resendDelaysMinutes[_resendAttempts.clamp(0, 2)] * 60);
      setState(() => _resendAttempts++);
      _startResendCountdown(nextResendInSeconds);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Code renvoyé à votre email.'),
          backgroundColor: SignmeColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    // États du bouton Renvoyer
    final bool isCountingDown = _remainingSeconds > 0;
    final bool resendExhausted = _resendAttempts >= _maxResendAttempts;
    final bool canResend = !isCountingDown && !resendExhausted;

    // Formatage MM:SS
    final String countdownLabel =
        '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}'
        ':${(_remainingSeconds % 60).toString().padLeft(2, '0')}';

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
          onPressed: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: SignmeSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────
              const AuthScreenHeader(
                title: 'Vérifiez votre code',
                subtitle: 'Saisissez les 6 chiffres reçus par email',
                logoSize: 72,
              ),
              const SizedBox(height: SignmeSpacing.lg),

              // ── Email affiché ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SignmeSpacing.lg,
                  vertical: SignmeSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: SignmeColors.lightGray,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                ),
                child: Text(
                  widget.email,
                  style: SignmeTypography.bodyMedium.copyWith(
                    color: SignmeColors.mediumGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: SignmeSpacing.lg),

              // ── Pinput OTP ────────────────────────────────────────────
              // Taille des cases calculée depuis la largeur disponible (et
              // non fixée à 50px) pour éviter tout débordement sur les
              // téléphones étroits (~360dp) tout en restant confortable sur
              // les écrans larges.
              LayoutBuilder(
                builder: (context, constraints) {
                  const separatorWidth = 8.0;
                  const separatorsCount = 5;
                  final pinSize = ((constraints.maxWidth - separatorWidth * separatorsCount) / 6)
                      .clamp(40.0, 56.0);
                  return Pinput(
                    controller: _otpCtrl,
                    focusNode: _focusNode,
                    length: 6,
                    showCursor: true,
                    separatorBuilder: (_) => const SizedBox(width: separatorWidth),
                    onCompleted: (_) { if (!isLoading) _verify(); },
                    defaultPinTheme: _pinTheme(
                      size: pinSize,
                      borderColor: const Color(0xFF333333),
                      borderWidth: 1.5,
                    ),
                    focusedPinTheme: _pinTheme(
                      size: pinSize,
                      borderColor: SignmeColors.primaryLight,
                      borderWidth: 2,
                    ),
                    submittedPinTheme: _pinTheme(
                      size: pinSize,
                      borderColor: SignmeColors.success,
                      borderWidth: 2,
                    ),
                    errorPinTheme: _pinTheme(
                      size: pinSize,
                      borderColor: SignmeColors.error,
                      borderWidth: 2,
                    ),
                  );
                },
              ),
              const SizedBox(height: SignmeSpacing.lg),

              // ── Bouton Vérifier ───────────────────────────────────────
              SignmePrimaryButton(
                label: 'Vérifier',
                isLoading: isLoading,
                onPressed: isLoading ? null : _verify,
              ),
              const SizedBox(height: SignmeSpacing.md),

              // ── Ligne "Renvoyer" ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous n'avez pas reçu le code ? ",
                    style: SignmeTypography.bodyMedium.copyWith(
                      color: SignmeColors.mediumGray,
                    ),
                  ),
                  // Bouton Renvoyer : actif / grisé / épuisé
                  if (resendExhausted)
                    Text(
                      'Trop de renvois',
                      style: SignmeTypography.labelMedium.copyWith(
                        color: SignmeColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: canResend ? _resend : null,
                      child: Text(
                        'Renvoyer',
                        style: SignmeTypography.labelMedium.copyWith(
                          // Bleu si cliquable, gris si countdown en cours
                          color: canResend
                              ? SignmeColors.primaryLight
                              : SignmeColors.mediumGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.sm),

              // ── Compte à rebours MM:SS (visible uniquement si actif) ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isCountingDown
                    ? Text(
                  'Veuillez réessayer dans $countdownLabel',
                  key: const ValueKey('countdown'),
                  style: SignmeTypography.bodyMedium.copyWith(
                    color: SignmeColors.primaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                    : const SizedBox(key: ValueKey('empty'), height: 20),
              ),
              const SizedBox(height: SignmeSpacing.md),

              // ── Compteur de tentatives ────────────────────────────────
              Text(
                'Tentative $_totalAttempts/$_maxVerifyAttempts',
                style: SignmeTypography.bodySmall.copyWith(
                  color: SignmeColors.mediumGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper : PinTheme ─────────────────────────────────────────────────────

  PinTheme _pinTheme({
    required double size,
    required Color borderColor,
    required double borderWidth,
  }) {
    return PinTheme(
      width: size,
      height: size,
      textStyle: SignmeTypography.headlineMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: SignmeColors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
    );
  }
}