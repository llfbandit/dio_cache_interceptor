import 'package:http_cache_drift_store/src/store/database.dart';
import 'package:drift/drift.dart';
import 'package:http_cache_core/http_cache_core.dart';

/// A store saving responses in a dedicated database
/// from an optional [directory].
///
class DriftCacheStore extends CacheStore {
  static const String tableName = 'dio_cache';

  /// Database name. Optional.
  /// - Defaults to [DriftCacheStore.tableName]
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

  DriftCacheStore({
    required this.databasePath,
    this.databaseName = tableName,
    this.logStatements = false,
    this.webSqlite3WasmPath = 'sqlite3.wasm',
    this.webDriftWorkerPath = 'drift_worker.js',
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
  }) {
    return _getFromPath(
      pathPattern,
      queryParams: queryParams,
      onResult: _db.dioCacheDao.deleteKeys,
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
      onResult: (keys) async => responses.addAll(
        await _db.dioCacheDao.getMany(keys),
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
    required Future<void> Function(List<String>) onResult,
  }) async {
    final cache = _db.dioCacheDao.dioCache;

    final matchesPath = cache.url.regexp(
      pathPattern.pattern,
      multiLine: pathPattern.isMultiLine,
      caseSensitive: pathPattern.isCaseSensitive,
      unicode: pathPattern.isUnicode,
      dotAll: pathPattern.isDotAll,
    );

    final results = await (_db.dioCacheDao.selectOnly(cache)
          ..where(matchesPath)
          ..addColumns([cache.cacheKey, cache.url]))
        .map((result) => MapEntry(
              result.read(cache.cacheKey)!,
              result.read(cache.url)!,
            ))
        .get();

    results.removeWhere(
      (e) => !pathExists(e.value, pathPattern, queryParams: queryParams),
    );

    await onResult(results.map((e) => e.key).toList());
  }
}
