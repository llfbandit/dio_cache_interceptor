import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/src/store/database.dart';
import 'package:drift/drift.dart';

/// A store saving responses in a dedicated database
/// from an optional [directory].
///
class DbCacheStore extends CacheStore {
  static const String tableName = 'dio_cache';

  /// Database name. Optional.
  /// - Defaults to [DbCacheStore.tableName]
  /// - Useful if you want more than one DB.
  final String databaseName;

  /// Data base location.
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

  DbCacheStore({
    required this.databasePath,
    this.databaseName = tableName,
    this.logStatements = false,
  }) : _db = openDb(
          databasePath: databasePath,
          databaseName: databaseName,
          logStatements: logStatements,
        ) {
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
    List<MapEntry<String, String>> results = [];

    final Expression<bool> matchesPath = _db.dioCacheDao.dioCache.url.regexp(
      pathPattern.pattern,
      multiLine: pathPattern.isMultiLine,
      caseSensitive: pathPattern.isCaseSensitive,
      unicode: pathPattern.isUnicode,
      dotAll: pathPattern.isDotAll,
    );

    results = await (_db.dioCacheDao.selectOnly(_db.dioCacheDao.dioCache)
          ..where(matchesPath)
          ..addColumns([
            _db.dioCacheDao.dioCache.cacheKey,
            _db.dioCacheDao.dioCache.url,
          ]))
        .map(
          (p0) => MapEntry(
            p0.read(_db.dioCacheDao.dioCache.cacheKey)!,
            p0.read(_db.dioCacheDao.dioCache.url)!,
          ),
        )
        .get();

    results.removeWhere(
      (e) => !pathExists(e.value, pathPattern, queryParams: queryParams),
    );

    await onResult(results.map((e) => e.key).toList());
  }
}
