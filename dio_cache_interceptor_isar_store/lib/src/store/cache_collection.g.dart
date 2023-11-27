// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCacheCollection on Isar {
  IsarCollection<Cache> get caches => this.collection();
}

const CacheSchema = CollectionSchema(
  name: r'Cache',
  id: 1541975981581312059,
  properties: {
    r'cacheControl': PropertySchema(
      id: 0,
      name: r'cacheControl',
      type: IsarType.string,
    ),
    r'cacheKey': PropertySchema(
      id: 1,
      name: r'cacheKey',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 2,
      name: r'content',
      type: IsarType.longList,
    ),
    r'date': PropertySchema(
      id: 3,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'eTag': PropertySchema(
      id: 4,
      name: r'eTag',
      type: IsarType.string,
    ),
    r'expires': PropertySchema(
      id: 5,
      name: r'expires',
      type: IsarType.dateTime,
    ),
    r'headers': PropertySchema(
      id: 6,
      name: r'headers',
      type: IsarType.longList,
    ),
    r'lastModified': PropertySchema(
      id: 7,
      name: r'lastModified',
      type: IsarType.string,
    ),
    r'maxStale': PropertySchema(
      id: 8,
      name: r'maxStale',
      type: IsarType.dateTime,
    ),
    r'priority': PropertySchema(
      id: 9,
      name: r'priority',
      type: IsarType.long,
    ),
    r'requestDate': PropertySchema(
      id: 10,
      name: r'requestDate',
      type: IsarType.dateTime,
    ),
    r'responseDate': PropertySchema(
      id: 11,
      name: r'responseDate',
      type: IsarType.dateTime,
    ),
    r'url': PropertySchema(
      id: 12,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _cacheEstimateSize,
  serialize: _cacheSerialize,
  deserialize: _cacheDeserialize,
  deserializeProp: _cacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'cacheKey': IndexSchema(
      id: 5885332021012296610,
      name: r'cacheKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cacheKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cacheGetId,
  getLinks: _cacheGetLinks,
  attach: _cacheAttach,
  version: '3.1.0+1',
);

int _cacheEstimateSize(
  Cache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cacheControl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.cacheKey.length * 3;
  {
    final value = object.content;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.eTag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.headers;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.lastModified;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _cacheSerialize(
  Cache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cacheControl);
  writer.writeString(offsets[1], object.cacheKey);
  writer.writeLongList(offsets[2], object.content);
  writer.writeDateTime(offsets[3], object.date);
  writer.writeString(offsets[4], object.eTag);
  writer.writeDateTime(offsets[5], object.expires);
  writer.writeLongList(offsets[6], object.headers);
  writer.writeString(offsets[7], object.lastModified);
  writer.writeDateTime(offsets[8], object.maxStale);
  writer.writeLong(offsets[9], object.priority);
  writer.writeDateTime(offsets[10], object.requestDate);
  writer.writeDateTime(offsets[11], object.responseDate);
  writer.writeString(offsets[12], object.url);
}

Cache _cacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Cache();
  object.cacheControl = reader.readStringOrNull(offsets[0]);
  object.cacheKey = reader.readString(offsets[1]);
  object.content = reader.readLongList(offsets[2]);
  object.date = reader.readDateTimeOrNull(offsets[3]);
  object.eTag = reader.readStringOrNull(offsets[4]);
  object.expires = reader.readDateTimeOrNull(offsets[5]);
  object.headers = reader.readLongList(offsets[6]);
  object.id = id;
  object.lastModified = reader.readStringOrNull(offsets[7]);
  object.maxStale = reader.readDateTimeOrNull(offsets[8]);
  object.priority = reader.readLong(offsets[9]);
  object.requestDate = reader.readDateTimeOrNull(offsets[10]);
  object.responseDate = reader.readDateTime(offsets[11]);
  object.url = reader.readString(offsets[12]);
  return object;
}

P _cacheDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongList(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLongList(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cacheGetId(Cache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cacheGetLinks(Cache object) {
  return [];
}

void _cacheAttach(IsarCollection<dynamic> col, Id id, Cache object) {
  object.id = id;
}

extension CacheByIndex on IsarCollection<Cache> {
  Future<Cache?> getByCacheKey(String cacheKey) {
    return getByIndex(r'cacheKey', [cacheKey]);
  }

  Cache? getByCacheKeySync(String cacheKey) {
    return getByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<bool> deleteByCacheKey(String cacheKey) {
    return deleteByIndex(r'cacheKey', [cacheKey]);
  }

  bool deleteByCacheKeySync(String cacheKey) {
    return deleteByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<List<Cache?>> getAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'cacheKey', values);
  }

  List<Cache?> getAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cacheKey', values);
  }

  Future<int> deleteAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cacheKey', values);
  }

  int deleteAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cacheKey', values);
  }

  Future<Id> putByCacheKey(Cache object) {
    return putByIndex(r'cacheKey', object);
  }

  Id putByCacheKeySync(Cache object, {bool saveLinks = true}) {
    return putByIndexSync(r'cacheKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCacheKey(List<Cache> objects) {
    return putAllByIndex(r'cacheKey', objects);
  }

  List<Id> putAllByCacheKeySync(List<Cache> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'cacheKey', objects, saveLinks: saveLinks);
  }
}

extension CacheQueryWhereSort on QueryBuilder<Cache, Cache, QWhere> {
  QueryBuilder<Cache, Cache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CacheQueryWhere on QueryBuilder<Cache, Cache, QWhereClause> {
  QueryBuilder<Cache, Cache, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Cache, Cache, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterWhereClause> idBetween(
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

  QueryBuilder<Cache, Cache, QAfterWhereClause> cacheKeyEqualTo(
      String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cacheKey',
        value: [cacheKey],
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterWhereClause> cacheKeyNotEqualTo(
      String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CacheQueryFilter on QueryBuilder<Cache, Cache, QFilterCondition> {
  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cacheControl',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cacheControl',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheControl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cacheControl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cacheControl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cacheControl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cacheControl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cacheControl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cacheControl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cacheControl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheControl',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheControlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cacheControl',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cacheKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cacheKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> cacheKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentElementEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'content',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'content',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'content',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'content',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'content',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> contentLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'content',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> dateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> dateGreaterThan(
    DateTime? value, {
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

  QueryBuilder<Cache, Cache, QAfterFilterCondition> dateLessThan(
    DateTime? value, {
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

  QueryBuilder<Cache, Cache, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eTag',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eTag',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eTag',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eTag',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eTag',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> eTagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eTag',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> expiresIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expires',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> expiresIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expires',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> expiresEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expires',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> expiresGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expires',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> expiresLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expires',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> expiresBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expires',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'headers',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'headers',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersElementEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'headers',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'headers',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'headers',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'headers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headers',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headers',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headers',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headers',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headers',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> headersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headers',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Cache, Cache, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Cache, Cache, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastModified',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastModified',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModified',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModified',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModified',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModified',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastModified',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastModified',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastModified',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastModified',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModified',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> lastModifiedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastModified',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> maxStaleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxStale',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> maxStaleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxStale',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> maxStaleEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxStale',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> maxStaleGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxStale',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> maxStaleLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxStale',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> maxStaleBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxStale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> requestDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'requestDate',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> requestDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'requestDate',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> requestDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> requestDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> requestDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> requestDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> responseDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> responseDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'responseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> responseDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'responseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> responseDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'responseDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<Cache, Cache, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension CacheQueryObject on QueryBuilder<Cache, Cache, QFilterCondition> {}

extension CacheQueryLinks on QueryBuilder<Cache, Cache, QFilterCondition> {}

extension CacheQuerySortBy on QueryBuilder<Cache, Cache, QSortBy> {
  QueryBuilder<Cache, Cache, QAfterSortBy> sortByCacheControl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheControl', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByCacheControlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheControl', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByETag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eTag', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByETagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eTag', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByExpires() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expires', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByExpiresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expires', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByMaxStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStale', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByMaxStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStale', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByRequestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestDate', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByRequestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestDate', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByResponseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseDate', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByResponseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseDate', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension CacheQuerySortThenBy on QueryBuilder<Cache, Cache, QSortThenBy> {
  QueryBuilder<Cache, Cache, QAfterSortBy> thenByCacheControl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheControl', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByCacheControlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheControl', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByETag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eTag', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByETagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eTag', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByExpires() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expires', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByExpiresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expires', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByMaxStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStale', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByMaxStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStale', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByRequestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestDate', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByRequestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestDate', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByResponseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseDate', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByResponseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseDate', Sort.desc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<Cache, Cache, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension CacheQueryWhereDistinct on QueryBuilder<Cache, Cache, QDistinct> {
  QueryBuilder<Cache, Cache, QDistinct> distinctByCacheControl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheControl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByCacheKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content');
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByETag(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eTag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByExpires() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expires');
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByHeaders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'headers');
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByLastModified(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModified', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByMaxStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxStale');
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByRequestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestDate');
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByResponseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'responseDate');
    });
  }

  QueryBuilder<Cache, Cache, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension CacheQueryProperty on QueryBuilder<Cache, Cache, QQueryProperty> {
  QueryBuilder<Cache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Cache, String?, QQueryOperations> cacheControlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheControl');
    });
  }

  QueryBuilder<Cache, String, QQueryOperations> cacheKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheKey');
    });
  }

  QueryBuilder<Cache, List<int>?, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<Cache, DateTime?, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<Cache, String?, QQueryOperations> eTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eTag');
    });
  }

  QueryBuilder<Cache, DateTime?, QQueryOperations> expiresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expires');
    });
  }

  QueryBuilder<Cache, List<int>?, QQueryOperations> headersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'headers');
    });
  }

  QueryBuilder<Cache, String?, QQueryOperations> lastModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModified');
    });
  }

  QueryBuilder<Cache, DateTime?, QQueryOperations> maxStaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxStale');
    });
  }

  QueryBuilder<Cache, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<Cache, DateTime?, QQueryOperations> requestDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestDate');
    });
  }

  QueryBuilder<Cache, DateTime, QQueryOperations> responseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'responseDate');
    });
  }

  QueryBuilder<Cache, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
