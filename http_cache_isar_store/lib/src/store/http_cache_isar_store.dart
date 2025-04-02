import 'package:http_cache_core/http_cache_core.dart';
import 'package:http_cache_isar_store/src/store/cache_collection.dart';
import 'package:isar/isar.dart';

/// A store saving responses using hive.
///
class IsarCacheStore extends CacheStore {
  /// Cache name
  final String name;

  /// Isar directory
  final String directory;

  /// Isar instance
  Isar? _isar;

  /// Initialize cache store by giving Isar a home directory.
  /// [directory] can be null only on web platform or if you already use Hive
  /// in your app.
  IsarCacheStore(
    this.directory, {
    this.name = 'dio_cache',
  }) {
    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final isar = await _openIsar();

    var query = isar.caches
        .filter()
        .priorityLessThan(priorityOrBelow.index, include: true);

    if (staleOnly) {
      query = query.and().maxStaleLessThan(DateTime.now().toUtc());
    }

    await isar.writeTxn(() => query.deleteAll());
  }

  @override
  Future<void> close() {
    final checkedIsar = _isar;
    if (checkedIsar != null && checkedIsar.isOpen) {
      _isar = null;
      return checkedIsar.close();
    }

    return Future.value();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    final isar = await _openIsar();
    var query = isar.caches.filter().cacheKeyEqualTo(key);
    final result = await query.findFirst();
    if (result == null) return Future.value();

    if (staleOnly) {
      query = query.and().maxStaleLessThan(DateTime.now().toUtc());
    }

    await isar.writeTxn(() => query.deleteFirst());
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
  Future<bool> exists(String key) async {
    final isar = await _openIsar();
    final result = await isar.caches.filter().cacheKeyEqualTo(key).count();

    return result != 0;
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final isar = await _openIsar();
    final result = await isar.caches.filter().cacheKeyEqualTo(key).findFirst();
    if (result == null) return null;

    return _mapDataToResponse(result);
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
      onResponseMatch: (r) async => responses.add(_mapDataToResponse(r)),
    );

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) async {
    final isar = await _openIsar();

    await isar.writeTxn(
      () async => isar.caches.putByCacheKey(
        Cache()
          ..cacheControl = response.cacheControl.toHeader()
          ..content = response.content
          ..date = response.date
          ..eTag = response.eTag
          ..expires = response.expires
          ..headers = response.headers
          ..cacheKey = response.key
          ..lastModified = response.lastModified
          ..maxStale = response.maxStale
          ..priority = response.priority.index
          ..requestDate = response.requestDate
          ..responseDate = response.responseDate
          ..url = response.url
          ..statusCode = response.statusCode,
      ),
    );
  }

  Future<void> _getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
    required Future<void> Function(Cache) onResponseMatch,
  }) async {
    final isar = await _openIsar();

    var results = <Cache>[];
    const limit = 10;
    int offset = 0;

    do {
      final results =
          await isar.caches.where().offset(offset).limit(limit).findAll();

      for (final result in results) {
        if (pathExists(result.url, pathPattern, queryParams: queryParams)) {
          await onResponseMatch(result);
        }
      }

      offset = offset + limit;
    } while (results.isNotEmpty);
  }

  Future<Isar> _openIsar() async {
    if (_isar == null) {
      _isar = await Isar.open(
        [CacheSchema],
        directory: directory,
        name: name,
      );

      await clean(staleOnly: true);
    }

    return _isar!;
  }

  CacheResponse _mapDataToResponse(Cache data) {
    return CacheResponse(
      cacheControl: CacheControl.fromString(data.cacheControl),
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
      statusCode: data.statusCode ?? 304,
    );
  }
}
