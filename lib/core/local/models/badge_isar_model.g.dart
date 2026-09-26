// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_isar_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBadgeIsarModelCollection on Isar {
  IsarCollection<BadgeIsarModel> get badgeIsarModels => this.collection();
}

const BadgeIsarModelSchema = CollectionSchema(
  name: r'BadgeIsarModel',
  id: 5417994865697023577,
  properties: {
    r'annonces': PropertySchema(
      id: 0,
      name: r'annonces',
      type: IsarType.long,
    ),
    r'evenements': PropertySchema(
      id: 1,
      name: r'evenements',
      type: IsarType.long,
    ),
    r'historique': PropertySchema(
      id: 2,
      name: r'historique',
      type: IsarType.long,
    ),
    r'historiqueSignatures': PropertySchema(
      id: 3,
      name: r'historiqueSignatures',
      type: IsarType.long,
    ),
    r'meditations': PropertySchema(
      id: 4,
      name: r'meditations',
      type: IsarType.long,
    )
  },
  estimateSize: _badgeIsarModelEstimateSize,
  serialize: _badgeIsarModelSerialize,
  deserialize: _badgeIsarModelDeserialize,
  deserializeProp: _badgeIsarModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _badgeIsarModelGetId,
  getLinks: _badgeIsarModelGetLinks,
  attach: _badgeIsarModelAttach,
  version: '3.1.0+1',
);

int _badgeIsarModelEstimateSize(
  BadgeIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _badgeIsarModelSerialize(
  BadgeIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.annonces);
  writer.writeLong(offsets[1], object.evenements);
  writer.writeLong(offsets[2], object.historique);
  writer.writeLong(offsets[3], object.historiqueSignatures);
  writer.writeLong(offsets[4], object.meditations);
}

BadgeIsarModel _badgeIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BadgeIsarModel();
  object.annonces = reader.readLong(offsets[0]);
  object.evenements = reader.readLong(offsets[1]);
  object.historique = reader.readLong(offsets[2]);
  object.historiqueSignatures = reader.readLong(offsets[3]);
  object.id = id;
  object.meditations = reader.readLong(offsets[4]);
  return object;
}

P _badgeIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _badgeIsarModelGetId(BadgeIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _badgeIsarModelGetLinks(BadgeIsarModel object) {
  return [];
}

void _badgeIsarModelAttach(
    IsarCollection<dynamic> col, Id id, BadgeIsarModel object) {
  object.id = id;
}

extension BadgeIsarModelQueryWhereSort
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QWhere> {
  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BadgeIsarModelQueryWhere
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QWhereClause> {
  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BadgeIsarModelQueryFilter
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QFilterCondition> {
  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      annoncesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'annonces',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      annoncesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'annonces',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      annoncesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'annonces',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      annoncesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'annonces',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      evenementsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evenements',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      evenementsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'evenements',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      evenementsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'evenements',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      evenementsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'evenements',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      historiqueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'historique',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      historiqueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'historique',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      historiqueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'historique',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      historiqueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'historique',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      historiqueSignaturesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'historiqueSignatures',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      historiqueSignaturesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'historiqueSignatures',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      historiqueSignaturesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'historiqueSignatures',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      historiqueSignaturesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'historiqueSignatures',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      meditationsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'meditations',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      meditationsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'meditations',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      meditationsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'meditations',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterFilterCondition>
      meditationsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'meditations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BadgeIsarModelQueryObject
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QFilterCondition> {}

extension BadgeIsarModelQueryLinks
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QFilterCondition> {}

extension BadgeIsarModelQuerySortBy
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QSortBy> {
  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy> sortByAnnonces() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annonces', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByAnnoncesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annonces', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByEvenements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evenements', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByEvenementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evenements', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByHistorique() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historique', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByHistoriqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historique', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByHistoriqueSignatures() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historiqueSignatures', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByHistoriqueSignaturesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historiqueSignatures', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByMeditations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meditations', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      sortByMeditationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meditations', Sort.desc);
    });
  }
}

extension BadgeIsarModelQuerySortThenBy
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QSortThenBy> {
  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy> thenByAnnonces() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annonces', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByAnnoncesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annonces', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByEvenements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evenements', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByEvenementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evenements', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByHistorique() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historique', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByHistoriqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historique', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByHistoriqueSignatures() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historiqueSignatures', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByHistoriqueSignaturesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historiqueSignatures', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByMeditations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meditations', Sort.asc);
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QAfterSortBy>
      thenByMeditationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meditations', Sort.desc);
    });
  }
}

extension BadgeIsarModelQueryWhereDistinct
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QDistinct> {
  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QDistinct> distinctByAnnonces() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'annonces');
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QDistinct>
      distinctByEvenements() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'evenements');
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QDistinct>
      distinctByHistorique() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'historique');
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QDistinct>
      distinctByHistoriqueSignatures() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'historiqueSignatures');
    });
  }

  QueryBuilder<BadgeIsarModel, BadgeIsarModel, QDistinct>
      distinctByMeditations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meditations');
    });
  }
}

extension BadgeIsarModelQueryProperty
    on QueryBuilder<BadgeIsarModel, BadgeIsarModel, QQueryProperty> {
  QueryBuilder<BadgeIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BadgeIsarModel, int, QQueryOperations> annoncesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'annonces');
    });
  }

  QueryBuilder<BadgeIsarModel, int, QQueryOperations> evenementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'evenements');
    });
  }

  QueryBuilder<BadgeIsarModel, int, QQueryOperations> historiqueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'historique');
    });
  }

  QueryBuilder<BadgeIsarModel, int, QQueryOperations>
      historiqueSignaturesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'historiqueSignatures');
    });
  }

  QueryBuilder<BadgeIsarModel, int, QQueryOperations> meditationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meditations');
    });
  }
}
