import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/users_provider.dart';
import 'user_detail_screen.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser?.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mon Profil',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        body: const Center(
          child: Text('Non authentifié'),
        ),
      );
    }

    return UserDetailScreen(userId: currentUser!.user!.id);
  }
}
