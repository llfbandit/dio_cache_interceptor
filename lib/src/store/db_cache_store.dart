import 'package:dio_cache_interceptor/src/model/cache_priority.dart';
import 'package:dio_cache_interceptor/src/model/cache_response.dart';
import 'package:dio_cache_interceptor/src/store/cache_store.dart';
import 'package:dio_cache_interceptor/src/store/db_cache_store/database.dart';

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
  DioCacheDatabase? _db;

  DbCacheStore({
    required this.databasePath,
    this.databaseName = tableName,
    this.logStatements = false,
  }) {
    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) {
    final db = _getDatabase();
    if (db == null) return Future.value();

    return db.dioCacheDao.clean(
      priorityOrBelow: priorityOrBelow,
      staleOnly: staleOnly,
    );
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) {
    final db = _getDatabase();
    if (db == null) return Future.value();

    return db.dioCacheDao.deleteKey(key, staleOnly: staleOnly);
  }

  @override
  Future<bool> exists(String key) {
    final db = _getDatabase();
    if (db == null) return Future.value(false);

    return db.dioCacheDao.exists(key);
  }

  @override
  Future<CacheResponse?> get(String key) {
    final db = _getDatabase();
    if (db == null) return Future.value();

    return db.dioCacheDao.get(key);
  }

  @override
  Future<void> set(CacheResponse response) {
    final db = _getDatabase();
    if (db == null) return Future.value();

    return db.dioCacheDao.set(response);
  }

  DioCacheDatabase? _getDatabase() {
    if (_db != null) return _db;

    _db = openDb(
      databasePath: databasePath,
      databaseName: databaseName,
      logStatements: logStatements,
    );

    return _db;
  }

  @override
  Future<void> close() {
    return _db?.close() ?? Future.value();
  }
}
