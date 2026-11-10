import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/index.dart';
import '../providers/chants_provider.dart';

/// Feuille de réglage de la taille du texte des paroles.
Future<void> showChantTextSizeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: SignmeColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(SignmeSpacing.radiusXl)),
    ),
    builder: (_) => const _ChantTextSizeSheet(),
  );
}

class _ChantTextSizeSheet extends ConsumerWidget {
  const _ChantTextSizeSheet();

  static const double _min = 0.85;
  static const double _max = 1.6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(chantTextScaleProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SignmeSpacing.xl,
          SignmeSpacing.xl,
          SignmeSpacing.xl,
          SignmeSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Taille du texte', style: SignmeTypography.headlineSmall),
            const SizedBox(height: SignmeSpacing.md),
            Row(
              children: [
                Text('A', style: SignmeTypography.bodySmall),
                Expanded(
                  child: Slider(
                    value: scale.clamp(_min, _max),
                    min: _min,
                    max: _max,
                    divisions: 6,
                    activeColor: SignmeColors.primaryLight,
                    onChanged: (v) => ref.read(chantTextScaleProvider.notifier).state = v,
                  ),
                ),
                Text('A', style: SignmeTypography.headlineMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
