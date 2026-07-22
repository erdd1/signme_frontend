import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../widgets/user_info.dart';
import '../widgets/general_info.dart';
import '../widgets/about_app.dart';
import '../widgets/support_and_legal_card.dart';

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SignmeSpacing.lg,
          vertical: SignmeSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserInfo(),
            const SizedBox(height: SignmeSpacing.xxxl),
            const GeneralInfo(),
            const SizedBox(height: SignmeSpacing.xxxl),
            const AboutApp(),
            const SizedBox(height: SignmeSpacing.xxxl),
            const SupportAndLegalCard(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
