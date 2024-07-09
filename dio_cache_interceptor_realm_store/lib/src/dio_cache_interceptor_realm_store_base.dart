import 'dart:math';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_realm_store/src/domain/dio_cache_realm_models.dart';
import 'package:realm_dart/realm.dart';

/// A store saving responses using Realm.
class RealmCacheStore extends CacheStore {
  /// Realm store file path.
  final String storePath;

  /// Realm store.
  Realm? _realm;

  /// Realm configuration.
  late final Configuration _realmConfig;

  /// Realm object schemas.
  final List<SchemaObject> _realmSchemas = [
    CacheResponseRealm.schema,
    CacheControlRealm.schema,
  ];

  /// Creates a Realm cache store.
  ///
  /// - [storePath] is the path where the Realm file will be stored.
  /// - [inMemmory] if true, the store will be in-memory only. [storePath] is
  ///   still needed to save auxiliary files.
  RealmCacheStore({required this.storePath, bool inMemmory = false}) {
    if (inMemmory) {
      _realmConfig = Configuration.inMemory(
        _realmSchemas,
        path: '$storePath/cache-api.realm',
      );
    } else {
      _realmConfig = Configuration.local(
        _realmSchemas,
        path: '$storePath/cache-api.realm',
        shouldDeleteIfMigrationNeeded: true,
      );
    }

    clean(staleOnly: true);
  }

  Realm _openRealm() {
    _realm ??= Realm(_realmConfig);
    return _realm!;
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final realm = _openRealm();

    // Get all responses with priority less or equal to the given one.
    final results = realm.query<CacheResponseRealm>(
      'cachePriority <= \$0',
      [priorityOrBelow.index],
    );

    // If staleOnly is false, we don't care about maxStale. Just delete all.
    if (!staleOnly) {
      realm.write(() {
        realm.deleteMany(results);
      });
      return;
    }

    // Delete only staled responses.
    realm.write(() {
      for (final response in results) {
        if (_isResponseStaled(response)) {
          realm.delete(response);
        }
      }
    });
  }

  @override
  Future<void> close() async {
    _realm?.close();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    final realm = _openRealm();
    final resp = realm.find<CacheResponseRealm>(key);

    if (resp == null || (staleOnly && !_isResponseStaled(resp))) {
      return;
    }

    realm.write(() {
      realm.delete(resp);
    });
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final realm = _openRealm();

    realm.write(() {
      _getFromPath(
        pathPattern,
        queryParams: queryParams,
        onResponseMatch: (freezedResponse) {
          final response = realm.find<CacheResponseRealm>(freezedResponse.key);
          if (response != null) {
            realm.delete(response);
          }
        },
      );
    });
  }

  @override
  Future<bool> exists(String key) {
    final realm = _openRealm();
    return Future.value(realm.find<CacheResponseRealm>(key) != null);
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final realm = _openRealm();
    final resp = realm.find<CacheResponseRealm>(key);
    return resp?.toObject();
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final List<CacheResponse> responses = [];

    _getFromPath(
      pathPattern,
      queryParams: queryParams,
      onResponseMatch: (r) => responses.add(r.toObject()),
    );

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) async {
    final realm = _openRealm();
    final existing = realm.find<CacheResponseRealm>(response.key);

    realm.write(() {
      if (existing != null) {
        realm.delete(existing);
      }
      realm.add($CacheResponseRealm.fromObject(response));
    });
  }

  bool _isResponseStaled(CacheResponseRealm response) {
    return response.maxStale?.isBefore(DateTime.now()) ?? false;
  }

  void _getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
    required void Function(CacheResponseRealm) onResponseMatch,
  }) {
    final realm = _openRealm();

    /// The database can change between each `onResponseMatch` call, so freezing
    /// it to avoid any complications.
    final allResponses = realm.all<CacheResponseRealm>().freeze();

    try {
      Iterable<CacheResponseRealm> results;
      const limit = 10;
      int offset = 0;

      do {
        results =
            allResponses.skip(min(offset, allResponses.length)).take(limit);

        for (final result in results) {
          if (pathExists(result.url, pathPattern, queryParams: queryParams)) {
            onResponseMatch(result);
          }
        }

        offset += limit;
      } while (results.isNotEmpty);
    } finally {
      /// There will be nasty memory leaks if the freezed allResponses.realm is
      /// not closed, so we putting it in the finally block just to be sure.
      allResponses.realm.close();
    }
  }
}
