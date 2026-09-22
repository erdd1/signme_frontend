import 'dart:math';
import 'package:flutter/material.dart';

/// Forme des particules de confettis pour une occasion donnée.
enum ConfettiShape { circle, petal, egg, star }

/// Configuration visuelle d'une occasion. Clé =
/// App\Models\CelebrationType::animationKey côté backend (voir
/// CelebrationTypeSeeder). [colors] = palette des confettis (décorative,
/// vive) ; [iconColor] = teinte de l'icône centrale, choisie indépendamment
/// pour rester fidèle au sens de chaque occasion (ex. cœur rouge, pas rose
/// pâle). Le reste du dialogue (textes, boutons) respecte le design system
/// (SignmeColors/Typography/Spacing).
class CelebrationAnimationConfig {
  const CelebrationAnimationConfig({
    required this.colors,
    required this.icon,
    required this.iconColor,
    this.shape = ConfettiShape.circle,
    this.numberOfParticles = 24,
  });

  final List<Color> colors;
  final IconData icon;
  final Color iconColor;
  final ConfettiShape shape;
  final int numberOfParticles;
}

const Map<String, CelebrationAnimationConfig> kCelebrationAnimations = {
  'birthday': CelebrationAnimationConfig(
    colors: [Color(0xFFFFC107), Color(0xFFFF6F91), Color(0xFFFF9F43), Color(0xFF2979F0)],
    icon: Icons.cake_rounded,
    iconColor: Color(0xFFFF6F91),
  ),
  'new_year': CelebrationAnimationConfig(
    colors: [Color(0xFFFFD700), Color(0xFFC0C0C0), Color(0xFF2979F0), Color(0xFFFFFFFF)],
    icon: Icons.celebration_rounded,
    iconColor: Color(0xFFEDA800),
  ),
  'christmas': CelebrationAnimationConfig(
    colors: [Color(0xFFE53935), Color(0xFF43A047), Color(0xFFFFD700)],
    icon: Icons.park_rounded,
    iconColor: Color(0xFF2E7D32),
  ),
  'valentine': CelebrationAnimationConfig(
    colors: [Color(0xFFE91E63), Color(0xFFFF8FA3), Color(0xFFC2185B)],
    icon: Icons.favorite_rounded,
    iconColor: Color(0xFFD32F2F),
    shape: ConfettiShape.petal,
  ),
  'women_day': CelebrationAnimationConfig(
    colors: [Color(0xFF9C27B0), Color(0xFFFF8FA3), Color(0xFFFFD54F)],
    icon: Icons.woman_rounded,
    iconColor: Color(0xFF212121),
    shape: ConfettiShape.petal,
  ),
  'labor_day': CelebrationAnimationConfig(
    colors: [Color(0xFF2979F0), Color(0xFFB0BEC5), Color(0xFFFFFFFF)],
    icon: Icons.handyman_rounded,
    iconColor: Color(0xFF1565C0),
    numberOfParticles: 14,
  ),
  'easter': CelebrationAnimationConfig(
    colors: [Color(0xFFFFF59D), Color(0xFFF8BBD0), Color(0xFFB3E5FC), Color(0xFFC8E6C9)],
    icon: Icons.egg_rounded,
    iconColor: Color(0xFFEF6C00),
    shape: ConfettiShape.egg,
  ),
  'unity_day': CelebrationAnimationConfig(
    colors: [Color(0xFF43A047), Color(0xFFE53935), Color(0xFFFFD700)],
    icon: Icons.flag_rounded,
    iconColor: Color(0xFF2E7D32),
  ),
  'youth_day': CelebrationAnimationConfig(
    colors: [Color(0xFFFF6F91), Color(0xFFFFD700), Color(0xFF2979F0), Color(0xFF43A047)],
    icon: Icons.auto_awesome_rounded,
    iconColor: Color(0xFFE65100),
  ),
};

const _fallback = CelebrationAnimationConfig(
  colors: [Color(0xFFFFC107), Color(0xFF2979F0)],
  icon: Icons.emoji_events_rounded,
  iconColor: Color(0xFFEDA800),
);

CelebrationAnimationConfig animationFor(String key) => kCelebrationAnimations[key] ?? _fallback;

/// Chemins de particules custom pour confetti — pétale (Saint-Valentin,
/// journée de la femme) et œuf pastel (Pâques). `circle`/`star` utilisent
/// les formes natives du package `confetti`.
Path Function(Size)? particlePathFor(ConfettiShape shape) {
  switch (shape) {
    case ConfettiShape.petal:
      return (size) {
        final path = Path();
        final w = size.width, h = size.height;
        path.moveTo(w / 2, 0);
        path.quadraticBezierTo(w, h / 3, w / 2, h);
        path.quadraticBezierTo(0, h / 3, w / 2, 0);
        path.close();
        return path;
      };
    case ConfettiShape.egg:
      return (size) {
        final path = Path();
        final w = size.width, h = size.height;
        path.addOval(Rect.fromLTWH(0, h * 0.15, w, h * 0.85));
        return path;
      };
    case ConfettiShape.star:
      return (size) => _starPath(size);
    case ConfettiShape.circle:
      return null;
  }
}

Path _starPath(Size size) {
  const points = 5;
  final path = Path();
  final center = Offset(size.width / 2, size.height / 2);
  final outerRadius = size.width / 2;
  final innerRadius = outerRadius / 2.5;

  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = (pi / points) * i - pi / 2;
    final point = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  path.close();
  return path;
}
