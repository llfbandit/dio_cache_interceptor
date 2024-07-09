import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_realm_store/src/domain/dio_cache_realm_models.dart';
import 'package:realm_dart/realm.dart';

/// A store saving responses using Realm.
class RealmCacheStore extends CacheStore {
  /// Realm store file path.
  final String storePath;

  /// Realm store.
  Realm? _realm;

  RealmCacheStore({required this.storePath}) {
    clean(staleOnly: true);
  }

  Realm _openRealm() {
    if (_realm == null) {
      final realmCfg = Configuration.local(
        [
          CacheResponseRealm.schema,
          CacheControlRealm.schema,
        ],
        path: '$storePath/cache-api.realm',
        shouldDeleteIfMigrationNeeded: true,
      );

      _realm = Realm(realmCfg);
    }

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
    // if (!staleOnly) {
    //   realm.write(() {
    //     realm.deleteMany(results);
    //   });
    //   return;
    // }

    // Delete only staled responses.
    // final stalledResponses = _getStalledResponses();
    // final stalledResult = results.query(
    //   'key IN \$0',
    //   [stalledResponses.map((e) => e.key)],
    // );
    // realm.write(() {
    //   realm.deleteMany(stalledResult);
    // });

    for (final result in results) {
      if ((staleOnly && result.toObject().isStaled()) || !staleOnly) {
        realm.write(() {
          realm.delete(result);
        });
      }
    }
  }

  // RealmResults<CacheResponseRealm> _getStalledResponses() {
  //   final realm = _openRealm();

  //   // Realm stores dates in UTC.
  //   final utcNow = DateTime.now().toUtc();
  //   return realm.query<CacheResponseRealm>(
  //     // This is the equivalent of maxStale?.isBefore(DateTime.now()) ?? false
  //     'maxStale != nil AND maxStale < \$0',
  //     [utcNow],
  //   );
  // }

  @override
  Future<void> close() async {
    _realm?.close();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    final realm = _openRealm();
    final resp = realm.find<CacheResponseRealm>(key);

    if (resp == null || (staleOnly && !resp.toObject().isStaled())) {
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
        onResponseMatch: realm.delete,
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

  void _getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
    required void Function(CacheResponseRealm) onResponseMatch,
  }) {
    final realm = _openRealm();

    /// Don't freak out, this is lazily loaded.
    ///
    /// Because Realm does not support skip/offset, we have to implement it
    /// ownselves.
    ///
    /// The database can change between each do-while iteration, so freezing it
    /// to avoid any complications.
    final allResponses = realm.all<CacheResponseRealm>().freeze();

    try {
      RealmResults<CacheResponseRealm> results;
      const limit = 10;
      int offset = 0;

      do {
        results = allResponses.skip(offset).query('LIMIT($limit)');

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
