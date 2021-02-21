import 'package:dio_cache_interceptor/src/model/cache_priority.dart';
import 'package:dio_cache_interceptor/src/model/cache_response.dart';
import 'package:dio_cache_interceptor/src/store/cache_store.dart';
import 'package:dio_cache_interceptor/src/store/db_cache_store/database.dart';
import 'package:meta/meta.dart';

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
<<<<<<< HEAD
  /// - On mobile, prefer getApplicationDocumentsDirectory()
  ///   given by path_provider.
  /// - On desktop, current directory by default.
  /// - On web, this is ignored.
  final String databasePath;
=======
  /// By default:
  /// - On Android, data/data/package_name/databases.
  /// - On iOS, Documents directory.
  final String? databasePath;
>>>>>>> fixing tests

  /// Log DB statements. Defaults to [false].
  final bool logStatements;

  // Our DB connection
<<<<<<< HEAD
  DioCacheDatabase _db;
=======
  Database? _db;
>>>>>>> fixing tests

  DbCacheStore({
    @required this.databasePath,
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
<<<<<<< HEAD
  Future<CacheResponse> get(String key) {
    final db = _getDatabase();
    if (db == null) return Future.value();

    return db.dioCacheDao.get(key);
  }

  @override
  Future<void> set(CacheResponse response) {
    final db = _getDatabase();
    if (db == null) return Future.value();

    return db.dioCacheDao.set(response);
=======
  Future<CacheResponse?> get(String key) async {
    final db = await _getDatabase();

    if (db != null) {
      final where = '$_columnKey = \"$key\"';
      final List<Map> resultList = await db.query(_tableName, where: where);
      if (resultList.isEmpty) return Future.value();

      final result = resultList.first;

      // Purge entry if stalled
      final maxStale = result[_columnMaxStale];
      if (maxStale != null) {
        final date =
            DateTime.fromMillisecondsSinceEpoch(maxStale * 1000, isUtc: true);
        if (DateTime.now().toUtc().isAfter(date)) {
          await delete(key);
          return Future.value();
        }
      }

      return CacheResponse(
        cacheControl:
            CacheControl.fromHeader(result[_columnCacheControl]?.split(', ')),
        content: result[_columnContent],
        date: DateTime.tryParse(result[_columnDate]) ?? DateTime.now(),
        eTag: result[_columnETag],
        expires: DateTime.tryParse(result[_columnExpires]) ?? DateTime.now(),
        headers: result[_columnHeaders],
        key: key,
        lastModified: result[_columnLastModified],
        maxStale: maxStale != null
            ? DateTime.fromMillisecondsSinceEpoch(maxStale * 1000, isUtc: true)
            : DateTime.now(),
        priority: CachePriority.values[result[_columnPriority]],
        responseDate: DateTime.parse(result[_columnResponseDate]),
        url: result[_columnUrl],
      );
    }

    return Future.value();
  }

  @override
  Future<void> set(CacheResponse response) async {
    final db = await _getDatabase();

    if (db != null) {
      await db.insert(
        _tableName,
        {
          _columnDate: response.date.toIso8601String(),
          _columnCacheControl: response.cacheControl.toHeader(),
          _columnContent: response.content,
          _columnETag: response.eTag,
          _columnExpires: response.expires.toIso8601String(),
          _columnHeaders: response.headers,
          _columnKey: response.key,
          _columnLastModified: response.lastModified,
          _columnMaxStale: response.getMaxStaleSeconds(),
          _columnPriority: response.priority.index,
          _columnResponseDate: response.responseDate.toIso8601String(),
          _columnUrl: response.url,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
>>>>>>> fixing tests
  }

  DioCacheDatabase _getDatabase() {
    if (_db != null) return _db;

    _db = openDb(
      databasePath: databasePath,
      databaseName: databaseName,
      logStatements: logStatements,
    );

<<<<<<< HEAD
=======
  Future<String?> _tryGetDatabasesPath() async {
    try {
      return await getDatabasesPath();
    } catch (_) {
      return null;
    }
  }

  Future<Database?> _getDatabase() async {
    if (_db == null) {
      final path = databasePath ?? await _tryGetDatabasesPath() ?? '';
      await Directory(path).create(recursive: true);

      _db = await openDatabase(
        join(path, '$databaseName.db'),
        version: _currentDbVersion,
        onCreate: (Database db, int version) async {
          await db.execute(_getCreateTableSqlV2());
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          final batch = db.batch();
          if (oldVersion == 1) {
            _updateTableV1toV2(batch);
          }
          await batch.commit();
        },
      );
    }
>>>>>>> fixing tests
    return _db;
  }

  @override
  Future<void> close() {
    return _db?.close();
  }
}
