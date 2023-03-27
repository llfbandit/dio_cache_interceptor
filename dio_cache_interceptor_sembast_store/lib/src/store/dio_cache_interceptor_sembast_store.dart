import 'dart:convert';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// A store saving responses using Sembast.
class SembastCacheStore extends CacheStore {
  /// Sembast store file path
  final String storePath;

  // Cache box name
  final String cacheStore;

  /// Sembast database
  Database? _database;

  /// Sembast ref instance for [CacheResponseBox]
  late final StoreRef<String, Map<String, dynamic>> _store;

  SembastCacheStore({required this.storePath, this.cacheStore ='cacheStore'}) {
    _store = stringMapStoreFactory.store(cacheStore);
    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final database = await _openDatabase();
    final query = Finder(filter: Filter.custom((snapshot) {
      var value = snapshot['priority'] as String;
      return CachePriority.values.byName(value).index <= priorityOrBelow.index;
    }));

    final results = await _store.find(database, finder: query);

    for (final result in results) {
      final value = CacheResponseBox.fromJson(result.value);
      if ((staleOnly && value.isStaled()) || !staleOnly) {
        await _store.record(result.key).delete(database);
      }
    }
  }

  @override
  Future<void> close() async {
    return await _database?.close();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    final database = await _openDatabase();
    final resp = await _store.record(key).getSnapshot(database);

    if (resp?.value == null) return Future.value();

    if (staleOnly && !CacheResponseBox.fromJson(resp!.value).isStaled()) {
      return Future.value();
    }

    await _store.record(key).delete(database);
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final database = await _openDatabase();
    await _getFromPath(
      pathPattern,
      queryParams: queryParams,
      onResponseMatch: (r) => _store.record(r.key).delete(database),
    );
  }

  @override
  Future<bool> exists(String key) async {
    //put async/await requests in inner future (because delete also has inner futures)
    //it prevents to call futures in right order
    return await Future.delayed(Duration.zero, () async {
      final database = await _openDatabase();
      final resp = await _store.record(key).getSnapshot(database);
      return resp?.value != null;
    });
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final database = await _openDatabase();
    final resp = await _store.record(key).getSnapshot(database);
    return resp?.value != null ? CacheResponseBox.fromJson(resp!.value) : null;
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = <CacheResponse>[];

    await _getFromPath(
      pathPattern,
      queryParams: queryParams,
      onResponseMatch: (r) => responses.add(r.toObject()),
    );

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) async {
    final database = await _openDatabase();
    await _store.record(response.key).delete(database);
    await _store.record(response.key).put(database, CacheResponseBox.toJson(response));
  }

  Future<void> _getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
    required void Function(CacheResponseBox) onResponseMatch,
  }) async {
    final database = await _openDatabase();
    var results = <CacheResponseBox>[];
    const limit = 10;
    int offset = 0;

    do {
      final query = Finder(
        limit: limit,
        offset: offset,
      );

      var results = await _store.find(database, finder: query);
      for (final result in results) {
        final value = CacheResponseBox.fromJson(result.value);
        if (pathExists(value.url, pathPattern, queryParams: queryParams)) {
          onResponseMatch.call(CacheResponseBox.fromObject(value));
        }
      }

      offset += limit;
    } while (results.isNotEmpty);
  }

  Future<Database> _openDatabase() async {
    _database ??= await databaseFactoryIo.openDatabase('$storePath/$cacheStore');
    return Future.value(_database);
  }
}

class CacheResponseBox {
  CacheResponseBox({
    required this.key,
    this.content,
    this.date,
    this.eTag,
    this.expires,
    this.headers,
    this.lastModified,
    this.maxStale,
    this.requestDate,
    required this.priority,
    required this.responseDate,
    required this.url,
    required this.cacheControl,
  });

  int? id;
  String key;
  List<int>? content;
  DateTime? date;
  String? eTag;
  DateTime? expires;
  List<int>? headers;
  String? lastModified;
  DateTime? maxStale;
  DateTime responseDate;
  DateTime? requestDate;
  String url;
  int priority;
  CacheControl? cacheControl;

  CachePriority get cachePriority {
    switch (priority) {
      case 0:
        return CachePriority.low;
      case 1:
        return CachePriority.normal;
      case 2:
        return CachePriority.high;
      default:
        return CachePriority.low;
    }
  }

  static Map<String, dynamic> toJson(CacheResponse instance) => <String, dynamic>{
        'key': instance.key,
        'content': instance.content != null ? utf8.decode(instance.content!) : null,
        'date': instance.date?.toIso8601String(),
        'eTag': instance.eTag,
        'expires': instance.expires?.toIso8601String(),
        'headers': instance.headers != null ? utf8.decode(instance.headers!) : null,
        'lastModified': instance.lastModified,
        'maxStale': instance.maxStale?.toIso8601String(),
        'responseDate': instance.responseDate.toIso8601String(),
        'url': instance.url,
        'requestDate': instance.requestDate.toIso8601String(),
        'priority': instance.priority.name,
        'cacheControl': CacheControlBox.toJson(instance.cacheControl),
      };

  CacheResponse toObject() {
    return CacheResponse(
      cacheControl: cacheControl ?? CacheControl(),
      content: content,
      date: date,
      eTag: eTag,
      expires: expires,
      headers: headers,
      key: key,
      lastModified: lastModified,
      maxStale: maxStale,
      priority: cachePriority,
      responseDate: responseDate,
      url: url,
      requestDate: requestDate ??
          responseDate.subtract(
            const Duration(milliseconds: 150),
          ),
    );
  }

  static CacheResponse fromJson(Map<String, dynamic> instance) => CacheResponse(
        key: instance['key'],
        content: instance['content'] != null ? utf8.encode(instance['content']) : null,
        date: instance['date'] != null ? DateTime.parse(instance['date']) : null,
        eTag: instance['eTag'],
        expires: instance['expires'] != null ? DateTime.parse(instance['expires']) : null,
        headers: instance['headers'] != null ? utf8.encode(instance['headers']) : null,
        lastModified: instance['lastModified'],
        maxStale: instance['maxStale'] != null ? DateTime.parse(instance['maxStale']) : null,
        responseDate: DateTime.parse(instance['responseDate']),
        url: instance['url'],
        requestDate: DateTime.parse(instance['requestDate']),
        priority: CachePriority.values.byName(instance['priority']),
        cacheControl: CacheControlBox.fromJson(instance['cacheControl']),
      );

  static CacheResponseBox fromObject(CacheResponse response) {
    final result = CacheResponseBox(
      key: response.key,
      content: response.content,
      date: response.date,
      eTag: response.eTag,
      expires: response.expires,
      headers: response.headers,
      lastModified: response.lastModified,
      maxStale: response.maxStale,
      responseDate: response.responseDate,
      url: response.url,
      requestDate: response.requestDate,
      priority: response.priority.index,
      cacheControl: response.cacheControl,
    );

    return result;
  }
}

class CacheControlBox {
  CacheControlBox({
    this.id,
    this.maxAge,
    this.privacy,
    this.noCache,
    this.noStore,
    this.other,
  });

  int? id;
  int? maxAge;
  String? privacy;
  bool? noCache;
  bool? noStore;
  List<String>? other;
  int? maxStale;
  int? minFresh;
  bool? mustRevalidate;

  static Map<String, dynamic> toJson(CacheControl instance) => <String, dynamic>{
        'maxAge': instance.maxAge,
        'privacy': instance.privacy,
        'noCache': instance.noCache,
        'noStore': instance.noStore,
        'other': json.encode(instance.other),
        'maxStale': instance.maxStale,
        'minFresh': instance.minFresh,
        'mustRevalidate': instance.mustRevalidate,
      };

  static CacheControl fromJson(Map<String, dynamic> instance) => CacheControl(
        maxAge: instance['maxAge'] ?? -1,
        privacy: instance['privacy'],
        noCache: instance['noCache'] ?? false,
        noStore: instance['noStore'] ?? false,
        other: instance['other'] != null
            ? (json.decode(instance['other']) as List).map<String>((e) => e).toList()
            : <String>[],
        maxStale: instance['maxStale'] ?? -1,
        minFresh: instance['minFresh'] ?? -1,
        mustRevalidate: instance['mustRevalidate'] ?? false,
      );
}
