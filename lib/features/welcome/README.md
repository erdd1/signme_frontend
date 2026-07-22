# Welcome Feature - Clean Architecture

## 📁 Structure

```
welcome/
├── domain/
│   ├── entities/
│   │   └── onboarding_entity.dart      # Entité métier pour les pages
│   └── index.dart
├── presentation/
│   ├── screens/
│   │   ├── welcome_screen.dart         # Écran principal orchestrant tout
│   │   └── index.dart
│   ├── widgets/
│   │   ├── onboarding_page.dart        # Widget pour une page d'onboarding
│   │   ├── page_indicator.dart         # Widget des indicateurs (dots)
│   │   ├── welcome_action_buttons.dart # Widget des boutons d'action
│   │   └── index.dart
│   ├── utils/
│   │   ├── welcome_data.dart           # Constantes et données d'onboarding
│   │   └── index.dart
│   └── index.dart
└── index.dart
```

## 🎯 Responsabilités

### Domain Layer
- **OnboardingEntity**: Représente une page d'onboarding avec ses propriétés (titre, sous-titre, description, image)

### Presentation Layer

#### Screens
- **WelcomeScreen**: Orchestrateur principal
  - Gère le PageController
  - Gère les animations (fade, scroll)
  - Coordonne les événements (page change, next, skip)
  - Navigue vers la page login avec `context.go(AppRoutes.login)`

#### Widgets
- **OnboardingPage**: Affiche une seule page d'onboarding
  - Animation de fade
  - Affichage SVG de l'image
  - Typographie professionnelle
  
- **PageIndicator**: Indicateurs visuels du carrousel
  - Dots animés
  - Largeur variable selon la page active
  
- **WelcomeActionButtons**: Boutons d'action
  - Bouton primaire (Suivant/Commencer)
  - Bouton secondaire (Passer)
  - Texte adapté selon la position

#### Utils
- **WelcomeData**: Container pour les constantes
  - Liste des 3 pages d'onboarding
  - Durées d'animation réutilisables

## 🔄 Navigation

### Splash → Welcome
```dart
if (!next.isAuthenticated) {
  context.go(AppRoutes.welcome);
}
```

### Welcome → Login
```dart
void _navigateToLogin() {
  context.go(AppRoutes.login);
}
```

## 🎨 Design System

Tous les widgets utilisent :
- `SignmeColors`: Palette de couleurs
- `SignmeTypography`: Styles de texte
- `SignmeSpacing`: Espacements et dimensions

## 🔧 Amélioration Possible

Pour une scalabilité future (optionnel) :
- Ajouter un repository pour récupérer les pages depuis une source
- Créer un ViewModel/StateNotifier si besoin de logique complexe
- Ajouter des tests unitaires pour les entités
- Implémenter la persistance de l'état (page visitée)

## 📝 Notes d'Architecture

✅ **Clean Architecture**: Séparation claire domain/presentation
✅ **Features-First**: Feature autonome et réutilisable
✅ **Single Responsibility**: Chaque widget a une responsabilité unique
✅ **Composition**: WelcomeScreen compose les widgets
✅ **Navigation Professionnelle**: Utilise GoRouter comme les autres routes
