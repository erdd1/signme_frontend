import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design_system/signme_colors.dart';

class GradientText extends StatelessWidget {

  final String text;

  const GradientText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          SignmeColors.primaryDark,
          SignmeColors.primaryLight,
        ],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}