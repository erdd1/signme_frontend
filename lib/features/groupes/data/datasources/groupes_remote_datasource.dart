import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../retraits/domain/entities/retrait_beneficiaire_entity.dart';
import '../../../retraits/domain/entities/retrait_entity.dart';
import '../../domain/entities/groupe_entities.dart';

class MouvementsPage {
  const MouvementsPage({required this.items, required this.currentPage, required this.lastPage});

  final List<MouvementEntity> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

/// Accès API du service « Groupes ». Chaque appel porte sur UN groupe dont
/// l'utilisateur est membre ; les droits par poste sont appliqués côté
/// serveur (l'interface ne fait que masquer ce qui est interdit).
class MesGroupesRemoteDataSource {
  MesGroupesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<T> _call<T>(Future<Response<dynamic>> Function() request, T Function(Response<dynamic>) parse,
      {Set<int> ok = const {200, 201}}) async {
    try {
      final resp = await request();
      if (ok.contains(resp.statusCode) && ApiResponseParser.isSuccess(resp.data)) {
        return parse(resp);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Map<String, dynamic> _map(Response<dynamic> r) =>
      ApiResponseParser.dataMap(r.data) ?? (throw ServerException(message: 'Réponse invalide.'));

  Future<List<GroupeEntity>> mesGroupes() => _call(
        () => _dio.get(ApiConfig.mesGroupes),
        (r) => ApiResponseParser.extractList(r.data).map(GroupeEntity.fromJson).toList(),
      );

  Future<GroupeEntity> groupe(String uuid) =>
      _call(() => _dio.get(ApiConfig.mesGroupe(uuid)), (r) => GroupeEntity.fromJson(_map(r)));

  Future<List<CommuniqueEntity>> communiques(String uuid) => _call(
        () => _dio.get(ApiConfig.groupeCommuniques(uuid)),
        (r) => ApiResponseParser.extractList(r.data).map(CommuniqueEntity.fromJson).toList(),
      );

  Future<CommuniqueEntity> creerCommunique(String uuid, Map<String, dynamic> data) => _call(
        () => _dio.post(ApiConfig.groupeCommuniques(uuid), data: data),
        (r) => CommuniqueEntity.fromJson(_map(r)),
      );

  Future<CommuniqueEntity> modifierCommunique(String uuid, String communiqueUuid, Map<String, dynamic> data) => _call(
        () => _dio.put(ApiConfig.groupeCommunique(uuid, communiqueUuid), data: data),
        (r) => CommuniqueEntity.fromJson(_map(r)),
      );

  Future<void> archiverCommunique(String uuid, String communiqueUuid) =>
      _call(() => _dio.delete(ApiConfig.groupeCommunique(uuid, communiqueUuid)), (_) {});

  Future<List<ContributeurEntity>> contributeurs(String uuid, String communiqueUuid) => _call(
        () => _dio.get(ApiConfig.groupeCommuniqueContributions(uuid, communiqueUuid)),
        (r) => ApiResponseParser.extractList(r.data).map(ContributeurEntity.fromJson).toList(),
      );

  Future<MouvementsPage> mouvements(String uuid, {int page = 1, int perPage = 20}) => _call(
        () => _dio.get(ApiConfig.groupeMouvements(uuid), queryParameters: {'page': page, 'per_page': perPage}),
        (r) {
          final body = r.data as Map<String, dynamic>;
          final pagination = body['pagination'] as Map<String, dynamic>?;
          return MouvementsPage(
            items: ApiResponseParser.extractList(body).map(MouvementEntity.fromJson).toList(),
            currentPage: (pagination?['current_page'] as num?)?.toInt() ?? page,
            lastPage: (pagination?['last_page'] as num?)?.toInt() ?? page,
          );
        },
      );

  Future<void> enregistrerCash(String uuid, {required int montant, String? donateur, String? note}) => _call(
        () => _dio.post(ApiConfig.groupeEntreesCash(uuid), data: {
          'montant': montant,
          if (donateur != null && donateur.isNotEmpty) 'donateur': donateur,
          if (note != null && note.isNotEmpty) 'note': note,
        }),
        (_) {},
      );

  Future<void> annulerCash(String uuid, String entreeUuid, String motif) => _call(
        () => _dio.post(ApiConfig.groupeEntreeCashAnnuler(uuid, entreeUuid), data: {'motif': motif}),
        (_) {},
      );

  Future<RetraitBeneficiaireEntity?> beneficiaire(String uuid) => _call(
        () => _dio.get(ApiConfig.groupeBeneficiaire(uuid)),
        (r) {
          final data = ApiResponseParser.dataMap(r.data);
          return data == null ? null : RetraitBeneficiaireEntity.fromJson(data);
        },
      );

  Future<RetraitBeneficiaireEntity> enregistrerBeneficiaire(String uuid,
          {required String operator, required String phone}) =>
      _call(
        () => _dio.post(ApiConfig.groupeBeneficiaire(uuid), data: {'operator': operator, 'phone': phone}),
        (r) => RetraitBeneficiaireEntity.fromJson(_map(r)),
      );

  Future<RetraitEntity> retirer(String uuid, {required int montant, required String motif}) => _call(
        () => _dio.post(ApiConfig.groupeRetraits(uuid), data: {'montant': montant, 'motif': motif}),
        (r) => RetraitEntity.fromJson(_map(r)),
      );
}
