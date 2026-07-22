// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evenement_isar_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEvenementIsarModelCollection on Isar {
  IsarCollection<EvenementIsarModel> get evenementIsarModels =>
      this.collection();
}

const EvenementIsarModelSchema = CollectionSchema(
  name: r'EvenementIsarModel',
  id: 3676755993624794154,
  properties: {
    r'archivedAt': PropertySchema(
      id: 0,
      name: r'archivedAt',
      type: IsarType.dateTime,
    ),
    r'auteurId': PropertySchema(
      id: 1,
      name: r'auteurId',
      type: IsarType.long,
    ),
    r'auteurNom': PropertySchema(
      id: 2,
      name: r'auteurNom',
      type: IsarType.string,
    ),
    r'auteurPhotoUrl': PropertySchema(
      id: 3,
      name: r'auteurPhotoUrl',
      type: IsarType.string,
    ),
    r'churchId': PropertySchema(
      id: 4,
      name: r'churchId',
      type: IsarType.long,
    ),
    r'churchNom': PropertySchema(
      id: 5,
      name: r'churchNom',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dateDebut': PropertySchema(
      id: 7,
      name: r'dateDebut',
      type: IsarType.dateTime,
    ),
    r'dateFin': PropertySchema(
      id: 8,
      name: r'dateFin',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 9,
      name: r'description',
      type: IsarType.string,
    ),
    r'estAuteur': PropertySchema(
      id: 10,
      name: r'estAuteur',
      type: IsarType.bool,
    ),
    r'imageUrl': PropertySchema(
      id: 11,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'joursAvantArchivage': PropertySchema(
      id: 12,
      name: r'joursAvantArchivage',
      type: IsarType.long,
    ),
    r'montantCollecte': PropertySchema(
      id: 13,
      name: r'montantCollecte',
      type: IsarType.long,
    ),
    r'nombreContributions': PropertySchema(
      id: 14,
      name: r'nombreContributions',
      type: IsarType.long,
    ),
    r'objectifMontant': PropertySchema(
      id: 15,
      name: r'objectifMontant',
      type: IsarType.long,
    ),
    r'peutContribuer': PropertySchema(
      id: 16,
      name: r'peutContribuer',
      type: IsarType.bool,
    ),
    r'peutGerer': PropertySchema(
      id: 17,
      name: r'peutGerer',
      type: IsarType.bool,
    ),
    r'pourcentageObjectif': PropertySchema(
      id: 18,
      name: r'pourcentageObjectif',
      type: IsarType.double,
    ),
    r'publishedAt': PropertySchema(
      id: 19,
      name: r'publishedAt',
      type: IsarType.dateTime,
    ),
    r'scheduledPublishAt': PropertySchema(
      id: 20,
      name: r'scheduledPublishAt',
      type: IsarType.dateTime,
    ),
    r'serverUuid': PropertySchema(
      id: 21,
      name: r'serverUuid',
      type: IsarType.string,
    ),
    r'statut': PropertySchema(
      id: 22,
      name: r'statut',
      type: IsarType.string,
    ),
    r'termineAt': PropertySchema(
      id: 23,
      name: r'termineAt',
      type: IsarType.dateTime,
    ),
    r'titre': PropertySchema(
      id: 24,
      name: r'titre',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 25,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _evenementIsarModelEstimateSize,
  serialize: _evenementIsarModelSerialize,
  deserialize: _evenementIsarModelDeserialize,
  deserializeProp: _evenementIsarModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'serverUuid': IndexSchema(
      id: -5197471357718218481,
      name: r'serverUuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'serverUuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'statut': IndexSchema(
      id: 898685416201145331,
      name: r'statut',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'statut',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _evenementIsarModelGetId,
  getLinks: _evenementIsarModelGetLinks,
  attach: _evenementIsarModelAttach,
  version: '3.1.0+1',
);

int _evenementIsarModelEstimateSize(
  EvenementIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.auteurNom.length * 3;
  {
    final value = object.auteurPhotoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.churchNom;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.serverUuid.length * 3;
  bytesCount += 3 + object.statut.length * 3;
  bytesCount += 3 + object.titre.length * 3;
  return bytesCount;
}

void _evenementIsarModelSerialize(
  EvenementIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.archivedAt);
  writer.writeLong(offsets[1], object.auteurId);
  writer.writeString(offsets[2], object.auteurNom);
  writer.writeString(offsets[3], object.auteurPhotoUrl);
  writer.writeLong(offsets[4], object.churchId);
  writer.writeString(offsets[5], object.churchNom);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeDateTime(offsets[7], object.dateDebut);
  writer.writeDateTime(offsets[8], object.dateFin);
  writer.writeString(offsets[9], object.description);
  writer.writeBool(offsets[10], object.estAuteur);
  writer.writeString(offsets[11], object.imageUrl);
  writer.writeLong(offsets[12], object.joursAvantArchivage);
  writer.writeLong(offsets[13], object.montantCollecte);
  writer.writeLong(offsets[14], object.nombreContributions);
  writer.writeLong(offsets[15], object.objectifMontant);
  writer.writeBool(offsets[16], object.peutContribuer);
  writer.writeBool(offsets[17], object.peutGerer);
  writer.writeDouble(offsets[18], object.pourcentageObjectif);
  writer.writeDateTime(offsets[19], object.publishedAt);
  writer.writeDateTime(offsets[20], object.scheduledPublishAt);
  writer.writeString(offsets[21], object.serverUuid);
  writer.writeString(offsets[22], object.statut);
  writer.writeDateTime(offsets[23], object.termineAt);
  writer.writeString(offsets[24], object.titre);
  writer.writeDateTime(offsets[25], object.updatedAt);
}

EvenementIsarModel _evenementIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EvenementIsarModel();
  object.archivedAt = reader.readDateTimeOrNull(offsets[0]);
  object.auteurId = reader.readLong(offsets[1]);
  object.auteurNom = reader.readString(offsets[2]);
  object.auteurPhotoUrl = reader.readStringOrNull(offsets[3]);
  object.churchId = reader.readLongOrNull(offsets[4]);
  object.churchNom = reader.readStringOrNull(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.dateDebut = reader.readDateTime(offsets[7]);
  object.dateFin = reader.readDateTimeOrNull(offsets[8]);
  object.description = reader.readString(offsets[9]);
  object.estAuteur = reader.readBool(offsets[10]);
  object.id = id;
  object.imageUrl = reader.readStringOrNull(offsets[11]);
  object.joursAvantArchivage = reader.readLongOrNull(offsets[12]);
  object.montantCollecte = reader.readLong(offsets[13]);
  object.nombreContributions = reader.readLong(offsets[14]);
  object.objectifMontant = reader.readLongOrNull(offsets[15]);
  object.peutContribuer = reader.readBool(offsets[16]);
  object.peutGerer = reader.readBool(offsets[17]);
  object.pourcentageObjectif = reader.readDoubleOrNull(offsets[18]);
  object.publishedAt = reader.readDateTimeOrNull(offsets[19]);
  object.scheduledPublishAt = reader.readDateTimeOrNull(offsets[20]);
  object.serverUuid = reader.readString(offsets[21]);
  object.statut = reader.readString(offsets[22]);
  object.termineAt = reader.readDateTimeOrNull(offsets[23]);
  object.titre = reader.readString(offsets[24]);
  object.updatedAt = reader.readDateTime(offsets[25]);
  return object;
}

P _evenementIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 20:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _evenementIsarModelGetId(EvenementIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _evenementIsarModelGetLinks(
    EvenementIsarModel object) {
  return [];
}

void _evenementIsarModelAttach(
    IsarCollection<dynamic> col, Id id, EvenementIsarModel object) {
  object.id = id;
}

extension EvenementIsarModelByIndex on IsarCollection<EvenementIsarModel> {
  Future<EvenementIsarModel?> getByServerUuid(String serverUuid) {
    return getByIndex(r'serverUuid', [serverUuid]);
  }

  EvenementIsarModel? getByServerUuidSync(String serverUuid) {
    return getByIndexSync(r'serverUuid', [serverUuid]);
  }

  Future<bool> deleteByServerUuid(String serverUuid) {
    return deleteByIndex(r'serverUuid', [serverUuid]);
  }

  bool deleteByServerUuidSync(String serverUuid) {
    return deleteByIndexSync(r'serverUuid', [serverUuid]);
  }

  Future<List<EvenementIsarModel?>> getAllByServerUuid(
      List<String> serverUuidValues) {
    final values = serverUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverUuid', values);
  }

  List<EvenementIsarModel?> getAllByServerUuidSync(
      List<String> serverUuidValues) {
    final values = serverUuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'serverUuid', values);
  }

  Future<int> deleteAllByServerUuid(List<String> serverUuidValues) {
    final values = serverUuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'serverUuid', values);
  }

  int deleteAllByServerUuidSync(List<String> serverUuidValues) {
    final values = serverUuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'serverUuid', values);
  }

  Future<Id> putByServerUuid(EvenementIsarModel object) {
    return putByIndex(r'serverUuid', object);
  }

  Id putByServerUuidSync(EvenementIsarModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerUuid(List<EvenementIsarModel> objects) {
    return putAllByIndex(r'serverUuid', objects);
  }

  List<Id> putAllByServerUuidSync(List<EvenementIsarModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverUuid', objects, saveLinks: saveLinks);
  }
}

extension EvenementIsarModelQueryWhereSort
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QWhere> {
  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhere>
      anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension EvenementIsarModelQueryWhere
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QWhereClause> {
  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      serverUuidEqualTo(String serverUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverUuid',
        value: [serverUuid],
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      serverUuidNotEqualTo(String serverUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverUuid',
              lower: [],
              upper: [serverUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverUuid',
              lower: [serverUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverUuid',
              lower: [serverUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverUuid',
              lower: [],
              upper: [serverUuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      statutEqualTo(String statut) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'statut',
        value: [statut],
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      statutNotEqualTo(String statut) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'statut',
              lower: [],
              upper: [statut],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'statut',
              lower: [statut],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'statut',
              lower: [statut],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'statut',
              lower: [],
              upper: [statut],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterWhereClause>
      updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EvenementIsarModelQueryFilter
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QFilterCondition> {
  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      archivedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'archivedAt',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      archivedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'archivedAt',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      archivedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'archivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      archivedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'archivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      archivedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'archivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      archivedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'archivedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auteurId',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'auteurId',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'auteurId',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'auteurId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auteurNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'auteurNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'auteurNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'auteurNom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'auteurNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'auteurNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'auteurNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'auteurNom',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auteurNom',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurNomIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'auteurNom',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'auteurPhotoUrl',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'auteurPhotoUrl',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auteurPhotoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'auteurPhotoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'auteurPhotoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'auteurPhotoUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'auteurPhotoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'auteurPhotoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'auteurPhotoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'auteurPhotoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auteurPhotoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      auteurPhotoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'auteurPhotoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'churchId',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'churchId',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'churchId',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'churchId',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'churchId',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'churchId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'churchNom',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'churchNom',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'churchNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'churchNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'churchNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'churchNom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'churchNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'churchNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'churchNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'churchNom',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'churchNom',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      churchNomIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'churchNom',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateDebutEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateDebut',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateDebutGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateDebut',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateDebutLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateDebut',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateDebutBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateDebut',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateFinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateFin',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateFinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateFin',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateFinEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateFin',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateFinGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateFin',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateFinLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateFin',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      dateFinBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateFin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      estAuteurEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estAuteur',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
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

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
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

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      joursAvantArchivageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'joursAvantArchivage',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      joursAvantArchivageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'joursAvantArchivage',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      joursAvantArchivageEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'joursAvantArchivage',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      joursAvantArchivageGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'joursAvantArchivage',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      joursAvantArchivageLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'joursAvantArchivage',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      joursAvantArchivageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'joursAvantArchivage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      montantCollecteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montantCollecte',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      montantCollecteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montantCollecte',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      montantCollecteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montantCollecte',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      montantCollecteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montantCollecte',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      nombreContributionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreContributions',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      nombreContributionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombreContributions',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      nombreContributionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombreContributions',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      nombreContributionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombreContributions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      objectifMontantIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'objectifMontant',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      objectifMontantIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'objectifMontant',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      objectifMontantEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objectifMontant',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      objectifMontantGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'objectifMontant',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      objectifMontantLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'objectifMontant',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      objectifMontantBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'objectifMontant',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      peutContribuerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peutContribuer',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      peutGererEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peutGerer',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      pourcentageObjectifIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pourcentageObjectif',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      pourcentageObjectifIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pourcentageObjectif',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      pourcentageObjectifEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pourcentageObjectif',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      pourcentageObjectifGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pourcentageObjectif',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      pourcentageObjectifLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pourcentageObjectif',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      pourcentageObjectifBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pourcentageObjectif',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      publishedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publishedAt',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      publishedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publishedAt',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      publishedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      publishedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      publishedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      publishedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publishedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      scheduledPublishAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledPublishAt',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      scheduledPublishAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledPublishAt',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      scheduledPublishAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledPublishAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      scheduledPublishAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledPublishAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      scheduledPublishAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledPublishAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      scheduledPublishAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledPublishAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serverUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serverUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      serverUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statut',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statut',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statut',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statut',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statut',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statut',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statut',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statut',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statut',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      statutIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statut',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      termineAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'termineAt',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      termineAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'termineAt',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      termineAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      termineAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'termineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      termineAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'termineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      termineAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'termineAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'titre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'titre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'titre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'titre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'titre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'titre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'titre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titre',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      titreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'titre',
        value: '',
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EvenementIsarModelQueryObject
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QFilterCondition> {}

extension EvenementIsarModelQueryLinks
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QFilterCondition> {}

extension EvenementIsarModelQuerySortBy
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QSortBy> {
  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByArchivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archivedAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByArchivedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archivedAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByAuteurId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurId', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByAuteurIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurId', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByAuteurNom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurNom', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByAuteurNomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurNom', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByAuteurPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurPhotoUrl', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByAuteurPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurPhotoUrl', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByChurchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchId', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByChurchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchId', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByChurchNom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchNom', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByChurchNomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchNom', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByDateDebut() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateDebut', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByDateDebutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateDebut', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByDateFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateFin', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByDateFinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateFin', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByEstAuteur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estAuteur', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByEstAuteurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estAuteur', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByJoursAvantArchivage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joursAvantArchivage', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByJoursAvantArchivageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joursAvantArchivage', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByMontantCollecte() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montantCollecte', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByMontantCollecteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montantCollecte', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByNombreContributions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreContributions', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByNombreContributionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreContributions', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByObjectifMontant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectifMontant', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByObjectifMontantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectifMontant', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByPeutContribuer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peutContribuer', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByPeutContribuerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peutContribuer', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByPeutGerer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peutGerer', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByPeutGererDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peutGerer', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByPourcentageObjectif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pourcentageObjectif', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByPourcentageObjectifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pourcentageObjectif', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByPublishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByScheduledPublishAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledPublishAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByScheduledPublishAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledPublishAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByServerUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverUuid', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByServerUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverUuid', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByStatut() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statut', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByStatutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statut', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByTermineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termineAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByTermineAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termineAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByTitre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titre', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByTitreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titre', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EvenementIsarModelQuerySortThenBy
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QSortThenBy> {
  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByArchivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archivedAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByArchivedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archivedAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByAuteurId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurId', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByAuteurIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurId', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByAuteurNom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurNom', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByAuteurNomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurNom', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByAuteurPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurPhotoUrl', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByAuteurPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurPhotoUrl', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByChurchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchId', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByChurchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchId', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByChurchNom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchNom', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByChurchNomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchNom', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByDateDebut() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateDebut', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByDateDebutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateDebut', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByDateFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateFin', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByDateFinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateFin', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByEstAuteur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estAuteur', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByEstAuteurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estAuteur', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByJoursAvantArchivage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joursAvantArchivage', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByJoursAvantArchivageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joursAvantArchivage', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByMontantCollecte() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montantCollecte', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByMontantCollecteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montantCollecte', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByNombreContributions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreContributions', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByNombreContributionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreContributions', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByObjectifMontant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectifMontant', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByObjectifMontantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectifMontant', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByPeutContribuer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peutContribuer', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByPeutContribuerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peutContribuer', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByPeutGerer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peutGerer', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByPeutGererDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peutGerer', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByPourcentageObjectif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pourcentageObjectif', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByPourcentageObjectifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pourcentageObjectif', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByPublishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByScheduledPublishAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledPublishAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByScheduledPublishAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledPublishAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByServerUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverUuid', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByServerUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverUuid', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByStatut() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statut', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByStatutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statut', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByTermineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termineAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByTermineAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termineAt', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByTitre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titre', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByTitreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titre', Sort.desc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EvenementIsarModelQueryWhereDistinct
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct> {
  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByArchivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'archivedAt');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByAuteurId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'auteurId');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByAuteurNom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'auteurNom', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByAuteurPhotoUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'auteurPhotoUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByChurchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'churchId');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByChurchNom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'churchNom', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByDateDebut() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateDebut');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByDateFin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateFin');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByEstAuteur() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estAuteur');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByJoursAvantArchivage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'joursAvantArchivage');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByMontantCollecte() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montantCollecte');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByNombreContributions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombreContributions');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByObjectifMontant() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objectifMontant');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByPeutContribuer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peutContribuer');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByPeutGerer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peutGerer');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByPourcentageObjectif() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pourcentageObjectif');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publishedAt');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByScheduledPublishAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledPublishAt');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByServerUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByStatut({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statut', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByTermineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termineAt');
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByTitre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvenementIsarModel, EvenementIsarModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension EvenementIsarModelQueryProperty
    on QueryBuilder<EvenementIsarModel, EvenementIsarModel, QQueryProperty> {
  QueryBuilder<EvenementIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EvenementIsarModel, DateTime?, QQueryOperations>
      archivedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'archivedAt');
    });
  }

  QueryBuilder<EvenementIsarModel, int, QQueryOperations> auteurIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'auteurId');
    });
  }

  QueryBuilder<EvenementIsarModel, String, QQueryOperations>
      auteurNomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'auteurNom');
    });
  }

  QueryBuilder<EvenementIsarModel, String?, QQueryOperations>
      auteurPhotoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'auteurPhotoUrl');
    });
  }

  QueryBuilder<EvenementIsarModel, int?, QQueryOperations> churchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'churchId');
    });
  }

  QueryBuilder<EvenementIsarModel, String?, QQueryOperations>
      churchNomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'churchNom');
    });
  }

  QueryBuilder<EvenementIsarModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EvenementIsarModel, DateTime, QQueryOperations>
      dateDebutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateDebut');
    });
  }

  QueryBuilder<EvenementIsarModel, DateTime?, QQueryOperations>
      dateFinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateFin');
    });
  }

  QueryBuilder<EvenementIsarModel, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<EvenementIsarModel, bool, QQueryOperations> estAuteurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estAuteur');
    });
  }

  QueryBuilder<EvenementIsarModel, String?, QQueryOperations>
      imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<EvenementIsarModel, int?, QQueryOperations>
      joursAvantArchivageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'joursAvantArchivage');
    });
  }

  QueryBuilder<EvenementIsarModel, int, QQueryOperations>
      montantCollecteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montantCollecte');
    });
  }

  QueryBuilder<EvenementIsarModel, int, QQueryOperations>
      nombreContributionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombreContributions');
    });
  }

  QueryBuilder<EvenementIsarModel, int?, QQueryOperations>
      objectifMontantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objectifMontant');
    });
  }

  QueryBuilder<EvenementIsarModel, bool, QQueryOperations>
      peutContribuerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peutContribuer');
    });
  }

  QueryBuilder<EvenementIsarModel, bool, QQueryOperations> peutGererProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peutGerer');
    });
  }

  QueryBuilder<EvenementIsarModel, double?, QQueryOperations>
      pourcentageObjectifProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pourcentageObjectif');
    });
  }

  QueryBuilder<EvenementIsarModel, DateTime?, QQueryOperations>
      publishedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publishedAt');
    });
  }

  QueryBuilder<EvenementIsarModel, DateTime?, QQueryOperations>
      scheduledPublishAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledPublishAt');
    });
  }

  QueryBuilder<EvenementIsarModel, String, QQueryOperations>
      serverUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverUuid');
    });
  }

  QueryBuilder<EvenementIsarModel, String, QQueryOperations> statutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statut');
    });
  }

  QueryBuilder<EvenementIsarModel, DateTime?, QQueryOperations>
      termineAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termineAt');
    });
  }

  QueryBuilder<EvenementIsarModel, String, QQueryOperations> titreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titre');
    });
  }

  QueryBuilder<EvenementIsarModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
