import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/src/store/database.dart';

/// A store saving responses in a dedicated database
/// from an optional [directory].
///
class DbCacheStore extends CacheStore {
  static const String tableName = 'dio_cache';

  /// Database name. Optional.
  /// - Defaults to [DbCacheStore.tableName]
  /// - Useful if you want more than one DB.
  final String databaseName;

  /// Database location.
  ///
  /// - On mobile, prefer getApplicationDocumentsDirectory()
  ///   given by path_provider.
  /// - On desktop, current directory by default.
  /// - On web, this is ignored.
  final String databasePath;

  /// Log DB statements. Defaults to [false].
  final bool logStatements;

  // Our DB connection
  final DioCacheDatabase _db;

  /// SQLite WASM library path
  final String webSqlite3WasmPath;

  /// Drift worker path
  final String webDriftWorkerPath;

  DbCacheStore({
    required this.databasePath,
    this.databaseName = tableName,
    this.logStatements = false,
    this.webSqlite3WasmPath = 'sqlite3.wasm',
    this.webDriftWorkerPath = 'drift_worker.dart.js',
  }) : _db = DioCacheDatabase(openDb(
          databasePath: databasePath,
          databaseName: databaseName,
          webSqlite3WasmPath: webSqlite3WasmPath,
          webDriftWorkerPath: webDriftWorkerPath,
          logStatements: logStatements,
        )) {
    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) {
    return _db.dioCacheDao.clean(
      priorityOrBelow: priorityOrBelow,
      staleOnly: staleOnly,
    );
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) {
    return _db.dioCacheDao.deleteKey(key, staleOnly: staleOnly);
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    return _getFromPath(
      pathPattern,
      queryParams: queryParams,
      onResponseMatch: (r) => delete(r.cacheKey),
    );
  }

  @override
  Future<bool> exists(String key) {
    return _db.dioCacheDao.exists(key);
  }

  @override
  Future<CacheResponse?> get(String key) {
    return _db.dioCacheDao.get(key);
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
      onResponseMatch: (r) async => responses.add(
        _db.dioCacheDao.mapDataToResponse(r),
      ),
    );

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) {
    return _db.dioCacheDao.set(response);
  }

  @override
  Future<void> close() {
    return _db.close();
  }

  Future<void> _getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
    required Future<void> Function(DioCacheData) onResponseMatch,
  }) async {
    var results = <DioCacheData>[];
    const limit = 10;
    int? offset;

    do {
      final query = _db.dioCacheDao.select(_db.dioCacheDao.dioCache)
        ..limit(limit, offset: offset);
      results = await query.get();

      for (final result in results) {
        if (pathExists(result.url, pathPattern, queryParams: queryParams)) {
          await onResponseMatch(result);
        }
      }

      offset = (offset ?? 0) + limit;
    } while (results.isNotEmpty);
  }
}
