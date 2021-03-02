import 'dart:io';

import 'package:dio_cache_interceptor/src/model/cache_control.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/cache_priority.dart';
import '../model/cache_response.dart';
import 'cache_store.dart';

/// A store saving responses in a dedicated database
/// from an optional [directory].
///
class DbCacheStore extends CacheStore {
  static const String _tableName = 'dio_cache';

  static const String _columnDate = 'date';
  static const String _columnKey = 'key';
  static const String _columnCacheControl = 'cache_control';
  static const String _columnContent = 'content';
  static const String _columnETag = 'etag';
  static const String _columnExpires = 'expires';
  static const String _columnHeaders = 'headers';
  static const String _columnLastModified = 'last_modified';
  static const String _columnMaxStale = 'max_stale';
  static const String _columnPriority = 'priority';
  static const String _columnResponseDate = 'response_date';
  static const String _columnUrl = 'url';

  static const int _currentDbVersion = 2;

  /// Database name. Optional.
  /// Useful if you want more than one DB.
  final String databaseName;

  /// Data base location. Optional.
  ///
  /// By default:
  /// - On Android, data/data/package_name/databases.
  /// - On iOS, Documents directory.
  final String databasePath;

  // Our DB connection
  Database _db;

  DbCacheStore({this.databaseName = _tableName, this.databasePath}) {
    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final db = await _getDatabase();

    if (db != null) {
      final where = StringBuffer(
        '$_columnPriority <= ${priorityOrBelow.index}',
      );
      _whereMaxStale(staleOnly, where);

      await db.delete(_tableName, where: where.toString());
    }

    return Future.value();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    final db = await _getDatabase();

    if (db != null) {
      final where = StringBuffer('$_columnKey = \"$key\"');
      _whereMaxStale(staleOnly, where);

      await db.delete(_tableName, where: where.toString());
    }

    return Future.value();
  }

  @override
  Future<bool> exists(String key) async {
    final db = await _getDatabase();

    if (db != null) {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT($_columnKey) FROM $_tableName'),
      );

      return count == 1;
    }

    return Future.value(false);
  }

  @override
  Future<CacheResponse> get(String key) async {
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
        date: result[_columnDate] != null
            ? DateTime.tryParse(result[_columnDate])
            : null,
        eTag: result[_columnETag],
        expires: result[_columnExpires] != null
            ? DateTime.tryParse(result[_columnExpires])
            : null,
        headers: result[_columnHeaders],
        key: key,
        lastModified: result[_columnLastModified],
        maxStale: maxStale != null
            ? DateTime.fromMillisecondsSinceEpoch(maxStale * 1000, isUtc: true)
            : null,
        priority: CachePriority.values[result[_columnPriority]],
        responseDate: DateTime.tryParse(result[_columnResponseDate]),
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
          _columnCacheControl: response.cacheControl?.toHeader(),
          _columnContent: response.content,
          _columnETag: response.eTag,
          _columnExpires: response.expires?.toIso8601String(),
          _columnHeaders: response.headers,
          _columnKey: response.key,
          _columnLastModified: response.lastModified,
          _columnMaxStale: response.getMaxStaleSeconds()?.toString(),
          _columnPriority: response.priority.index,
          _columnResponseDate: response.responseDate.toIso8601String(),
          _columnUrl: response.url,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  void _whereMaxStale(bool staleOnly, StringBuffer where) {
    if (staleOnly) {
      final expiry = DateTime.now().toUtc().millisecondsSinceEpoch / 1000;

      where.write(' AND ');
      where.write('$_columnMaxStale <= $expiry');
    }
  }

  Future<Database> _getDatabase() async {
    if (_db == null) {
      final path = databasePath ?? await getDatabasesPath();
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
    return _db;
  }

  String _getCreateTableSqlV2() {
    return '''
      CREATE TABLE IF NOT EXISTS $_tableName (
        $_columnDate TEXT,
        $_columnKey TEXT,
        $_columnCacheControl TEXT,
        $_columnContent BLOB,
        $_columnETag TEXT,
        $_columnExpires TEXT,
        $_columnHeaders BLOB,
        $_columnLastModified TEXT,
        $_columnMaxStale INTEGER,
        $_columnPriority INTEGER,
        $_columnResponseDate TEXT,
        $_columnUrl TEXT,
        PRIMARY KEY ($_columnKey)
        ) 
      ''';
  }

  void _updateTableV1toV2(Batch batch) {
    batch.execute('ALTER TABLE $_tableName ADD $_columnCacheControl TEXT');
    batch.execute('ALTER TABLE $_tableName ADD $_columnDate TEXT');
    batch.execute('ALTER TABLE $_tableName ADD $_columnExpires TEXT');
    batch.execute('ALTER TABLE $_tableName ADD $_columnResponseDate TEXT');
  }
}
