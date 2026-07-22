/// SIGNME Core Widgets Library
/// 
/// All custom button, card, dialog, loader, and state widgets
/// organized with the SIGNME design system
///
/// Usage:
/// ```dart
/// import 'core/widgets/index.dart';
///
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return SignmeCard(
///       child: SignmePrimaryButton(
///         label: 'Click Me',
///         onPressed: () => print('Clicked!'),
///       ),
///     );
///   }
/// }
/// ```

// ── Buttons
export 'app_button.dart';

// ── Cards
export 'signme_card.dart';

// ── Dialogs
export 'signme_dialogs.dart';

// ── Loaders & State Indicators
export 'signme_loaders.dart';
export 'signme_async_content.dart';
export 'profile_photo_avatar.dart';
export 'profile_photo_viewer.dart';
export 'signme_role_badge.dart';
export 'signme_year_selector.dart';
export 'app_shimmer.dart';

// ── Text Fields
export 'app_text_field.dart';
export 'signme_dropdown.dart';
export 'signme_compact_dropdown.dart';
export 'signme_date_picker_field.dart';

// ── Paiement
export 'payment_method_selector.dart';


// ── Onboarding
export 'onboarding_section.dart';

// ── Other
export 'app_snackbar.dart';
export 'role_menu_drawer.dart';

// ── Badges
export 'badge_dot.dart';

// ── Filtres & avatars décoratifs
export 'signme_pill_chip.dart';
export 'signme_filter_section_header.dart';
export 'signme_leading_icon_avatar.dart';

// ── Formulaires : garde anti-perte de saisie
export 'signme_unsaved_changes_guard.dart';
