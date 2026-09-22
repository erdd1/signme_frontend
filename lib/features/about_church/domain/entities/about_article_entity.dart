/// Article polymorphe "À propos de mon Église" — pasteur, activité majeure,
/// groupe, histoire, ou tout futur type. `type` correspond exactement aux
/// constantes App\Models\AboutChurchArticle::TYPE_* côté backend.
class AboutArticleEntity {
  const AboutArticleEntity({
    required this.uuid,
    required this.type,
    required this.titre,
    required this.contenu,
    this.images = const [],
    this.statutPasteur,
    this.isPinned = false,
    this.pinnedAt,
    this.auteurNom,
  });

  static const typePastor = 'pastor';
  static const typeActivity = 'activity';
  static const typeGroup = 'group';
  static const typeHistory = 'history';

  static const statutPasteurActuel = 'actuel';
  static const statutPasteurAncien = 'ancien';

  /// Limite absolue de longueur du contenu (en mots) — miroir exact de
  /// `App\Models\AboutChurchArticle::MAX_MOTS_CONTENU` côté backend. Distincte
  /// de la pagination d'affichage (~10 lignes/page, voir [ContentPager]).
  static const maxMotsContenu = 5000;

  final String uuid;
  final String type;
  final String titre;
  final String contenu;

  /// 0 à 3 URLs Cloudinary, dans l'ordre d'affichage.
  final List<String> images;

  /// 'actuel' | 'ancien' — uniquement pertinent si [type] == [typePastor].
  final String? statutPasteur;

  final bool isPinned;

  /// Sert uniquement au tri des carrousels (ordre d'épinglage) — jamais
  /// affiché à l'utilisateur (cette page n'affiche aucune date).
  final DateTime? pinnedAt;

  final String? auteurNom;

  bool get isPastor => type == typePastor;
  bool get isGroup => type == typeGroup;
  bool get isActivity => type == typeActivity;
  bool get isHistory => type == typeHistory;
  bool get isPasteurActuel => isPastor && statutPasteur == statutPasteurActuel;
  bool get isPasteurAncien => isPastor && statutPasteur == statutPasteurAncien;
  bool get hasImage => images.isNotEmpty;
  String? get firstImage => images.isNotEmpty ? images.first : null;

  factory AboutArticleEntity.fromJson(Map<String, dynamic> json) {
    return AboutArticleEntity(
      uuid: json['uuid']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      titre: json['titre']?.toString() ?? '',
      contenu: json['contenu']?.toString() ?? '',
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
      statutPasteur: json['statutPasteur']?.toString(),
      isPinned: json['isPinned'] == true,
      pinnedAt: json['pinnedAt'] != null
          ? DateTime.tryParse(json['pinnedAt'].toString())
          : null,
      auteurNom: json['auteurNom']?.toString(),
    );
  }
}
