import 'package:equatable/equatable.dart';

/// Entité représentant une page d'onboarding
class OnboardingEntity extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;

  const OnboardingEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [id, title, subtitle, description, imagePath];
}
