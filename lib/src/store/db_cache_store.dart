import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/cache_priority.dart';
import '../model/cache_response.dart';
import 'cache_store.dart';

/// A store that save each request result in a dedicated database.
///
class DbCacheStore extends CacheStore {
  static const String _tableName = 'dio_cache';
  static const String _columnKey = 'key';
  static const String _columnContent = 'content';
  static const String _columnETag = 'etag';
  static const String _columnHeaders = 'headers';
  static const String _columnLastModified = 'last_modified';
  static const String _columnMaxStale = 'max_stale';
  static const String _columnPriority = 'priority';
  static const String _columnUrl = 'url';
  static const int _currentDbVersion = 1;

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
    clean(stalledOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool stalledOnly = false,
  }) async {
    final db = await _getDatabase();

    if (db != null) {
      final where = StringBuffer(
        '$_columnPriority <= ${priorityOrBelow.index}',
      );
      _whereMaxStale(stalledOnly, where);

      await db.delete(_tableName, where: where.toString());
    }
  }

  @override
  Future<void> delete(String key, {bool stalledOnly = false}) async {
    final db = await _getDatabase();

    if (db != null) {
      final where = StringBuffer('$_columnKey = \"$key\"');
      _whereMaxStale(stalledOnly, where);

      await db.delete(_tableName, where: where.toString());
    }
  }

  @override
  Future<CacheResponse> get(String key) async {
    final db = await _getDatabase();

    if (db != null) {
      final where = '$_columnKey = \"$key\"';
      final List<Map> resultList = await db.query(_tableName, where: where);

      if (resultList.isNotEmpty) {
        final result = resultList.first;

        return CacheResponse(
          key: key,
          content: result[_columnContent],
          eTag: result[_columnETag],
          headers: result[_columnHeaders],
          lastModified: result[_columnLastModified],
          maxStale: result[_columnMaxStale],
          priority: CachePriority.values[result[_columnPriority]],
          url: result[_columnUrl],
        );
      }
    }

    return null;
  }

  @override
  Future<void> set(CacheResponse response) async {
    final db = await _getDatabase();

    if (db != null) {
      final maxStale = (response.maxStale != null)
          ? (DateTime.now().millisecondsSinceEpoch / 1000) +
              response.maxStale.inSeconds
          : null;

      await db.insert(
        _tableName,
        {
          _columnKey: response.key,
          _columnContent: response.content,
          _columnETag: response.eTag,
          _columnHeaders: response.headers,
          _columnLastModified: response.lastModified,
          _columnMaxStale: maxStale,
          _columnPriority: response.priority.index,
          _columnUrl: response.url,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  void _whereMaxStale(bool stalledOnly, StringBuffer where) {
    if (stalledOnly) {
      final expiry = DateTime.now().millisecondsSinceEpoch / 1000;

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
          await db.execute(_getCreateTableSql());
        },
      );
    }
    return _db;
  }

  String _getCreateTableSql() {
    return '''
      CREATE TABLE IF NOT EXISTS $_tableName ( 
        $_columnKey text, 
        $_columnContent BLOB,
        $_columnETag text,
        $_columnHeaders BLOB,
        $_columnLastModified text,
        $_columnMaxStale integer,
        $_columnPriority integer,
        $_columnUrl text,
        PRIMARY KEY ($_columnKey)
        ) 
      ''';
  }
}
