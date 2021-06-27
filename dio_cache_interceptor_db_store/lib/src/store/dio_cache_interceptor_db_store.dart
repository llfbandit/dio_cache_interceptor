import 'package:dio_cache_interceptor/src/model/cache_priority.dart';
import 'package:dio_cache_interceptor/src/model/cache_response.dart';
import 'package:dio_cache_interceptor/src/store/cache_store.dart';
import 'package:dio_cache_interceptor_db_store/src/store/database.dart';

/// A store saving responses in a dedicated database
/// from an optional [directory].
///
class DbCacheStore implements CacheStore {
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
  Future<bool> exists(String key) {
    return _db.dioCacheDao.exists(key);
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final resp = await _db.dioCacheDao.get(key);
    if (resp == null) return null;

    // Purge entry if staled
    if (resp.isStaled()) {
      await delete(key);
      return null;
    }

    return resp;
  }

  @override
  Future<void> set(CacheResponse response) {
    return _db.dioCacheDao.set(response);
  }

  @override
  Future<void> close() {
    return _db.close();
  }
}
