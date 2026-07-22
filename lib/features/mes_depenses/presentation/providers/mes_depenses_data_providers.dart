import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/mes_depenses_remote_datasource.dart';
import '../../data/datasources/mes_depenses_local_datasource.dart';

final mesDepensesRemoteDataSourceProvider = Provider<MesDepensesRemoteDataSource>(
  (ref) => MesDepensesRemoteDataSource(ref.watch(dioProvider)),
);

final mesDepensesLocalDataSourceProvider = Provider<MesDepensesLocalDataSource>(
  (_) => MesDepensesLocalDataSource(),
);

/// Année sélectionnée (jamais future — bornée à l'année courante par l'UI).
final mesDepensesYearProvider = StateProvider<int>((ref) => DateTime.now().year);

/// Mois sélectionné (null = tous les mois de l'année).
final mesDepensesMonthProvider = StateProvider<int?>((ref) => null);
