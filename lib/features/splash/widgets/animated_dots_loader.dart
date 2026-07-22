import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design_system/index.dart';

/// Three animated dots with a staggered fade + scale pulse.
/// Renders  "SignMe ···"  where each dot fades in/out in sequence.
class AnimatedDotsLoader extends StatefulWidget {
  const AnimatedDotsLoader({super.key});

  @override
  State<AnimatedDotsLoader> createState() => _AnimatedDotsLoaderState();
}

class _AnimatedDotsLoaderState extends State<AnimatedDotsLoader>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _opacities;

  static const int _dotCount = 3;
  static const Duration _dotDuration = Duration(milliseconds: 600);
  static const Duration _stagger = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _dotCount,
          (i) => AnimationController(vsync: this, duration: _dotDuration),
    );

    _opacities = _controllers
        .map(
          (c) => Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      ),
    )
        .toList();

    // Stagger: each dot starts its loop slightly after the previous one.
    for (var i = 0; i < _dotCount; i++) {
      Future.delayed(_stagger * i, () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "SignMe" label
        Text(
          'Bienvenue',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: SignmeColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 3),
        // Three staggered dots
        ...List.generate(_dotCount, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: AnimatedBuilder(
              animation: _opacities[i],
              builder: (_, __) => Opacity(
                opacity: _opacities[i].value,
                child: Text(
                  '.',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: SignmeColors.primary,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
