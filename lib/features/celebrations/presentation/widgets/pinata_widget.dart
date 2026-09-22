import 'package:flutter/material.dart';

/// Pignata virtuelle simple, construite entièrement à partir de formes
/// (aucun asset image) — bandes de couleurs façon papier crépon, franges en
/// bas, petits yeux. Utilisée pour l'occasion "anniversaire".
class PinataWidget extends StatelessWidget {
  const PinataWidget({super.key, this.size = 140});

  final double size;

  static const _stripeColors = [
    Color(0xFFFF6F91),
    Color(0xFFFFC107),
    Color(0xFF2979F0),
    Color(0xFF43A047),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.35,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 2, height: size * 0.14, color: const Color(0xFFB08968)),
          SizedBox(
            width: size,
            height: size * 0.85,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(size * 0.16),
                  child: Column(
                    children: List.generate(
                      _stripeColors.length,
                      (i) => Expanded(
                        child: Container(color: _stripeColors[i]),
                      ),
                    ),
                  ),
                ),
                // ── Yeux ──────────────────────────────────────────────────
                Positioned(
                  top: size * 0.22,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Eye(size: size * 0.16),
                      SizedBox(width: size * 0.14),
                      _Eye(size: size * 0.16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Franges ─────────────────────────────────────────────────────
          SizedBox(
            width: size,
            height: size * 0.22,
            child: ClipPath(
              clipper: _FringeClipper(),
              child: Row(
                children: List.generate(
                  5,
                  (i) => Expanded(child: Container(color: _stripeColors[i % _stripeColors.length])),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.45,
        height: size * 0.45,
        decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
      ),
    );
  }
}

class _FringeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const teeth = 5;
    final toothWidth = size.width / teeth;
    final path = Path()..moveTo(0, 0);
    for (var i = 0; i < teeth; i++) {
      path.lineTo(i * toothWidth + toothWidth / 2, size.height);
      path.lineTo((i + 1) * toothWidth, 0);
    }
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
