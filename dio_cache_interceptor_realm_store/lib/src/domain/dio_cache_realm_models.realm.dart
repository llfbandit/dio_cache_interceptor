// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_cache_realm_models.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class CacheResponseRealm extends $CacheResponseRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  CacheResponseRealm({
    required String key,
    CacheControlRealm? cacheControl,
    Iterable<int> content = const [],
    DateTime? date,
    String? eTag,
    DateTime? expires,
    Iterable<int> headers = const [],
    String? lastModified,
    DateTime? maxStale,
    DateTime? requestDate,
    required DateTime responseDate,
    required String url,
    required int priority,
  }) {
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'cacheControl', cacheControl);
    RealmObjectBase.set<RealmList<int>>(
        this, 'content', RealmList<int>(content));
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'eTag', eTag);
    RealmObjectBase.set(this, 'expires', expires);
    RealmObjectBase.set<RealmList<int>>(
        this, 'headers', RealmList<int>(headers));
    RealmObjectBase.set(this, 'lastModified', lastModified);
    RealmObjectBase.set(this, 'maxStale', maxStale);
    RealmObjectBase.set(this, 'requestDate', requestDate);
    RealmObjectBase.set(this, 'responseDate', responseDate);
    RealmObjectBase.set(this, 'url', url);
    RealmObjectBase.set(this, 'cachePriority', priority);
  }

  CacheResponseRealm._();

  @override
  String get key => RealmObjectBase.get<String>(this, 'key') as String;
  @override
  set key(String value) => RealmObjectBase.set(this, 'key', value);

  @override
  CacheControlRealm? get cacheControl =>
      RealmObjectBase.get<CacheControlRealm>(this, 'cacheControl')
          as CacheControlRealm?;
  @override
  set cacheControl(covariant CacheControlRealm? value) =>
      RealmObjectBase.set(this, 'cacheControl', value);

  @override
  RealmList<int> get content =>
      RealmObjectBase.get<int>(this, 'content') as RealmList<int>;
  @override
  set content(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  DateTime? get date =>
      RealmObjectBase.get<DateTime>(this, 'date') as DateTime?;
  @override
  set date(DateTime? value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get eTag => RealmObjectBase.get<String>(this, 'eTag') as String?;
  @override
  set eTag(String? value) => RealmObjectBase.set(this, 'eTag', value);

  @override
  DateTime? get expires =>
      RealmObjectBase.get<DateTime>(this, 'expires') as DateTime?;
  @override
  set expires(DateTime? value) => RealmObjectBase.set(this, 'expires', value);

  @override
  RealmList<int> get headers =>
      RealmObjectBase.get<int>(this, 'headers') as RealmList<int>;
  @override
  set headers(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  String? get lastModified =>
      RealmObjectBase.get<String>(this, 'lastModified') as String?;
  @override
  set lastModified(String? value) =>
      RealmObjectBase.set(this, 'lastModified', value);

  @override
  DateTime? get maxStale =>
      RealmObjectBase.get<DateTime>(this, 'maxStale') as DateTime?;
  @override
  set maxStale(DateTime? value) => RealmObjectBase.set(this, 'maxStale', value);

  @override
  DateTime? get requestDate =>
      RealmObjectBase.get<DateTime>(this, 'requestDate') as DateTime?;
  @override
  set requestDate(DateTime? value) =>
      RealmObjectBase.set(this, 'requestDate', value);

  @override
  DateTime get responseDate =>
      RealmObjectBase.get<DateTime>(this, 'responseDate') as DateTime;
  @override
  set responseDate(DateTime value) =>
      RealmObjectBase.set(this, 'responseDate', value);

  @override
  String get url => RealmObjectBase.get<String>(this, 'url') as String;
  @override
  set url(String value) => RealmObjectBase.set(this, 'url', value);

  @override
  int get _priority => RealmObjectBase.get<int>(this, 'cachePriority') as int;
  @override
  set _priority(int value) => RealmObjectBase.set(this, 'cachePriority', value);

  @override
  Stream<RealmObjectChanges<CacheResponseRealm>> get changes =>
      RealmObjectBase.getChanges<CacheResponseRealm>(this);

  @override
  Stream<RealmObjectChanges<CacheResponseRealm>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<CacheResponseRealm>(this, keyPaths);

  @override
  CacheResponseRealm freeze() =>
      RealmObjectBase.freezeObject<CacheResponseRealm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'key': key.toEJson(),
      'cacheControl': cacheControl.toEJson(),
      'content': content.toEJson(),
      'date': date.toEJson(),
      'eTag': eTag.toEJson(),
      'expires': expires.toEJson(),
      'headers': headers.toEJson(),
      'lastModified': lastModified.toEJson(),
      'maxStale': maxStale.toEJson(),
      'requestDate': requestDate.toEJson(),
      'responseDate': responseDate.toEJson(),
      'url': url.toEJson(),
      'cachePriority': _priority.toEJson(),
    };
  }

  static EJsonValue _toEJson(CacheResponseRealm value) => value.toEJson();
  static CacheResponseRealm _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'key': EJsonValue key,
        'cacheControl': EJsonValue cacheControl,
        'content': EJsonValue content,
        'date': EJsonValue date,
        'eTag': EJsonValue eTag,
        'expires': EJsonValue expires,
        'headers': EJsonValue headers,
        'lastModified': EJsonValue lastModified,
        'maxStale': EJsonValue maxStale,
        'requestDate': EJsonValue requestDate,
        'responseDate': EJsonValue responseDate,
        'url': EJsonValue url,
        'cachePriority': EJsonValue _priority,
      } =>
        CacheResponseRealm(
          key: fromEJson(key),
          cacheControl: fromEJson(cacheControl),
          content: fromEJson(content),
          date: fromEJson(date),
          eTag: fromEJson(eTag),
          expires: fromEJson(expires),
          headers: fromEJson(headers),
          lastModified: fromEJson(lastModified),
          maxStale: fromEJson(maxStale),
          requestDate: fromEJson(requestDate),
          responseDate: fromEJson(responseDate),
          url: fromEJson(url),
          priority: fromEJson(_priority),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CacheResponseRealm._);
    register(_toEJson, _fromEJson);
    return SchemaObject(
        ObjectType.realmObject, CacheResponseRealm, 'CacheResponseRealm', [
      SchemaProperty('key', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('cacheControl', RealmPropertyType.object,
          optional: true, linkTarget: 'CacheControlRealm'),
      SchemaProperty('content', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('date', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('eTag', RealmPropertyType.string, optional: true),
      SchemaProperty('expires', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('headers', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('lastModified', RealmPropertyType.string, optional: true),
      SchemaProperty('maxStale', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('requestDate', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('responseDate', RealmPropertyType.timestamp),
      SchemaProperty('url', RealmPropertyType.string),
      SchemaProperty('_priority', RealmPropertyType.int,
          mapTo: 'cachePriority'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CacheControlRealm extends $CacheControlRealm
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  CacheControlRealm({
    int? maxAge,
    String? privacy,
    int? maxStale,
    int? minFresh,
    bool? mustRevalidate,
    bool? noCache,
    bool? noStore,
    Iterable<String> other = const [],
  }) {
    RealmObjectBase.set(this, 'maxAge', maxAge);
    RealmObjectBase.set(this, 'privacy', privacy);
    RealmObjectBase.set(this, 'maxStale', maxStale);
    RealmObjectBase.set(this, 'minFresh', minFresh);
    RealmObjectBase.set(this, 'mustRevalidate', mustRevalidate);
    RealmObjectBase.set(this, 'noCache', noCache);
    RealmObjectBase.set(this, 'noStore', noStore);
    RealmObjectBase.set<RealmList<String>>(
        this, 'other', RealmList<String>(other));
  }

  CacheControlRealm._();

  @override
  int? get maxAge => RealmObjectBase.get<int>(this, 'maxAge') as int?;
  @override
  set maxAge(int? value) => RealmObjectBase.set(this, 'maxAge', value);

  @override
  String? get privacy =>
      RealmObjectBase.get<String>(this, 'privacy') as String?;
  @override
  set privacy(String? value) => RealmObjectBase.set(this, 'privacy', value);

  @override
  int? get maxStale => RealmObjectBase.get<int>(this, 'maxStale') as int?;
  @override
  set maxStale(int? value) => RealmObjectBase.set(this, 'maxStale', value);

  @override
  int? get minFresh => RealmObjectBase.get<int>(this, 'minFresh') as int?;
  @override
  set minFresh(int? value) => RealmObjectBase.set(this, 'minFresh', value);

  @override
  bool? get mustRevalidate =>
      RealmObjectBase.get<bool>(this, 'mustRevalidate') as bool?;
  @override
  set mustRevalidate(bool? value) =>
      RealmObjectBase.set(this, 'mustRevalidate', value);

  @override
  bool? get noCache => RealmObjectBase.get<bool>(this, 'noCache') as bool?;
  @override
  set noCache(bool? value) => RealmObjectBase.set(this, 'noCache', value);

  @override
  bool? get noStore => RealmObjectBase.get<bool>(this, 'noStore') as bool?;
  @override
  set noStore(bool? value) => RealmObjectBase.set(this, 'noStore', value);

  @override
  RealmList<String> get other =>
      RealmObjectBase.get<String>(this, 'other') as RealmList<String>;
  @override
  set other(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<CacheControlRealm>> get changes =>
      RealmObjectBase.getChanges<CacheControlRealm>(this);

  @override
  Stream<RealmObjectChanges<CacheControlRealm>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<CacheControlRealm>(this, keyPaths);

  @override
  CacheControlRealm freeze() =>
      RealmObjectBase.freezeObject<CacheControlRealm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'maxAge': maxAge.toEJson(),
      'privacy': privacy.toEJson(),
      'maxStale': maxStale.toEJson(),
      'minFresh': minFresh.toEJson(),
      'mustRevalidate': mustRevalidate.toEJson(),
      'noCache': noCache.toEJson(),
      'noStore': noStore.toEJson(),
      'other': other.toEJson(),
    };
  }

  static EJsonValue _toEJson(CacheControlRealm value) => value.toEJson();
  static CacheControlRealm _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'maxAge': EJsonValue maxAge,
        'privacy': EJsonValue privacy,
        'maxStale': EJsonValue maxStale,
        'minFresh': EJsonValue minFresh,
        'mustRevalidate': EJsonValue mustRevalidate,
        'noCache': EJsonValue noCache,
        'noStore': EJsonValue noStore,
        'other': EJsonValue other,
      } =>
        CacheControlRealm(
          maxAge: fromEJson(maxAge),
          privacy: fromEJson(privacy),
          maxStale: fromEJson(maxStale),
          minFresh: fromEJson(minFresh),
          mustRevalidate: fromEJson(mustRevalidate),
          noCache: fromEJson(noCache),
          noStore: fromEJson(noStore),
          other: fromEJson(other),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CacheControlRealm._);
    register(_toEJson, _fromEJson);
    return SchemaObject(
        ObjectType.embeddedObject, CacheControlRealm, 'CacheControlRealm', [
      SchemaProperty('maxAge', RealmPropertyType.int, optional: true),
      SchemaProperty('privacy', RealmPropertyType.string, optional: true),
      SchemaProperty('maxStale', RealmPropertyType.int, optional: true),
      SchemaProperty('minFresh', RealmPropertyType.int, optional: true),
      SchemaProperty('mustRevalidate', RealmPropertyType.bool, optional: true),
      SchemaProperty('noCache', RealmPropertyType.bool, optional: true),
      SchemaProperty('noStore', RealmPropertyType.bool, optional: true),
      SchemaProperty('other', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
