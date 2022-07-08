import '../model/cache_priority.dart';
import '../model/cache_response.dart';
import 'cache_store.dart';

/// A store saving responses in a dedicated [primary]
/// store and [secondary] store.
///
/// Cached responses are read from [primary] first, and then
/// from [secondary].
///
/// Mostly useful when you want MemCacheStore before another.
///
class BackupCacheStore extends CacheStore {
  /// Primary cache store
  final CacheStore primary;

  /// Secondary cache store
  final CacheStore secondary;

  BackupCacheStore({required this.primary, required this.secondary}) {
    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    await primary.clean(
      priorityOrBelow: priorityOrBelow,
      staleOnly: staleOnly,
    );
    return secondary.clean(
      priorityOrBelow: priorityOrBelow,
      staleOnly: staleOnly,
    );
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    await primary.delete(key, staleOnly: staleOnly);
    return secondary.delete(key, staleOnly: staleOnly);
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    await primary.deleteFromPath(pathPattern, queryParams: queryParams);
    return secondary.deleteFromPath(pathPattern, queryParams: queryParams);
  }

  @override
  Future<bool> exists(String key) async {
    return await primary.exists(key) || await secondary.exists(key);
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final resp = await primary.get(key);
    if (resp != null) return resp;

    return secondary.get(key);
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = <CacheResponse>[];

    responses.addAll(
        await primary.getFromPath(pathPattern, queryParams: queryParams));
    responses.addAll(
        await secondary.getFromPath(pathPattern, queryParams: queryParams));

    return responses.toSet().toList(growable: false);
  }

  @override
  Future<void> set(CacheResponse response) async {
    await primary.set(response);
    return secondary.set(response);
  }

  @override
  Future<void> close() async {
    await primary.close();
    return secondary.close();
  }
}
