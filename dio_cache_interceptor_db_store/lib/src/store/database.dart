import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:drift/drift.dart';

export 'db_platform/db_platform.dart';

part 'database.g.dart';

typedef _MigrateFunction = Future<void> Function(
  Migrator,
  DioCacheDatabase,
  int,
);

@DriftDatabase(include: {'cache_table.drift'}, daos: [DioCacheDao])
class DioCacheDatabase extends _$DioCacheDatabase {
  DioCacheDatabase(super.e);

  final Map<int, _MigrateFunction> _migrationsMap = {
    1: _migrateToV2,
  };

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (Migrator m, int from, int to) async {
        if (to < from) {
          throw Exception("Can't downgrade database");
        }

        await transaction(
          () async {
            // Create all missing elements
            // This is always true for all versions
            await m.createAll();

            for (var i = from; i < to; i++) {
              await _migrationsMap[i]?.call(m, this, from);
            }
          },
        );
      },
    );
  }

  static Future<void> _migrateToV2(
    Migrator m,
    DioCacheDatabase db,
    int from,
  ) async {
    if (from == 1) {
      await m.alterTable(TableMigration(
        db.dioCache,
        newColumns: [db.dioCache.requestDate],
      ));
    }
  }
}

@DriftAccessor(include: {'cache_table.drift'})
class DioCacheDao extends DatabaseAccessor<DioCacheDatabase>
    with _$DioCacheDaoMixin {
  DioCacheDao(super.db);

  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final query = delete(dioCache)
      ..where(
        (t) {
          var expr = t.priority.isSmallerOrEqualValue(priorityOrBelow.index);
          if (staleOnly) {
            expr =
                expr & t.maxStale.isSmallerOrEqualValue(DateTime.now().toUtc());
          }
          return expr;
        },
      );

    await query.go();
  }

  Future<void> deleteKey(String key, {bool staleOnly = false}) async {
    final query = delete(dioCache)
      ..where((t) {
        final expr = t.cacheKey.equals(key);

        return staleOnly
            ? expr & t.maxStale.isSmallerOrEqualValue(DateTime.now().toUtc())
            : expr;
      });

    await query.go();
  }

  Future<bool> exists(String key) async {
    final query = select(dioCache)
      ..where((t) => t.cacheKey.equals(key))
      ..limit(1);
    return (await query.getSingleOrNull()) != null;
  }

  Future<CacheResponse?> get(String key) async {
    // Get record
    final query = select(dioCache)
      ..where((t) => t.cacheKey.equals(key))
      ..limit(1);
    final result = await query.getSingleOrNull();
    if (result == null) return Future.value();

    return mapDataToResponse(result);
  }

  Future<void> set(CacheResponse response) async {
    final checkedContent = response.content;
    final checkedHeaders = response.headers;

    await into(dioCache).insert(
      DioCacheData(
        date: response.date,
        cacheControl: response.cacheControl.toHeader(),
        content: (checkedContent != null)
            ? Uint8List.fromList(checkedContent)
            : null,
        eTag: response.eTag,
        expires: response.expires,
        headers: (checkedHeaders != null)
            ? Uint8List.fromList(checkedHeaders)
            : null,
        cacheKey: response.key,
        lastModified: response.lastModified,
        maxStale: response.maxStale,
        priority: response.priority.index,
        requestDate: response.requestDate,
        responseDate: response.responseDate,
        url: response.url,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  CacheResponse mapDataToResponse(DioCacheData data) {
    return CacheResponse(
      cacheControl: CacheControl.fromHeader(data.cacheControl?.split(', ')),
      content: data.content,
      date: data.date,
      eTag: data.eTag,
      expires: data.expires,
      headers: data.headers,
      key: data.cacheKey,
      lastModified: data.lastModified,
      maxStale: data.maxStale,
      priority: CachePriority.values[data.priority],
      requestDate: data.requestDate ??
          data.responseDate.subtract(const Duration(milliseconds: 150)),
      responseDate: data.responseDate,
      url: data.url,
    );
  }
}
