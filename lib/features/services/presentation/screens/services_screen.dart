import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/service_entity.dart';
import '../providers/services_provider.dart';
import '../widgets/service_tile.dart';

/// Écran Services : accès rapide aux actions courantes des fidèles,
/// rangées par rubrique, avec recherche.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  static const int _columns = 4;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = filterServices(ref.watch(availableServicesProvider), _controller.text);
    final sections = <String, List<ServiceEntity>>{};
    for (final service in services) {
      sections.putIfAbsent(service.section, () => []).add(service);
    }

    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    // La navbar flottante se masque avec le clavier : le contenu se dégage
    // alors au-dessus du clavier plutôt que de la navbar.
    final bottomPadding =
        keyboardInset > 0 ? keyboardInset + SignmeSpacing.lg : SignmeSpacing.navbarClearance;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          SignmeSpacing.lg,
          SignmeSpacing.sm,
          SignmeSpacing.lg,
          bottomPadding,
        ),
        children: [
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            style: SignmeTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Rechercher un service…',
              prefixIcon: const Icon(Icons.search_rounded, color: SignmeColors.mediumGray),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, color: SignmeColors.mediumGray),
                      tooltip: 'Effacer',
                      onPressed: () => setState(_controller.clear),
                    ),
              filled: true,
              fillColor: SignmeColors.accentSky.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: SignmeSpacing.xl),
          if (sections.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: SignmeSpacing.xxxl),
              child: SignmeEmptyState(
                icon: Icons.search_off_rounded,
                title: 'Aucun service trouvé',
                message: 'Essayez un autre mot, par exemple « don ».',
              ),
            ),
          for (final entry in sections.entries) ...[
            Text(
              entry.key,
              style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: SignmeSpacing.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _columns,
              mainAxisSpacing: SignmeSpacing.lg,
              crossAxisSpacing: SignmeSpacing.md,
              childAspectRatio: 0.74,
              children: [
                for (final service in entry.value)
                  ServiceTile(service: service, onTap: () => context.push(service.route)),
              ],
            ),
            const SizedBox(height: SignmeSpacing.xl),
          ],
        ],
      ),
    );
  }
}
