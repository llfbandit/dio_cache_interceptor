import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:drift/drift.dart';

export 'db_platform/db_platform.dart';

part 'database.g.dart';

@DriftDatabase(include: {'cache_table.moor'}, daos: [DioCacheDao])
class DioCacheDatabase extends _$DioCacheDatabase {
  DioCacheDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}

@DriftAccessor(include: {'cache_table.moor'})
class DioCacheDao extends DatabaseAccessor<DioCacheDatabase>
    with _$DioCacheDaoMixin {
  DioCacheDao(DioCacheDatabase db) : super(db);

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
        final Expression<bool?> expr = t.cacheKey.equals(key);

        return staleOnly
            ? expr & t.maxStale.isSmallerOrEqualValue(DateTime.now().toUtc())
            : expr;
      });

    await query.go();
  }

  Future<bool> exists(String key) async {
    final countExp = dioCache.cacheKey.count();
    final query = selectOnly(dioCache)..addColumns([countExp]);
    final count = await query.map((row) => row.read(countExp)).getSingle();

    return count == 1;
  }

  Future<CacheResponse?> get(String key) async {
    // Get record
    final query = select(dioCache)
      ..where((t) => t.cacheKey.equals(key))
      ..limit(1);
    final result = await query.getSingleOrNull();
    if (result == null) return Future.value();

    return CacheResponse(
      cacheControl: CacheControl.fromHeader(result.cacheControl?.split(', ')),
      content: result.content,
      date: result.date,
      eTag: result.eTag,
      expires: result.expires,
      headers: result.headers,
      key: key,
      lastModified: result.lastModified,
      maxStale: result.maxStale,
      priority: CachePriority.values[result.priority],
      responseDate: result.responseDate,
      url: result.url,
    );
  }

  Future<void> set(CacheResponse response) async {
    final checkedContent = response.content;
    final checkedHeaders = response.headers;

    await into(dioCache).insert(
      DioCacheData(
        date: response.date,
        cacheControl: response.cacheControl?.toHeader(),
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
        responseDate: response.responseDate,
        url: response.url,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
