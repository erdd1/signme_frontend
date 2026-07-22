// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publication_isar_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPublicationIsarModelCollection on Isar {
  IsarCollection<PublicationIsarModel> get publicationIsarModels =>
      this.collection();
}

const PublicationIsarModelSchema = CollectionSchema(
  name: r'PublicationIsarModel',
  id: 2871498826806227867,
  properties: {
    r'auteurId': PropertySchema(
      id: 0,
      name: r'auteurId',
      type: IsarType.long,
    ),
    r'auteurNom': PropertySchema(
      id: 1,
      name: r'auteurNom',
      type: IsarType.string,
    ),
    r'auteurPhotoUrl': PropertySchema(
      id: 2,
      name: r'auteurPhotoUrl',
      type: IsarType.string,
    ),
    r'churchId': PropertySchema(
      id: 3,
      name: r'churchId',
      type: IsarType.long,
    ),
    r'churchName': PropertySchema(
      id: 4,
      name: r'churchName',
      type: IsarType.string,
    ),
    r'contenu': PropertySchema(
      id: 5,
      name: r'contenu',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 7,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'referenceBiblique': PropertySchema(
      id: 8,
      name: r'referenceBiblique',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 9,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'titre': PropertySchema(
      id: 10,
      name: r'titre',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 11,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _publicationIsarModelEstimateSize,
  serialize: _publicationIsarModelSerialize,
  deserialize: _publicationIsarModelDeserialize,
  deserializeProp: _publicationIsarModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'serverId': IndexSchema(
      id: -7950187970872907662,
      name: r'serverId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'serverId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'referenceBiblique': IndexSchema(
      id: 3265664292855432234,
      name: r'referenceBiblique',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'referenceBiblique',
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
  getId: _publicationIsarModelGetId,
  getLinks: _publicationIsarModelGetLinks,
  attach: _publicationIsarModelAttach,
  version: '3.1.0+1',
);

int _publicationIsarModelEstimateSize(
  PublicationIsarModel object,
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
    final value = object.churchName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.contenu.length * 3;
  {
    final value = object.referenceBiblique;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.titre.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _publicationIsarModelSerialize(
  PublicationIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.auteurId);
  writer.writeString(offsets[1], object.auteurNom);
  writer.writeString(offsets[2], object.auteurPhotoUrl);
  writer.writeLong(offsets[3], object.churchId);
  writer.writeString(offsets[4], object.churchName);
  writer.writeString(offsets[5], object.contenu);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeDateTime(offsets[7], object.date);
  writer.writeString(offsets[8], object.referenceBiblique);
  writer.writeLong(offsets[9], object.serverId);
  writer.writeString(offsets[10], object.titre);
  writer.writeString(offsets[11], object.type);
  writer.writeDateTime(offsets[12], object.updatedAt);
}

PublicationIsarModel _publicationIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PublicationIsarModel();
  object.auteurId = reader.readLong(offsets[0]);
  object.auteurNom = reader.readString(offsets[1]);
  object.auteurPhotoUrl = reader.readStringOrNull(offsets[2]);
  object.churchId = reader.readLong(offsets[3]);
  object.churchName = reader.readStringOrNull(offsets[4]);
  object.contenu = reader.readString(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.date = reader.readDateTime(offsets[7]);
  object.id = id;
  object.referenceBiblique = reader.readStringOrNull(offsets[8]);
  object.serverId = reader.readLong(offsets[9]);
  object.titre = reader.readString(offsets[10]);
  object.type = reader.readString(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  return object;
}

P _publicationIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _publicationIsarModelGetId(PublicationIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _publicationIsarModelGetLinks(
    PublicationIsarModel object) {
  return [];
}

void _publicationIsarModelAttach(
    IsarCollection<dynamic> col, Id id, PublicationIsarModel object) {
  object.id = id;
}

extension PublicationIsarModelByIndex on IsarCollection<PublicationIsarModel> {
  Future<PublicationIsarModel?> getByServerId(int serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  PublicationIsarModel? getByServerIdSync(int serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(int serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(int serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<PublicationIsarModel?>> getAllByServerId(
      List<int> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<PublicationIsarModel?> getAllByServerIdSync(List<int> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'serverId', values);
  }

  Future<int> deleteAllByServerId(List<int> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'serverId', values);
  }

  int deleteAllByServerIdSync(List<int> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'serverId', values);
  }

  Future<Id> putByServerId(PublicationIsarModel object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(PublicationIsarModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<PublicationIsarModel> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<PublicationIsarModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension PublicationIsarModelQueryWhereSort
    on QueryBuilder<PublicationIsarModel, PublicationIsarModel, QWhere> {
  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhere>
      anyServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serverId'),
      );
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhere>
      anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension PublicationIsarModelQueryWhere
    on QueryBuilder<PublicationIsarModel, PublicationIsarModel, QWhereClause> {
  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      serverIdEqualTo(int serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      serverIdNotEqualTo(int serverId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [],
              upper: [serverId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [serverId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [serverId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [],
              upper: [serverId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      serverIdGreaterThan(
    int serverId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serverId',
        lower: [serverId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      serverIdLessThan(
    int serverId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serverId',
        lower: [],
        upper: [serverId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      serverIdBetween(
    int lowerServerId,
    int upperServerId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serverId',
        lower: [lowerServerId],
        includeLower: includeLower,
        upper: [upperServerId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      referenceBibliqueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'referenceBiblique',
        value: [null],
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      referenceBibliqueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'referenceBiblique',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      referenceBibliqueEqualTo(String? referenceBiblique) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'referenceBiblique',
        value: [referenceBiblique],
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      referenceBibliqueNotEqualTo(String? referenceBiblique) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'referenceBiblique',
              lower: [],
              upper: [referenceBiblique],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'referenceBiblique',
              lower: [referenceBiblique],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'referenceBiblique',
              lower: [referenceBiblique],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'referenceBiblique',
              lower: [],
              upper: [referenceBiblique],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
      updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterWhereClause>
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

extension PublicationIsarModelQueryFilter on QueryBuilder<PublicationIsarModel,
    PublicationIsarModel, QFilterCondition> {
  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auteurId',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurIdGreaterThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurIdLessThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurIdBetween(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurNomEqualTo(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurNomGreaterThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurNomLessThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurNomBetween(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurNomStartsWith(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurNomEndsWith(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      auteurNomContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'auteurNom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      auteurNomMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'auteurNom',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurNomIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auteurNom',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurNomIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'auteurNom',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'auteurPhotoUrl',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'auteurPhotoUrl',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlEqualTo(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlGreaterThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlLessThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlBetween(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlStartsWith(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlEndsWith(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      auteurPhotoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'auteurPhotoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      auteurPhotoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'auteurPhotoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auteurPhotoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> auteurPhotoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'auteurPhotoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'churchId',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchIdGreaterThan(
    int value, {
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchIdLessThan(
    int value, {
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'churchName',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'churchName',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'churchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'churchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'churchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'churchName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'churchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'churchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      churchNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'churchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      churchNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'churchName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'churchName',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> churchNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'churchName',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> contenuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> contenuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> contenuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> contenuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contenu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> contenuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> contenuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      contenuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      contenuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contenu',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> contenuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contenu',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> contenuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contenu',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referenceBiblique',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referenceBiblique',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceBiblique',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceBiblique',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceBiblique',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceBiblique',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenceBiblique',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenceBiblique',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      referenceBibliqueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenceBiblique',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      referenceBibliqueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenceBiblique',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceBiblique',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> referenceBibliqueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenceBiblique',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> serverIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> serverIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> serverIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> serverIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> titreEqualTo(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> titreGreaterThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> titreLessThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> titreBetween(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> titreStartsWith(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> titreEndsWith(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      titreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'titre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      titreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'titre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> titreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titre',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> titreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'titre',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<PublicationIsarModel, PublicationIsarModel,
      QAfterFilterCondition> updatedAtBetween(
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

extension PublicationIsarModelQueryObject on QueryBuilder<PublicationIsarModel,
    PublicationIsarModel, QFilterCondition> {}

extension PublicationIsarModelQueryLinks on QueryBuilder<PublicationIsarModel,
    PublicationIsarModel, QFilterCondition> {}

extension PublicationIsarModelQuerySortBy
    on QueryBuilder<PublicationIsarModel, PublicationIsarModel, QSortBy> {
  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByAuteurId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurId', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByAuteurIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurId', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByAuteurNom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurNom', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByAuteurNomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurNom', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByAuteurPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurPhotoUrl', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByAuteurPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurPhotoUrl', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByChurchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchId', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByChurchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchId', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByChurchName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchName', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByChurchNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchName', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByContenu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contenu', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByContenuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contenu', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByReferenceBiblique() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceBiblique', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByReferenceBibliqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceBiblique', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByTitre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titre', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByTitreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titre', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PublicationIsarModelQuerySortThenBy
    on QueryBuilder<PublicationIsarModel, PublicationIsarModel, QSortThenBy> {
  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByAuteurId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurId', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByAuteurIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurId', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByAuteurNom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurNom', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByAuteurNomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurNom', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByAuteurPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurPhotoUrl', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByAuteurPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auteurPhotoUrl', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByChurchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchId', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByChurchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchId', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByChurchName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchName', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByChurchNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'churchName', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByContenu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contenu', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByContenuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contenu', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByReferenceBiblique() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceBiblique', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByReferenceBibliqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceBiblique', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByTitre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titre', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByTitreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titre', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PublicationIsarModelQueryWhereDistinct
    on QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct> {
  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByAuteurId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'auteurId');
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByAuteurNom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'auteurNom', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByAuteurPhotoUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'auteurPhotoUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByChurchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'churchId');
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByChurchName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'churchName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByContenu({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contenu', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByReferenceBiblique({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceBiblique',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByTitre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PublicationIsarModel, PublicationIsarModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PublicationIsarModelQueryProperty on QueryBuilder<
    PublicationIsarModel, PublicationIsarModel, QQueryProperty> {
  QueryBuilder<PublicationIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PublicationIsarModel, int, QQueryOperations> auteurIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'auteurId');
    });
  }

  QueryBuilder<PublicationIsarModel, String, QQueryOperations>
      auteurNomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'auteurNom');
    });
  }

  QueryBuilder<PublicationIsarModel, String?, QQueryOperations>
      auteurPhotoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'auteurPhotoUrl');
    });
  }

  QueryBuilder<PublicationIsarModel, int, QQueryOperations> churchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'churchId');
    });
  }

  QueryBuilder<PublicationIsarModel, String?, QQueryOperations>
      churchNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'churchName');
    });
  }

  QueryBuilder<PublicationIsarModel, String, QQueryOperations>
      contenuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contenu');
    });
  }

  QueryBuilder<PublicationIsarModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PublicationIsarModel, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PublicationIsarModel, String?, QQueryOperations>
      referenceBibliqueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceBiblique');
    });
  }

  QueryBuilder<PublicationIsarModel, int, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<PublicationIsarModel, String, QQueryOperations> titreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titre');
    });
  }

  QueryBuilder<PublicationIsarModel, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<PublicationIsarModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
