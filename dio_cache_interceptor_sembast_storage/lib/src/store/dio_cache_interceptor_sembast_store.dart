import 'dart:convert';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sembast/sembast.dart';

import '../factory/sembast_factory.dart';

/// A store saving responses using Sembast.
class SembastCacheStore extends CacheStore {
  /// Sembast store file path
  final String storePath;

  /// Cache box name
  final String cacheStore;

  /// Sembast database
  Database? _database;

  /// Sembast ref instance for [CacheResponseBox]
  final StoreRef<String, Map<String, dynamic>> _store;

  SembastCacheStore({
    required this.storePath,
    this.cacheStore = 'cacheStore',
  }) : _store = stringMapStoreFactory.store(cacheStore) {
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
      final value = CacheResponseExt.fromJson(result.value);
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
    final resp = await get(key);
    if (resp == null) return;

    if (staleOnly && !resp.isStaled()) {
      return;
    }

    final database = await _openDatabase();
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
    // put async/await requests in inner future (because delete also has inner futures)
    // it ensures to call futures in right order
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
    return resp?.value != null ? CacheResponseExt.fromJson(resp!.value) : null;
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
      onResponseMatch: (r) => responses.add(r),
    );

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) async {
    final database = await _openDatabase();
    await _store.record(response.key).delete(database);
    await _store.record(response.key).put(database, response.toJson());
  }

  Future<void> _getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
    required void Function(CacheResponse) onResponseMatch,
  }) async {
    final database = await _openDatabase();
    var results = <RecordSnapshot<String, Map<String, dynamic>>>[];
    const limit = 10;
    int offset = 0;

    do {
      results = await _store.find(
        database,
        finder: Finder(limit: limit, offset: offset),
      );

      for (final result in results) {
        final value = CacheResponseExt.fromJson(result.value);

        if (pathExists(value.url, pathPattern, queryParams: queryParams)) {
          onResponseMatch(value);
        }
      }

      offset += limit;
    } while (results.isNotEmpty);
  }

  Future<Database> _openDatabase() async {
    _database ??= await dbFactory.openDatabase(
      '$storePath/$cacheStore',
    );
    return Future.value(_database);
  }
}

extension CacheResponseExt on CacheResponse {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'content': content != null ? utf8.decode(content!) : null,
      'date': date?.toIso8601String(),
      'eTag': eTag,
      'expires': expires?.toIso8601String(),
      'headers': headers != null ? utf8.decode(headers!) : null,
      'lastModified': lastModified,
      'maxStale': maxStale?.toIso8601String(),
      'responseDate': responseDate.toIso8601String(),
      'url': url,
      'requestDate': requestDate.toIso8601String(),
      'priority': priority.name,
      'cacheControl': cacheControl.toJson(),
    };
  }

  static CacheResponse fromJson(Map<String, dynamic> instance) {
    return CacheResponse(
      key: instance['key'],
      content:
          instance['content'] != null ? utf8.encode(instance['content']) : null,
      date: instance['date'] != null ? DateTime.parse(instance['date']) : null,
      eTag: instance['eTag'],
      expires: instance['expires'] != null
          ? DateTime.parse(instance['expires'])
          : null,
      headers:
          instance['headers'] != null ? utf8.encode(instance['headers']) : null,
      lastModified: instance['lastModified'],
      maxStale: instance['maxStale'] != null
          ? DateTime.parse(instance['maxStale'])
          : null,
      responseDate: DateTime.parse(instance['responseDate']),
      url: instance['url'],
      requestDate: DateTime.parse(instance['requestDate']),
      priority: CachePriority.values.byName(instance['priority']),
      cacheControl: CacheControlExt.fromJson(instance['cacheControl']),
    );
  }
}

extension CacheControlExt on CacheControl {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'maxAge': maxAge,
      'privacy': privacy,
      'noCache': noCache,
      'noStore': noStore,
      'other': json.encode(other),
      'maxStale': maxStale,
      'minFresh': minFresh,
      'mustRevalidate': mustRevalidate,
    };
  }

  static CacheControl fromJson(Map<String, dynamic> instance) {
    return CacheControl(
      maxAge: instance['maxAge'] ?? -1,
      privacy: instance['privacy'],
      noCache: instance['noCache'] ?? false,
      noStore: instance['noStore'] ?? false,
      other: instance['other'] != null
          ? (json.decode(instance['other']) as List)
              .map<String>((e) => e)
              .toList()
          : <String>[],
      maxStale: instance['maxStale'] ?? -1,
      minFresh: instance['minFresh'] ?? -1,
      mustRevalidate: instance['mustRevalidate'] ?? false,
    );
  }
}
