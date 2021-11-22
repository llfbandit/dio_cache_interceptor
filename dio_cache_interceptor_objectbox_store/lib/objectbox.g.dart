// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:objectbox/flatbuffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';

import 'src/store/dio_cache_interceptor_objectbox_store.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(1, 1354879783786486451),
      name: 'CacheControlBox',
      lastPropertyId: const IdUid(6, 3554148799202003267),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 7542048865731308062),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 5058379695187648266),
            name: 'maxAge',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 6729461042167174602),
            name: 'privacy',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 3984935714719910661),
            name: 'noCache',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 4279848142252840831),
            name: 'noStore',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 3554148799202003267),
            name: 'other',
            type: 30,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(2, 3591291115973887432),
      name: 'CacheResponseBox',
      lastPropertyId: const IdUid(13, 4287785650979561948),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 5681174421901306941),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 2558701747622840298),
            name: 'key',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 3817824292323352053),
            name: 'content',
            type: 23,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 6117783729881623912),
            name: 'date',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 3535461758765559380),
            name: 'eTag',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 365079362971753198),
            name: 'expires',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 9154450730268381409),
            name: 'headers',
            type: 23,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 2810219807190022652),
            name: 'lastModified',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 2228972762576331614),
            name: 'maxStale',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 357520955945404792),
            name: 'responseDate',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(11, 8589375812343335305),
            name: 'url',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(12, 2042507747744468765),
            name: 'priority',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(13, 4287785650979561948),
            name: 'cacheControlId',
            type: 11,
            flags: 520,
            indexId: const IdUid(1, 8984911200634127343),
            relationTarget: 'CacheControlBox')
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[])
];

/// Open an ObjectBox store with the model declared in this file.
Store openStore(
        {String? directory,
        int? maxDBSizeInKB,
        int? fileMode,
        int? maxReaders,
        bool queriesCaseSensitiveDefault = true,
        String? macosApplicationGroup}) =>
    Store(getObjectBoxModel(),
        directory: directory,
        maxDBSizeInKB: maxDBSizeInKB,
        fileMode: fileMode,
        maxReaders: maxReaders,
        queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
        macosApplicationGroup: macosApplicationGroup);

/// ObjectBox model definition, pass it to [Store] - Store(getObjectBoxModel())
ModelDefinition getObjectBoxModel() {
  final model = ModelInfo(
      entities: _entities,
      lastEntityId: const IdUid(2, 3591291115973887432),
      lastIndexId: const IdUid(1, 8984911200634127343),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    CacheControlBox: EntityDefinition<CacheControlBox>(
        model: _entities[0],
        toOneRelations: (CacheControlBox object) => [],
        toManyRelations: (CacheControlBox object) => {},
        getId: (CacheControlBox object) => object.id,
        setId: (CacheControlBox object, int id) {
          object.id = id;
        },
        objectToFB: (CacheControlBox object, fb.Builder fbb) {
          final privacyOffset =
              object.privacy == null ? null : fbb.writeString(object.privacy!);
          final otherOffset = object.other == null
              ? null
              : fbb.writeList(
                  object.other!.map(fbb.writeString).toList(growable: false));
          fbb.startTable(7);
          fbb.addInt64(0, object.id ?? 0);
          fbb.addInt64(1, object.maxAge);
          fbb.addOffset(2, privacyOffset);
          fbb.addBool(3, object.noCache);
          fbb.addBool(4, object.noStore);
          fbb.addOffset(5, otherOffset);
          fbb.finish(fbb.endTable());
          return object.id ?? 0;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = CacheControlBox(
              id: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 4),
              maxAge: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 6),
              privacy: const fb.StringReader()
                  .vTableGetNullable(buffer, rootOffset, 8),
              noCache: const fb.BoolReader()
                  .vTableGetNullable(buffer, rootOffset, 10),
              noStore: const fb.BoolReader()
                  .vTableGetNullable(buffer, rootOffset, 12),
              other: const fb.ListReader<String>(fb.StringReader(), lazy: false)
                  .vTableGetNullable(buffer, rootOffset, 14));

          return object;
        }),
    CacheResponseBox: EntityDefinition<CacheResponseBox>(
        model: _entities[1],
        toOneRelations: (CacheResponseBox object) => [object.cacheControl],
        toManyRelations: (CacheResponseBox object) => {},
        getId: (CacheResponseBox object) => object.id,
        setId: (CacheResponseBox object, int id) {
          object.id = id;
        },
        objectToFB: (CacheResponseBox object, fb.Builder fbb) {
          final keyOffset = fbb.writeString(object.key);
          final contentOffset = object.content == null
              ? null
              : fbb.writeListInt8(object.content!);
          final eTagOffset =
              object.eTag == null ? null : fbb.writeString(object.eTag!);
          final headersOffset = object.headers == null
              ? null
              : fbb.writeListInt8(object.headers!);
          final lastModifiedOffset = object.lastModified == null
              ? null
              : fbb.writeString(object.lastModified!);
          final urlOffset = fbb.writeString(object.url);
          fbb.startTable(14);
          fbb.addInt64(0, object.id ?? 0);
          fbb.addOffset(1, keyOffset);
          fbb.addOffset(2, contentOffset);
          fbb.addInt64(3, object.date?.millisecondsSinceEpoch);
          fbb.addOffset(4, eTagOffset);
          fbb.addInt64(5, object.expires?.millisecondsSinceEpoch);
          fbb.addOffset(6, headersOffset);
          fbb.addOffset(7, lastModifiedOffset);
          fbb.addInt64(8, object.maxStale?.millisecondsSinceEpoch);
          fbb.addInt64(9, object.responseDate.millisecondsSinceEpoch);
          fbb.addOffset(10, urlOffset);
          fbb.addInt64(11, object.priority);
          fbb.addInt64(12, object.cacheControl.targetId);
          fbb.finish(fbb.endTable());
          return object.id ?? 0;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final dateValue =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 10);
          final expiresValue =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 14);
          final maxStaleValue =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 20);
          final object = CacheResponseBox(
              key: const fb.StringReader().vTableGet(buffer, rootOffset, 6, ''),
              content: const fb.ListReader<int>(fb.Int8Reader(), lazy: false)
                  .vTableGetNullable(buffer, rootOffset, 8),
              date: dateValue == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(dateValue),
              eTag: const fb.StringReader()
                  .vTableGetNullable(buffer, rootOffset, 12),
              expires: expiresValue == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(expiresValue),
              headers: const fb.ListReader<int>(fb.Int8Reader(), lazy: false)
                  .vTableGetNullable(buffer, rootOffset, 16),
              lastModified: const fb.StringReader()
                  .vTableGetNullable(buffer, rootOffset, 18),
              maxStale: maxStaleValue == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(maxStaleValue),
              priority:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 26, 0),
              responseDate: DateTime.fromMillisecondsSinceEpoch(
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 22, 0)),
              url:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 24, ''))
            ..id = const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 4);
          object.cacheControl.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 28, 0);
          object.cacheControl.attach(store);
          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [CacheControlBox] entity fields to define ObjectBox queries.
class CacheControlBox_ {
  /// see [CacheControlBox.id]
  static final id =
      QueryIntegerProperty<CacheControlBox>(_entities[0].properties[0]);

  /// see [CacheControlBox.maxAge]
  static final maxAge =
      QueryIntegerProperty<CacheControlBox>(_entities[0].properties[1]);

  /// see [CacheControlBox.privacy]
  static final privacy =
      QueryStringProperty<CacheControlBox>(_entities[0].properties[2]);

  /// see [CacheControlBox.noCache]
  static final noCache =
      QueryBooleanProperty<CacheControlBox>(_entities[0].properties[3]);

  /// see [CacheControlBox.noStore]
  static final noStore =
      QueryBooleanProperty<CacheControlBox>(_entities[0].properties[4]);

  /// see [CacheControlBox.other]
  static final other =
      QueryStringVectorProperty<CacheControlBox>(_entities[0].properties[5]);
}

/// [CacheResponseBox] entity fields to define ObjectBox queries.
class CacheResponseBox_ {
  /// see [CacheResponseBox.id]
  static final id =
      QueryIntegerProperty<CacheResponseBox>(_entities[1].properties[0]);

  /// see [CacheResponseBox.key]
  static final key =
      QueryStringProperty<CacheResponseBox>(_entities[1].properties[1]);

  /// see [CacheResponseBox.content]
  static final content =
      QueryByteVectorProperty<CacheResponseBox>(_entities[1].properties[2]);

  /// see [CacheResponseBox.date]
  static final date =
      QueryIntegerProperty<CacheResponseBox>(_entities[1].properties[3]);

  /// see [CacheResponseBox.eTag]
  static final eTag =
      QueryStringProperty<CacheResponseBox>(_entities[1].properties[4]);

  /// see [CacheResponseBox.expires]
  static final expires =
      QueryIntegerProperty<CacheResponseBox>(_entities[1].properties[5]);

  /// see [CacheResponseBox.headers]
  static final headers =
      QueryByteVectorProperty<CacheResponseBox>(_entities[1].properties[6]);

  /// see [CacheResponseBox.lastModified]
  static final lastModified =
      QueryStringProperty<CacheResponseBox>(_entities[1].properties[7]);

  /// see [CacheResponseBox.maxStale]
  static final maxStale =
      QueryIntegerProperty<CacheResponseBox>(_entities[1].properties[8]);

  /// see [CacheResponseBox.responseDate]
  static final responseDate =
      QueryIntegerProperty<CacheResponseBox>(_entities[1].properties[9]);

  /// see [CacheResponseBox.url]
  static final url =
      QueryStringProperty<CacheResponseBox>(_entities[1].properties[10]);

  /// see [CacheResponseBox.priority]
  static final priority =
      QueryIntegerProperty<CacheResponseBox>(_entities[1].properties[11]);

  /// see [CacheResponseBox.cacheControl]
  static final cacheControl =
      QueryRelationToOne<CacheResponseBox, CacheControlBox>(
          _entities[1].properties[12]);
}
