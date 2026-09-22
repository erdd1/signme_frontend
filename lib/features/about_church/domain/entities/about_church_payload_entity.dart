import 'about_article_entity.dart';
import 'church_about_info_entity.dart';
import 'church_summary_entity.dart';

/// Payload agrégé unique de la page "À propos de mon Église" — combine en un
/// seul appel réseau les infos de l'église, les infos permanentes du Card
/// principal et la liste complète des articles (voir
/// AboutChurchArticleService::listForChurch côté backend : le filtrage par
/// catégorie se fait ici, côté client, sur cette même liste).
class AboutChurchPayloadEntity {
  const AboutChurchPayloadEntity({
    required this.church,
    required this.info,
    required this.articles,
  });

  final ChurchSummaryEntity church;
  final ChurchAboutInfoEntity info;
  final List<AboutArticleEntity> articles;

  factory AboutChurchPayloadEntity.fromJson(Map<String, dynamic> json) {
    return AboutChurchPayloadEntity(
      church: ChurchSummaryEntity.fromJson(json['church'] as Map<String, dynamic>),
      info: ChurchAboutInfoEntity.fromJson(json['info'] as Map<String, dynamic>),
      articles: (json['articles'] as List? ?? [])
          .whereType<Map>()
          .map((e) => AboutArticleEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Pasteurs actuels épinglés, triés par ordre d'épinglage (le plus ancien
  /// épinglé en premier) — alimente le carrousel "Pasteur Actuel".
  List<AboutArticleEntity> get pinnedPastors => _pinnedOfType(AboutArticleEntity.typePastor);

  /// Groupes épinglés — alimente le carrousel "Nos groupes".
  List<AboutArticleEntity> get pinnedGroups => _pinnedOfType(AboutArticleEntity.typeGroup);

  /// Activités épinglées — alimente le carrousel "Activités majeures".
  List<AboutArticleEntity> get pinnedActivities => _pinnedOfType(AboutArticleEntity.typeActivity);

  List<AboutArticleEntity> _pinnedOfType(String type) {
    final list = articles.where((a) => a.type == type && a.isPinned).toList();
    list.sort((a, b) {
      final da = a.pinnedAt;
      final db = b.pinnedAt;
      if (da == null || db == null) return 0;
      return da.compareTo(db);
    });
    return list;
  }
}
